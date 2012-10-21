Star = class()
-- Star class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
function Star:init(pos, vel, angl)
    self.position = pos
    self.velocity = vel
    self.angle    = angl
end

function Star:update()
    self.position.x = self.position.x - self.velocity
end

function Star:draw()
    p = self.position
    pushMatrix()
    if self.angle ~= 0 then
        translate(WIDTH/3,-HEIGHT/3)
    end
    rotate(self.angle)
    line(p.x-self.velocity,p.y,p.x,p.y)
    popMatrix()
end

function Star:shouldCull()
    -- Check if off the left of the screen
    if (self.position.x - self.velocity) < 0 then
        return true
    end 

    return false
end

----------------------------------------------
-- All stars
----------------------------------------------
Stars = class()

function Stars:init()
    self.minSpeed  = 6
    self.speed     = 23
    self.spawnRate = 1
    self.stars     = {}
    self.angle     = 45
end

function Stars:updateAndCull()
    toCull = {}
    for i,star in ipairs(self.stars) do
        if star:shouldCull() then
            table.remove( self.stars, i )
        else
            star:update()
        end
    end


end

function Stars:update()
    -- Create spawnRate lines per update
    for i = 1,self.spawnRate do
        -- Generate random spawn location
        vel = math.random(self.minSpeed, self.speed)
        spawn = vec2( WIDTH - vel, math.random(HEIGHT) )
        table.insert(self.stars, Star(spawn, vel, self.angle))
    end

    -- Update and cull offscreen lines
    self:updateAndCull()
end

function Stars:draw()
    pushMatrix()
    self:update()
    pushStyle()

   -- noSmooth()
   -- stroke(179, 153, 180, 173)
    --strokeWidth(2)
   -- lineCapMode(SQUARE)
 
    for i,star in ipairs(self.stars) do
        star:draw()
    end

    popStyle()
    popMatrix()
end
