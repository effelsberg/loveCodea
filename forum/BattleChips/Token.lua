Token = class()

function Token:init(code, x, y, d)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.divide = d
    self.code = code
end

function Token:draw()  
    pushStyle()
    tint(self.code.color)
    --tint(98, 130, 152, 255)
    sprite(chipImg, self.x, self.y, 
    self.x + 140, self.y + 32)
    strokeWidth(2)
    noFill()
    stroke(152, 152, 152, 255)
    rect(self.x, self.y, self.x + 140, self.y + 32)
    fill(154, 154, 154, 255)
    noStroke()
    rect(self.x, self.y, self.x + 8, self.y - 8)
    rect(self.x + 34, self.y, self.x + 42, self.y - 8)
    rect(self.x + 66, self.y, self.x + 74, self.y - 8)
    rect(self.x + 98, self.y, self.x + 106, self.y - 8)
    rect(self.x + 132, self.y, self.x + 140, self.y - 8)
    rect(self.x, self.y + 32, self.x + 8, self.y + 38)
    rect(self.x + 34, self.y + 32, self.x + 42, self.y + 38)
    rect(self.x + 66, self.y + 32, self.x + 74, self.y + 38)
    rect(self.x + 98, self.y + 32, self.x + 106, self.y + 38)
    rect(self.x + 132, self.y + 32, self.x + 140, self.y + 38)
    
    fill(233, 233, 233, 255)
    fontSize(16)
    if string.len(self.code.long2) > 0 then
        text(self.code.long2, self.x + 8, self.y + 2)
        text(self.code.long1, self.x + 8, self.y + 14)
    else
        text(self.code.long1, self.x + 8, self.y + 6)
    end
    if self.code.hasValue then
        if self.code.short ~= "P" then
            fill(211, 211, 211, 255)
            ellipse(self.x + 110, self.y + 16, 20)
            ellipse(self.x + 125, self.y + 16, 20)
            rect(self.x + 110, self.y + 6, self.x + 125, self.y + 26)

            fill(127, 127, 127, 219)
            stroke(127, 127, 127, 255)
            strokeWidth(5)
            ellipse(self.x + 87, self.y + 16, 20)
            line(self.x + 90, self.y + 16, self.x + 100, self.y + 16)
        else
            fill(194, 194, 194, 255)
            rect(self.x + 100, self.y + 6, 
            self.x + 135, self.y + 26)
            fill(223, 168, 168, 255)
            --textMode(CENTER)
            text("1", self.x + 130, self.y + 15)
            fill(63, 58, 37, 219)
            stroke(127, 127, 127, 228)
            strokeWidth(5)
            line(self.x + 87, self.y + 30, self.x + 87, self.y + 14)
            line(self.x + 87, self.y + 16, self.x + 102, self.y + 16)
        end
    end
end

function Token:touched(touch)
    if touch.x >= self.x and touch.x <= self.x + 130 and
    touch.y >= self.y and touch.y <= self.y + 30 then
        return true
    end
    return false
end
