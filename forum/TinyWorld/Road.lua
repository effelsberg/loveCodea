Road = class()

-- Road class 
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!

ROAD_EMPTY = 0
ROAD_DRAW  = 1
ROAD_RUN   = 2
ROAD_END   = 3
function Road:init()
    -- you can accept and set parameters here
    self.touches = {}
    self.colours = {}
    self.person  = nil
    self.house   = nil
    self.time    = 0
    self.state   = ROAD_EMPTY
    self.distance= 0
end

function Road:add(t,Red,Green,Blue,Alpha)
    if self.state == ROAD_EMPTY or self.state== ROAD_DRAW then
        self.touches = {}
        table.insert(self.touches, {t})
        table.insert(self.colours, color(Red,Green,Blue,Alpha))
        self.state   = ROAD_DRAW
    end
end

function Road:expand(t)
    if self.state == ROAD_DRAW then
        table.insert(self.touches[#self.touches],t)
    end
end

function Road:draw()
    if self.state == ROAD_RUN then 
        self:guide_person_to_house()
    end
    if self.state ~= ROAD_DRAW then return end
    -- default seems to be 0
    strokeWidth(8)
    lineCapMode(ROUND)
    local last
    if #self.touches > 0 then
        for i,v in ipairs(self.touches) do
            last = v[1]
            stroke(self.colours[i])
            for j,w in ipairs(v) do
                line(last.x,last.y,w.x,w.y)
                last = w
            end
        end
    end
end

function Road:guide_person_to_house()
    if self.time == 0 then
        self.time = 6
    end
    self.time = self.time - (1.6*(#self.touches[1]))
    if self.time>0 then
       -- print(self.time)
        return
    else
        self.time = 6
    end
    for i,v in ipairs(self.touches) do
        for j,w in ipairs(v) do
            --if self.index == j then
                self.person.position.x = w.x
                self.person.position.y = w.y
                table.remove(v,j)
                if #v == 0 then
                    sound(DATA, "ZgBARwA+QSJAVCNeJe5KP9dSvj6N+mK/UQAif2BAQERFVSsw")
                    self.state = ROAD_END
                else
                    sound(DATA, "ZgBAOQA/CnI3AzlERinpPDHybz5oQIU+TQBYVj9zQgpbLQo3")
                end
                
                return
            --end
        end
        
    end
end

function Road:length()
    local total = 0
    for i,v in ipairs(self.touches) do
        total = total + #v
    end      
    return total
end