Socket = class()

function Socket:init(code, x, y)
    self.code = code
    self.x = x
    self.y = y
    self.frame = Frame(x, y, x + 145, y + 30)
    self.value = 1
end

function Socket:draw()
    pushStyle()
    if self.code == nil then
        fill(16, 16, 16, 255)
        stroke(189, 189, 189, 255)
        strokeWidth(2)
        self.frame:draw()
        for i = 0,4 do
            rect(self.frame.left + i * 30, self.frame.bottom + 2, 
            self.frame.left + i * 30, self.frame.bottom + 6)
            rect(self.frame.left + i * 30, self.frame.top - 6 , 
            self.frame.left + i * 30, self.frame.top - 2)
        end
    else
        strokeWidth(3)
        tint(self.code.color)
        sprite(chipImg, self.frame.left, self.frame.bottom, 
        self.frame.right, self.frame.top)
        stroke(152, 130, 130, 255)
        noFill()
        self.frame:draw()
        fontSize(16)
        fill(255, 255, 255, 255)
        if string.len(self.code.long2) > 0 then
            text(self.code.long1, 
            self.frame.left + 10, self.frame.bottom + 13)
            text(self.code.long2, 
            self.frame.left + 10, self.frame.bottom + 2)
        else 
            text(self.code.long1, 
            self.frame.left + 10, self.frame.bottom + 6)
        end
        if self.code.hasValue then
            if self.code.short ~= "P" then
                fill(63, 58, 37, 219)
                stroke(127, 127, 127, 211)
                strokeWidth(5)
                ellipse(self.x + 87, self.y + 16, 20)
                line(self.x + 90, self.y + 16, self.x + 145, 
                self.y + 16)
                noStroke()
                fill(231, 227, 227, 255)
                ellipse(self.x + 110, self.y + 16, 20)
                ellipse(self.x + 125, self.y + 16, 20)
                rect(self.x + 110, self.y + 6, 
                self.x + 125, self.y + 26)
                fill(47, 47, 47, 255)
                textMode(CENTER)
                text(self.value, self.x + 120, self.y + 15)
                
            else
                fill(233, 233, 233, 255)
                rect(self.x + 100, self.y + 6, 
                self.x + 135, self.y + 26)
                fill(47, 47, 47, 255)
                textMode(CENTER)
                text(self.value, self.x + 120, self.y + 15)
                fill(63, 58, 37, 219)
                stroke(127, 127, 127, 229)
                strokeWidth(5)
                line(self.x + 87, self.y + 30, self.x + 87, 
                self.y + 14)
                line(self.x + 87, self.y + 16, self.x + 102, 
                self.y + 16)
            end
        end
    end
    popStyle()
end

function Socket:touched(touch)
    if self.frame:touched(touch) then
        return true
    end
    return false
end
