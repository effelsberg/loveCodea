Person = class()
-- Person class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
function Person:init(pos)
    self.position = pos
    self.with_us  = false
    self.friend   = nil 
end

function Person:draw(lost,R,G,B)
    if lost then
        tint(R,G,B,255)
    end
    if self.friend ~= nil then
        self.position.x = self.friend.position.x+math.random(-6,6)
        self.position.y = self.friend.position.y+math.random(-6,6)
    end
    sprite("juaxix:juax",self.position.x, self.position.y)
   
    noTint()
end

function Person:touched(touch)
    
end
