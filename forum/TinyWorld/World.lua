World = class()
-- Tiny World class
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
Red   = math.random(255)
Green = math.random(255)
Blue  = math.random(255)
WORLD_START = 1
WORLD_WAIT  = 2
WORLD_BREAK = 3
WORLD_SAVED = 4
function World:init(maxpeople)
    self.last_touch = nil
    self.touch  = nil
    self.moving = false
    self.people = {}
    self.houses = {}
    self.stars  = Stars()
    self.road   = Road()
    self.driver = math.random(maxpeople-1) -- random person is the driver of souls xD
    self.destiny= 1 --math.random(math.floor(maxpeople/2)) -- random house
    self.maxhouses = 1
    self.maxpeople = maxpeople
    self.state  = WORLD_START
    for i=1,maxpeople do
        table.insert(self.people, Person(
         vec2(math.random(WIDTH) , math.random(HEIGHT) )
        ))
    end
    for i=1,self.maxhouses do
        table.insert(self.houses, House(
         vec2( (WIDTH/2) - (math.random(-111,111)), (HEIGHT/2) + i*math.random(-111,111) )
        ) )
    end
    self.stars.angle = 0
    self.fireworks = {}
    self.aliens_touched = 0
    self.asteroids_touched = 0
    self.total_frames = 0
end

function World:travelStart()
    sound(DATA, "ZgBAOQA/Syw4PwEr5tOFPL2cND/QyTU9TgASVExCPiUuNVJA")
    self.state     = WORLD_TRAVEL
    --self.road   = nil
    self.aliens    = {}
    self.asteroids = {}
    table.insert(self.aliens,Alien())
    self.frame = 6
    table.insert(self.asteroids,Asteroid(self.houses[self.destiny].position))
end

function World:updateTravel()
    if self.frame<=0 then
        if self.aliens_touched<7 then
            table.insert(self.aliens,Alien())
        end
        table.insert(self.asteroids,Asteroid(self.houses[self.destiny].position))
        self.frame = 7
    elseif self.frame>0 then
        self.frame = self.frame - 1/11
    end

end

function World:update()
    self.total_frames = (self.total_frames + 1)%128
    if self.state == WORLD_TRAVEL then
        self:updateTravel()
        return
    end
    if self.state == WORLD_WAIT then return end
    if self.road.state == ROAD_END then
        table.insert(self.fireworks, Fireworks(
            self.people[self.driver].position.x,
            self.people[self.driver].position.y,
            242,255,0
        ))
        --length road penalization
        score = score - (self.road.distance*100)

        self.road:init()
        for i,person in ipairs(self.people) do
            if person.friend == nil then
                table.insert(self.fireworks, Fireworks(
                    person.position.x,
                    person.position.y,
                    math.random(255),math.random(255),math.random(255)
                ))
                score = score - math.random(600)
            end
            --person.with_us = false
            --person.friend  = nil

        end
        if score < 0 then
            score = 0
        end
        self.people = {}
        -- change instances states
        for i,house in ipairs(self.houses) do
            house.state = WORLD_WAIT
        end
        self.state = WORLD_WAIT
        return
    end

    self.touch = vec2(CurrentTouch.x, CurrentTouch.y)
    if CurrentTouch.state == ENDED then
        -- to make sure we don't miss the touch began state
        self.moving = false
        local hit_house = self.houses[self.destiny].position:dist(self.touch) <66
        if hit_house and self.road.person~= nil then
            self.road.state = ROAD_RUN
            -- add destiny
            self.road:add(self.houses[self.destiny].position,R,G,B,255)
            -- compute total distance
            self.road.distance = self.road:length()
        else -- clear not valid touches
            self.road:init()
            for i,p in ipairs(self.people) do
                p.with_us = false
                p.friend  = nil
            end
        end
    elseif CurrentTouch.state == BEGAN then
        local hit_driver = self.people[self.driver].position:dist(self.touch) <33
        if self.touch ~= self.last_touch and hit_driver then
            self.last_touch = self.touch
            self:new_move(self.touch,Red,Green,Blue)
        end
    elseif CurrentTouch.state == MOVING and self.road.person~=nil then
        if self.touch ~= self.last_touch then
            if self.moving then
                sound(DATA, "ZgBAbQBDPxReASQqRoCBOv2Gtz5qbMS+QAAEUDhAMC8jUGFb")
                self.road:expand(self.touch)
            else
                -- Did not detect the move
                self:new_move(self.touch,Red,Green,Blue)
            end
            self.last_touch = self.touch
            -- check for added chars
            for i,person in ipairs(self.people) do
                if person ~= self.people[self.driver] and not person.with_us then
                    local hitnew  = person.position:dist(self.touch) <33
                    if hitnew then
                        person.with_us = true
                        table.insert(self.fireworks, Fireworks(
                            person.position.x,
                            person.position.y,
                            Red,Green,Blue
                        ))
                    end
                end
            end
        end
    end


end

function World:new_move(touch,R,G,B)
    self.moving = true
    self.road:add(touch,R,G,B,255)
    self.road.person = self.people[self.driver]
    self.road.house  = self.houses[self.destiny]
    sound(DATA, "ZgBATABZHWRAO3oE2fqgvmtJlT4+uRg/XAAkbzxAXTFpC0gV")
end

function World:drawWin()
    noTint()
    background(183, 185, 189, 255)
    self.frame = self.frame + 0.1
    if self.frame>=33 then
        score = score - self.total_frames/100
        if highscore<score then
            saveLocalData("highscore",score)
            highscore = score
        end
        -- next level!
        level = level + 1
        self:init(4+(level*2))
        return
    end
    pushStyle()
    font("Futura-CondensedExtraBold")
    fontSize(133)
    pushMatrix()

    fill(math.random(66,255),255,math.random(66,255),255)
    translate(WIDTH/2+3,HEIGHT/2+66)
    rotate(math.random(-6,6))
    text("WINNER ")
    fill(math.random(66,255),255,math.random(66,255),255)
    popMatrix()
    fontSize(33)
    text("You totally save the tiny world inside us from crazy!. xixgames.com ",WIDTH/2,(HEIGHT/2)-66)
    text("Score:"..(score),WIDTH/2,(HEIGHT/2) - 166)
    if highscore<(score) then
        text("Congrats!!, you did a highscore!!"..score,WIDTH/2,(HEIGHT/2) - 190)
        saveLocalData("highscore",score)
    end
    text("Are you ready for level "..(level+1).."?",WIDTH/2,(HEIGHT/2) - 222)
    popStyle()
end


function World:drawGameOver()
    noTint()
    background(Red,Green,Blue,math.random(255))
    self.frame = self.frame + 0.1
    if self.frame>=6 then
        score = 0
        level = 1
        self:init(6)
    end

    pushStyle()
    font("ArialRoundedMTBold")
    fontSize(166)
    pushMatrix()
    fill(math.random(1,Red), math.random(Green), math.random(Blue),255)

    translate(WIDTH/2,HEIGHT/2)

    text("TRY AGAIN")

    popMatrix()
    popStyle()
end

function World:draw()
    if self.state == WORLD_BREAK then
        self:drawGameOver()
        return
    end
    if self.state == WORLD_SAVED then
        self:drawWin()
        return
    end
    self:update()
    background(0, 0, 0, 0)
    self.stars:draw()
    if self.state == WORLD_START or self.state==WORLD_WAIT then
        self.road:draw()
        for i,house in ipairs(self.houses) do
            house:draw(i==self.destiny,Red,Green,Blue)
        end

        for i,person in ipairs(self.people) do
         person:draw(i==self.driver,Red,Green,Blue)
         if i==self.driver and self.road.state==ROAD_RUN then

            for j,other in ipairs(self.people) do
                if person ~= other and other.with_us and other.friend==nil then

                    local contact = person.position:dist(other.position) <33
                    if contact then
                        other.friend = person
                        table.insert(self.fireworks, Fireworks(
                            person.position.x,
                            person.position.y,
                            Red,Green,Blue
                        ))
                        sound(DATA, "ZgFAQgBALV9APnoU48wkvAjhwj4ARU++TAB0fw1pOT84Tgpd")
                        score = score + math.random(666)
                    end

                end
            end
         end
        end
    elseif self.state == WORLD_TRAVEL then
        for i,house in ipairs(self.houses) do
            house:draw(i==self.destiny,Red,Green,Blue)
        end
        for i,alien in ipairs(self.aliens) do
            alien:draw()
            if alien.state == ALIEN_DEAD then
                table.insert(self.fireworks, Fireworks(
                    alien.position.x,
                    alien.position.y,
                    alien.R,alien.G,alien.B
                ))
                table.remove(self.aliens,i)
            end
        end
        for i,asteroid in ipairs(self.asteroids) do
            asteroid:draw()
            if asteroid.state == ASTEROID_DEAD then
                table.insert(self.fireworks, Fireworks(
                    asteroid.position.x,
                    asteroid.position.y,
                    asteroid.R,asteroid.G,asteroid.B
                ))
                table.remove(self.asteroids    ,i)
            end
        end
    end

    for i,fw in ipairs(self.fireworks) do
        fw:draw()
        if not fw.active then
            table.remove(self.fireworks, i)
        end
    end
    -- draw tiny square
    --noSmooth()

    stroke(Red,Green,Blue,255)
    fill(Red,Green,Blue,255)
    rect(0, HEIGHT-33, 33, 33)
    font("ArialRoundedMTBold")
    fontSize(33)
    if self.state==WORLD_START and score == 0 then
        text("Guide the chosen one to the Tiny World", 444, HEIGHT-27)
        fontSize(27)
        text("Highscore: "..highscore, 444, HEIGHT-66)
    else
        text("Score: "..score, 333, HEIGHT-27)
    end
    if self.state == WORLD_TRAVEL then
        fontSize(27)
        text("Protect the Tiny World from Aliens and Asteroids", 444, HEIGHT-66)
    end
end

function World:touched(touch)
    if self.state ~= WORLD_TRAVEL then return end
    for i,a in ipairs(self.aliens) do
        if a:touched(touch) then
            score = score + math.random(666)
            self.aliens_touched = self.aliens_touched + 1
            return
        end
    end
    for i,a in ipairs(self.asteroids) do
        if a:touched(touch) then
            score = score + math.random(777)
            self.asteroids_touched = self.asteroids_touched + 1
            return
        end
    end
end