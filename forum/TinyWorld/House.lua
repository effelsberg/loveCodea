House = class()
-- House class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
function House:init(pos)
    -- you can accept and set parameters here
    self.position = pos
    self.state    = WORLD_START
    self.time     = 0
    self.frame    = 0
end

function House:draw(isDestiny,R,G,B)
    if self.state == WORLD_WAIT then
        self.position.x = self.position.x - math.sin(self.position.x)*self.time*math.pi
        self.time = self.time + 1/3
        if (self.position.x<0 or self.position.x>WIDTH) then
            self.state = WORLD_TRAVEL
            self.position.x = 0
            tiny_world:travelStart()
        end
    elseif self.state == WORLD_TRAVEL then
        self.position.x = self.position.x + 0.8
        self.position.y = HEIGHT/2 - math.sin(self.position.x)*math.pi/3
        if self.position.x>WIDTH+10 then
            tiny_world.frame = 6
            tiny_world.state = WORLD_SAVED
            self.state = 0
            return
        end
        self.frame = (self.frame+1)%128
        if self.frame%100==0 then
            sound(DATA, "ZgBADgBAP1AaOWlEvl09O2DUrDwylEs/QQAhVUVyQEBIIQgn")
        end
    end
    
    -- tiny world with a colored house
    
    if self.state == WORLD_TRAVEL then
        sprite("juaxix:tiny_world",self.position.x,self.position.y,128,146)
        
    elseif self.state == WORLD_START or self.state == WORLD_WAIT then
        sprite("juaxix:tiny_world",self.position.x,self.position.y)
        if isDestiny then
            tint(R,G,B, 128)
        end
    
        sprite("juaxix:house",self.position.x,self.position.y)
        font("Arial-BoldMT")
        fontSize(12)
        fill(255, 255, 255, 255)
        noTint()
        text("House ,level: "..level,self.position.x-6,self.position.y-27)
    end
end

function House:touched(touch)
    -- Codea does not automatically call this method
end
