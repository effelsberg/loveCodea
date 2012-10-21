Asteroid = class()
-- Asteroid class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
ASTEROID_DEAD = 0
ASTEROID_LIVE = 1
function Asteroid:init(avoidpos)
    self.state = ASTEROID_LIVE
    self.R = math.random(255)
    self.G = math.random(255)
    self.B = math.random(255)
    self.img = AsteroidImg()
    self.angle= 1
    self.position = vec2(math.random(WIDTH),math.random(HEIGHT)) - avoidpos
    self.angle = math.random(360)
    local r = math.random(1,7)
    if r == 1 then
        self.speed  = vec2(1,1)
    elseif r == 2 then
        self.speed  = vec2(1,0)
    elseif r ==3 then
        self.speed  = vec2(0,1)
    elseif r == 5 then
        self.speed  = vec2(-1,-1)
    elseif r == 6 then
        self.speed  = vec2(-1,0)
    else
        self.speed  = vec2(0,-1)   
    end
    self.speed = self.speed * level
end

function Asteroid:update()
    self.angle = self.angle + 1
    if self.angle == 360 then self.angle = 0 end
    self.position = self.position + self.speed
    if self.position.x > WIDTH then 
            self.position.x = 0
        elseif self.position.x < 0 then
            self.position.x = WIDTH
        end
        if self.position.y > HEIGHT then
            self.position.y = 0
        elseif self.position.y < 0 then
            self.position.y = HEIGHT
        end
end



function Asteroid:draw()
    if self.state == ASTEROID_DEAD then return end
    self:update()
    -- check distance with the main tiny world house:
    if self.position:dist(tiny_world.houses[tiny_world.destiny].position)<22 then
        self.state = ASTEROID_DEAD
        tiny_world.frame = 0
        tiny_world.state = WORLD_BREAK
        return
    end
    -- draw
    pushMatrix()
    -- Transform to pos
    translate(self.position.x, self.position.y)
    self.angle = self.angle + 0.4
    rotate(self.angle)
    tint(self.R,self.G,self.B,math.random(130,255))
    sprite(self.img)
    noTint()
    popMatrix()
end

function Asteroid:touched(touch)
    if self.state ~= ASTEROID_DEAD and vec2(touch.x,touch.y):dist(self.position)<30 then
        self.state = ASTEROID_DEAD
        sound(SOUND_EXPLODE, 14589)
        return true
    end
    return false
end
