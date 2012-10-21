-- Project: Bezier
-- Author : Codeslinger
-- License: Public Domain
--
-- The main purpose is to visualize the construction of Bezier Curves,
-- inspired by this site:
--   http://www.jasondavies.com/animated-bezier/
-- Click circle to create a new node.
-- Drag a node to the X to delete it.

BEZIER_STEP = 0.01
STARTING_DOTS = 4
dots = {}
p = 0
touches = {}
touched_dots = {}

function setup()
    --table.insert(dots, Dot(50, 50))
    --table.insert(dots, Dot(200, 400))
    --table.insert(dots, Dot(400, 400))
    --table.insert(dots, Dot(500, 300))
    for i = 1, STARTING_DOTS do
        table.insert(dots, Dot(math.random(500), math.random(500)))
    end
    noSmooth()
    iparameter("speed", 1, 10, 10)
end

function draw()
    p = p + (speed / 1000)
    if p > 1 then p = 0 end
    background(255, 255, 230, 255)
    local curve = {}
    for i,d in ipairs(dots) do
        table.insert(curve, d.x)
        table.insert(curve, d.y)
    end
    Bezier(curve, p)
    fill(0, 255, 0)
    ellipse(WIDTH - 20, HEIGHT - 20, 40, 40)
    stroke(255, 0, 0)
    line(WIDTH, 0, WIDTH - 40, 40)
    line(WIDTH, 40, WIDTH - 40, 0)
end

function touched(touch)
    if touch.state == ENDED then
        touches[touch.id] = nil
        touched_dots[touch.id] = nil
        if touch.x > WIDTH - 40 and touch.y > HEIGHT - 40 then
            table.insert(dots, Dot(math.random(500), math.random(500)))
        end
    else
        touches[touch.id] = touch
        local td = touched_dots[touch.id]
        if td == nil then
            touched_dots[touch.id] = FindDot(touch.x, touch.y)
        else
            td.x = touch.x
            td.y = touch.y
            if td:Contains(WIDTH - 20, 20) then
                for i,d in ipairs(dots) do
                    if d == td then
                        table.remove(dots, i)
                        break
                    end
                end
            end
        end
    end
end

function FindDot(x, y)
    local dot = nil
    for i,d in ipairs(dots) do
        if d:Contains(x, y) then dot = d end
    end
    return dot
end

function Bezier(xy_list, p)
    DrawBezierOverlay(xy_list, p)
    DrawBezier(xy_list, p)
end

function DrawBezier(xy_list, p)
    if #xy_list == 0 then return end
    stroke(0, 0, 0)
    strokeWidth(3)
    local x0, y0
    for i = 0, p, BEZIER_STEP do
        local x, y = ReduceChain(xy_list, i)
        if i > 0 then
            line(x0, y0, x, y)
        end
        x0, y0 = x, y
    end
end

function ReduceChain(xy_list, p)
    local n_coords = #xy_list / 2
    while n_coords > 1 do
        xy_list = ReduceChainBy1(xy_list, p)
        n_coords = n_coords - 1
    end
    return xy_list[1], xy_list[2]
end

function DrawBezierOverlay(xy_list, p)
    local n_coords = #xy_list / 2
    local r = 20
    while n_coords > 0 do
        DrawChain(xy_list, r)
        xy_list = ReduceChainBy1(xy_list, p)
        n_coords = n_coords - 1
        r = 10
    end
end

function ReduceChainBy1(xy_list, p)
    local reduced = {}
    local n_coords = #xy_list / 2
    local x0, y0
    for i = 1, n_coords do
        local x = xy_list[i * 2 - 1]
        local y = xy_list[i * 2]
        if i > 1 then
            local xi = x0 + (x - x0) * p
            local yi = y0 + (y - y0) * p
            table.insert(reduced, xi)
            table.insert(reduced, yi)
        end
        x0, y0 = x, y
    end
    return reduced
end

function DrawChain(xy_list, r)
    local n_coords = #xy_list / 2
    local x0
    local y0
    stroke(255, 100, 0)
    strokeWidth(1)
    fill(255, 100, 0)
    if n_coords == 1 then
    fill(100, 100, 100)
    end
    for i = 1, n_coords do
        local x = xy_list[i * 2 - 1]
        local y = xy_list[i * 2]
        if i > 1 then
            line(x0, y0, x, y)
        end
        ellipse(x, y, r)
        x0, y0 = x, y
    end
end



Dot = class()

function Dot:init(x, y)
    self.x = x
    self.y = y
    self.r = 20
end

function Dot:Contains(x, y)
    local dx = x - self.x
    local dy = y - self.y
    return (dx * dx) + (dy * dy) <= (self.r * self.r)
end
