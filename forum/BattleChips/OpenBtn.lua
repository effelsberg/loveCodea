OpenBtn = class()

function OpenBtn:init(t, x, y)
    self.frame = Frame(x, y, x + 100, y + 30)
    self.text = t
    self.selected = false
end

function OpenBtn:draw()
    pushStyle()
    noFill()
    if self.selected then fill(101, 118, 134, 255) end
    stroke(255, 255, 255, 255)
    strokeWidth(1)
    ellipse(self.frame.left, self.frame:midY(), self.frame:height())
    self.frame:draw()
    fill(34, 34, 34, 255)
    noStroke()
    if self.selected then fill(101, 118, 134, 255) end
    self.frame:inset(-2,2)
    self.frame:draw()
    self.frame:inset(2, -2)
    fill(255, 255, 255, 255)
    text(self.text, self.frame.left , self.frame.bottom)
    popStyle()
end

function OpenBtn:touched(touch)
    return self.frame:touched(touch)
end
