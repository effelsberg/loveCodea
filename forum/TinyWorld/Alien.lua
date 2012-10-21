Alien = class()
-- Alien class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
ALIEN_DEAD = 0
ALIEN_LIVE = 1

function Alien:init()
    self.position = vec2(WIDTH,math.random(-6,6)+HEIGHT/2)
    self.state = ALIEN_LIVE
    self.speed = math.random(1,level+2)
    self.R = math.random(255)
    self.G = math.random(255)
    self.B = math.random(255)
end



function Alien:draw()
    if self.state == ALIEN_DEAD then return end
    -- check distance with the main tiny world house:
    if self.position:dist(tiny_world.houses[tiny_world.destiny].position)<55 then
        self.state = ALIEN_DEAD
        tiny_world.frame = 0
        tiny_world.state = WORLD_BREAK
        return
    end
    self.position.x = self.position.x - self.speed
    local d = math.sin((self.position.x-0.66)/33)
    if self.position.y <= tiny_world.houses[tiny_world.destiny].position.y then
        d = -d
    end
    self.position.y = self.position.y + d
    pushMatrix()
    pushStyle()
    
    -- Set up basic graphical style
    lineCapMode(ROUND)
    strokeWidth(8)
    stroke(self.R,self.G,self.B, 255)
    smooth()
    noFill()

    -- Transform to pos
    translate(self.position.x, self.position.y)
    rotate(90)
    -- Draw our triangle invader
    -- 60 pixels high, 40 pixels wide
    line( 0, 30, 20, -30 )
    line( 0, 30,-20, -30 )
    line( -20, -30, 20, -30 )

    popMatrix()

    

    popStyle()
end

function Alien:touched(touch)
    if self.state ~= ALIEN_DEAD and vec2(touch.x,touch.y):dist(self.position)<20 then
        self.state = ALIEN_DEAD
        sound(SOUND_EXPLODE, 14589)
        return true
    end
    return false
end
