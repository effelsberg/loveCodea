
--# Main
-- Orbital
-- by Spirikoi
displayMode(FULLSCREEN)
supportedOrientations(PORTRAIT_ANY)

function setup()

    balls = {}
    touches = {}
    effects = {}
    messages = {}

    physics.gravity(0,0)
    grav = 0.001
    coef = 2
    rest = 0.8
    v0 = 2000

    bottom = 100

    pos0 = vec2(WIDTH / 2, 0)
    cursor = nil

    ballLives = 5

    score = 0
    bestScores = {}
    combo = 0

    for i=1,10 do
        local a = readProjectData("best"..i)
        if a then
            table.insert(bestScores,a)
        end
    end

    borders = {}
    borders["left"] = physics.body(EDGE,vec2(0,0),vec2(0,HEIGHT))
    borders["right"] = physics.body(EDGE,vec2(WIDTH,0),vec2(WIDTH,HEIGHT))
    borders["up"] = physics.body(EDGE,vec2(0,HEIGHT),vec2(WIDTH,HEIGHT))
    borders["down"] = physics.body(EDGE,vec2(0,0),vec2(WIDTH,0))

    for i,v in pairs(borders) do
        local info = {type = "border"}
        v.info = info
    end
end

function touched(touch)
    touches[touch.id] = touch
    touchAction()
end

function resetTouch()
    touches = {}
    cursor = nil
end

function touchAction()
    for i,v in pairs(touches) do
        if v.state == BEGAN then
            if cursor == nil then
                cursor = i
            end
        elseif v.state == MOVING then

        else
            -- Launch Rocket
            if v.id == cursor then
                if rocket == nil then
                    rocket = Rocket(pos0.x,pos0.y,v0 * unit(vec2(v.x, v.y) - pos0))
                end
                cursor = nil
            end

            -- remove touch
            touches[i] = nil
        end
    end
end

function scoring()
    if combo > 1 then
        message("Score",{"Combo x"..combo,combo^2 .." points"},100)
    end
    score = score + combo^2
    combo = 0
end

function collide(contact)
    if contact.state == BEGAN then
        local a = {contact.bodyA.info.type,contact.bodyB.info.type}
        if table.concat(a) == "ballrocket" then
            balls[contact.bodyA.info.id]:damage()
        elseif table.concat(a) == "rocketball" then
            balls[contact.bodyB.info.id]:damage()
        end
    end
end

function draw()

    noSmooth()
    textMode(CENTER)
    touchAction()
    background(0, 0, 0, 255)
    strokeWidth(0)
    if rocket then
        rocket:draw()
    end

    for i,v in pairs(balls) do
        v:draw()
    end


    for k,v in pairs(balls) do
        if v.count <= 0 then
            table.insert(effects,Explosion(v.body.x,v.body.y,v.body.radius))
            v.body:destroy()
            balls[k] = nil

            for _,w in pairs(balls) do

            end

            combo = combo + 1 -- increase combo
        end
    end

    -- Effects
    for k,v in pairs(effects) do
        if v.on then
            v:draw()
        else
            table.remove(effects,k)
        end
    end

    -- messages
    for k,v in pairs(messages) do
        if v.on then
            v:draw()
            break
        else
            table.remove(messages,k)
        end
    end

    -- destroy rocket
    if rocket then
        if rocket.body.y - rocket.body.radius < bottom and rocket.body.linearVelocity.y < 0 then
            -- end the game
            rocket.body:destroy()
            rocket = nil

            for i,v in pairs(balls) do
                table.insert(effects,Explosion(v.body.x,v.body.y,v.body.radius))
                v.body:destroy()
            end
            balls = {}

            scoring()
            table.insert(bestScores,score)

            table.sort(bestScores, function (a,b) return tonumber(a)>tonumber(b) end)

            local temp = {"Your Score : "..score,"","Best Scores"}
            for k,v in pairs(bestScores) do
                if k > 10 then
                    break
                end
                table.insert(temp,v)
            end

            message("Game Over",temp,200)
            for i=1,#bestScores do
                saveProjectData("best"..i,bestScores[i])
            end
            score = 0
        end
    end

    -- draw bottom
    smooth()
    stroke(255, 255, 255, 255)
    strokeWidth(5)
    line(0,bottom,WIDTH,bottom)

    -- draw laser
    if cursor then
        local cur = 2000*unit(vec2(touches[cursor].x, touches[cursor].y) - pos0) + pos0
        if rocket then
            stroke(255, 134, 0, 255)
        else
            stroke(255, 0, 0, 255)
        end
        strokeWidth(4)
        lineCapMode(SQUARE)
        line(pos0.x, pos0.y, cur.x, cur.y)
    end

    -- Score
    fontSize(30)
    textAlign(CENTER)
    fill(255, 255, 255, 255)
    text(score,50,70)

end

Ball = class()

function Ball:init(x,y,r,id)
    self.body = physics.body(CIRCLE,r)
    self.body.type = STATIC
    self.body.x = x
    self.body.y = y
    self.body.linearVelocity = vec2(0,0)
    self.body.restitution = 0
    self.body.friction = 0

    self.radius = 15

    repeat
        self.r = math.random(0,255)
        self.g = math.random(0,255)
        self.b = math.random(0,255)
    until self.r < 230 and self.g < 230 and self.b < 230

    self.count = ballLives
    local info = {type = "ball", id = id}
    self.body.info = info

    -- Add score and reset combo
    scoring()

    physics.pause()
end

function Ball:draw()
    if self.radius < self.body.radius then
        self.radius = self.radius + self.body.radius/15
        if self.radius > self.body.radius then
            self.radius = self.body.radius
        end
    end

    strokeWidth(self.radius/30 + 3)
    stroke(self.r,self.g,self.b,255)
    fill(0, 0, 0, 0)
    ellipse(self.body.x,self.body.y,self.radius*2 + 2)
    textAlign(CENTER)
    textMode(CENTER)
    fontSize(self.radius * 1.5)
    fill(self.r,self.g,self.b,255)
    text(self.count,self.body.x,self.body.y)
end

function Ball:damage()
    self.count = self.count - 1
end

Message = class()

function Message:init(title,str,time)
    self.w = 400
    self.h = 40 * (#str + 1)
    self.title = title
    self.str = str
    if time then
        self.time = time
    else
        self.time = 100
    end
    self.alpha = 0
    self.on = true
end

function Message:draw()
    if self.time > 0 and self.alpha < 255 then
        self.alpha = self.alpha + 15
    elseif self.time > 0 then
        self.time = self.time - 1
    elseif self.alpha > 0 then
        self.alpha = self.alpha - 15
    else
        self.on = false
    end
    strokeWidth(3)
    stroke(255, 255, 255, self.alpha)
    fill(0, 0, 0, self.alpha/2)
    rectMode(CENTER)
    rect(WIDTH/2,HEIGHT/2,self.w,self.h)

    -- Title
    if self.title then
        textAlign(LEFT)
        textMode(CORNER)
        fontSize(30)
        fill(255, 255, 255, self.alpha)
        text(self.title,(WIDTH - self.w)/2,(HEIGHT + self.h)/2)
    end

    -- text
    textAlign(CENTER)
    textMode(CENTER)
    fontSize(30)
    for i,v in ipairs(self.str) do
        text(v,(WIDTH)/2,(HEIGHT + self.h)/2 - 40 * i)
    end
end


Rocket = class()

function Rocket:init(x,y,vec)
    self.body = physics.body(CIRCLE,15)
    self.body.x = x
    self.body.y = y
    self.body.linearVelocity = vec
    self.body.restitution = 0.8
    self.body.friction = 0
    self.body.density = 1
    self.body.bullet = true
    local info = {type = "rocket"}
    self.body.info = info

    self.passed = 0

    physics.resume()
end

function Rocket:draw()
    strokeWidth(0)
    fill(255, 255, 255, 255)
    ellipse(self.body.x,self.body.y,self.body.radius*2)
    self:forces()
end

function Rocket:forces()
    local vel = self.body.linearVelocity
    if math.sqrt(vel:dot(vel)) < 50 then
        self:morph()
    else
        -- Slowing rocket
        self.body:applyForce(- 30 * (1 + 1/math.sqrt(vel:dot(vel))) * unit(vel))

        -- Apply gravity
        local s1 = {x=self.body.x, y=self.body.y}
        for k,v in pairs(balls) do
            local s2 = {x=v.body.x, y=v.body.y, r=v.body.radius}
            local vit = math.sqrt(vel:dot(vel))/2000
            self.body:applyForce(vit * grav * s2.r^coef * unit(vec2(s2.x - s1.x, s2.y - s1.y)))
        end
    end
end

function Rocket:morph()
    -- Get the closest object
    table.insert(balls,Ball(self.body.x,self.body.y,self:distance(),#balls + 1))
    self:destroy()
end

function Rocket:destroy()
    self.body:destroy()
    rocket = nil
end

function Rocket:distance()
    local x, y = self.body.x, self.body.y
    local list = {x,y - bottom,WIDTH - x,HEIGHT - y}
    for i,v in pairs(balls) do
        table.insert(list,math.sqrt((x-v.body.x)^2 + (y-v.body.y)^2)-v.body.radius)
    end
    table.sort(list)
    return list[1]
end

function Rocket:collide(contact)
    if contact.state == BEGAN then

    elseif contact.state == MOVING then

    elseif contact.state == ENDED then

    end
end

Explosion = class()

function Explosion:init(x,y,r)
    self.x = x
    self.y = y
    self.r = r
    self.c = 0
    self.g = 10 * math.sqrt(r)
    self.on = true
    self.impact = {}
end

function Explosion:draw()
    strokeWidth(10  * (1 - self.c/self.g))
    stroke(255, 255, 255, 255 * (1 - self.c/self.g))
    fill(0, 0, 0, 0)
    ellipse(self.x,self.y,(self.r + self.c)*2)
    if self.c < self.g then
        self.c = self.c + 10
        for k,v in pairs(balls) do
            norm = math.sqrt((self.x - v.body.x)^2 + (self.y - v.body.y)^2)
            a = v.body.radius + self.r + self.c
            if norm < a and a < norm + 20 and self.impact[k] == nil then
                self.impact[k] = true
                v:damage()
            end
        end
    else
        self.on = false
    end
end

function unit(vect)
    local norm = vect:dot(vect)
    if norm == 0 then
        return vec2(0,0)
    else
        return vect/math.sqrt(norm)
    end
end

function message(title,lines,time)
    table.insert(messages,Message(title,lines,time))
end