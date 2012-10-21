Divider = class()

function Divider:init(name, l, t, r, b)
    self.name = name
    self.frame = Frame(l, t, r, b)
end

function Divider:draw()
    pushStyle()
    strokeWidth(1)
    stroke(247, 247, 247, 255)
    tint(143, 203, 223, 255)
    sprite(chipImg, self.frame.left, self.frame.bottom, 
    self.frame.right, self.frame.top)
    fill(255, 255, 255, 255)
    text(self.name, self.frame.left + 10, self.frame.bottom + 5)
    noFill()
    self.frame:draw()
    popStyle()
end

function Divider:touched(touch)
    return self.frame:touched(touch)
end
