Frame = class()

-- Frame 
-- ver. 1.0
-- a simple rectangle for holding controls.
-- ====================

function Frame:init(left, bottom, right, top)
    self.left = left
    self.right = right
    self.bottom = bottom
    self.top = top
end

function Frame:inset(dx, dy)
    self.left = self.left + dx
    self.right = self.right - dx
    self.bottom = self.bottom + dy
    self.top = self.top - dy
end

function Frame:offset(dx, dy)
    self.left = self.left + dx
    self.right = self.right + dx
    self.bottom = self.bottom + dy
    self.top = self.top + dy
end
    
function Frame:draw()
    pushStyle()
    rectMode(CORNERS)
    rect(self.left, self.bottom, self.right, self.top)
    popStyle()
end

function Frame:roundRect(r)
    pushStyle()
    insetPos = vec2(self.left + r,self.bottom + r)
    insetSize = vec2(self:width() - 2 * r,self:height() - 2 * r)

    rectMode(CORNER)
    rect(insetPos.x, insetPos.y, insetSize.x, insetSize.y)

    if r > 0 then
        smooth()
        lineCapMode(ROUND)
        strokeWidth(r * 2)

        line(insetPos.x, insetPos.y, 
             insetPos.x + insetSize.x, insetPos.y)
        line(insetPos.x, insetPos.y,
             insetPos.x, insetPos.y + insetSize.y)
        line(insetPos.x, insetPos.y + insetSize.y,
             insetPos.x + insetSize.x, insetPos.y + insetSize.y)
        line(insetPos.x + insetSize.x, insetPos.y,
             insetPos.x + insetSize.x, insetPos.y + insetSize.y)            
    end
    popStyle()
end

function Frame:gloss(baseclr)
    local i, t, r, g, b, y
    pushStyle()
    if baseclr == nil then baseclr = color(194, 194, 194, 255) end
    fill(baseclr)
    rectMode(CORNERS)
    rect(self.left, self.bottom, self.right, self.top)
    r = baseclr.r
    g = baseclr.g
    b = baseclr.b
    for i = 1 , self:height() / 2 do
        r = r - 1
        g = g - 1
        b = b - 1
        stroke(r, g, b, 255)
        y = (self.bottom + self.top) / 2
        line(self.left, y + i, self.right, y + i)
        line(self.left, y - i, self.right, y - i)
    end
    popStyle()
end

function Frame:shade(base, step)
    pushStyle()
    strokeWidth(1)
    for y = self.bottom, self.top do
        i = self.top - y
        stroke(base - i * step, base - i * step, base - i * step, 255)
        line(self.left, y, self.right, y)
    end
    popStyle()
end

function Frame:touched(touch)
    if touch.x >= self.left and touch.x <= self.right then
        if touch.y >= self.bottom and touch.y <= self.top then
            return true
        end
    end
    return false
end

function Frame:ptIn(x, y)
    if x >= self.left and x <= self.right then
        if y >= self.bottom and y <= self.top then
            return true
        end
    end
    return false
end

function Frame:overlaps(f)
    if self.left > f.right or self.right < f.left or
    self.bottom > f.top or self.top < f.bottom then
        return false
    else
        return true
    end
end

function Frame:width()
    return self.right - self.left
end

function Frame:height()
    return self.top - self.bottom
end

function Frame:midX()
    return (self.left + self.right) / 2
end
    
function Frame:midY()
    return (self.bottom + self.top) / 2
end
