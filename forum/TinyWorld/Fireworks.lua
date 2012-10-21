Fireworks = class()
-- Fireworks class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!
function Fireworks:init(ox,oy,R,G,B)
    self.debris_list = {}
    self.clumps= 1
    self.points = 66
    self.clump_factor = self.clumps  / self.points
    self.maxvel= 6
    self.maxcycles=66
    self.gdiv = 5
    self.active = true
    self.ox = ox
    self.oy = oy
    self:new(ox,oy)
    self.color = color(R,G,B,255)
end

function Fireworks:new(ox,oy)
    for i= 1, self.points do
        self.debris_list[i]=self:add_debris(ox,oy)
    end
end

function Fireworks:add_debris(ox,oy)
    local vel   = math.random() * self.maxvel
    local angle = math.random() * 2 * math.pi
    return {x = ox or 0, y = oy or 0, dx = vel *math.cos(angle), 
    dy=vel*math.sin(angle),active=true, cycles=math.random(1,self.maxcycles)}
end



-- This function gets called once every frame
function Fireworks:draw()
    
    self.clump_factor=self.clumps/self.points
    strokeWidth(4)
    lineCapMode(ROUND)
   -- background(10,10,20)
    local done = true
    for i, debris in ipairs(self.debris_list) do
        stroke(self.color.r, self.color.g, self.color.b,
        --stroke (255*math.random(),255*math.random(),255*math.random(), 
            255 - (debris.cycles / self.maxcycles) * 255)
        if debris.active then
            done=false
            line(debris.x,debris.y, debris.x, debris.y)
            debris.x = debris.x + debris.dx
            debris.y = debris.y + debris.dy
            debris.dy = debris.dy + Gravity.y / self.gdiv
            debris.cycles = debris.cycles + 1
            if debris.cycles > self.maxcycles
                or math.abs(debris.x) > WIDTH -- either side
                or debris.y < -HEIGHT -- bottom
            then
                debris.active = false
            end
        end
    end
    if done then
        self.active = false
    end
end