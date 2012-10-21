Vslider = class()

function Vslider:init(x, y, v)
    self.frame = Frame(x - 30, y - 200, x + 30, y + 60)
    self.value = v
    self.previousY = 0
end

function Vslider:draw()
    pushStyle()
    fill(143, 158, 166, 255)
    stroke(25, 25, 25, 255)
    strokeWidth(1)
    self.frame:draw()
    fill(231, 227, 227, 255)
    noStroke()
    ellipse(self.frame.left + 20, self.frame.top - 15, 25)
    ellipse(self.frame.right - 20, self.frame.top - 15, 25)
    rect(self.frame.left + 20, self.frame.top - 3, 
    self.frame.right - 20, self.frame.top - 27)
    fill(23, 23, 23, 255)
    textMode(CENTER)
    fontSize(18)
    text(self.value, self.frame.left + 30, self.frame.top - 15)
    strokeWidth(2)
    line(self.frame:midX(), self.frame.bottom + 10,
    self.frame:midX(), self.frame.top - 50)
    stroke(207, 207, 207, 255)
    line(self.frame:midX() + 4, self.frame.bottom + 10,
    self.frame:midX() + 4, self.frame.top - 50)
    line(self.frame:midX() - 4, self.frame.bottom + 10,
    self.frame:midX() - 4, self.frame.top - 50)
    popStyle()
end

function Vslider:touched(touch)
    if self.frame:touched(touch) then
        self.value = math.floor((self.frame.top - 50 - touch.y) / 6)
        if self.value < 1 then self.value = 1 end
        if self.value > 30 then self.value = 30 end
        return true
    end
    return false
end
