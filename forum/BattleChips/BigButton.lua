BigButton = class()

function BigButton:init(t, x, y)
    self.text = t
    self.frame = Frame(x, y, x + 140, y + 80)
    self.active = true
end

function BigButton:draw()
    if self.active then
        stroke(255, 255, 255, 255)
    else
        stroke(93, 95, 125, 255)
    end
    strokeWidth(2)
    noFill()
    self.frame:draw()
    if self.active then
        fill(255, 255, 255, 255)
    else
        fill(98, 100, 134, 255)
    end
    fontSize(24)
    textMode(CORNER)
    text(self.text, self.frame.left + 20, self.frame.top - 40)
end

function BigButton:touched(touch)
    return self.frame:touched(touch)
end
