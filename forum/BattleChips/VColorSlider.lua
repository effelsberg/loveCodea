VColorSlider = class()

function VColorSlider:init(x, y)
    self.frame = Frame(x - 30, y - 328, x + 60, y + 56)
    self.previousY = 0
    self.pots = {}
    for i = 0, 15 do
        self.pots[i + 1] = Frame(self.frame.left, 
        self.frame.top - i * 24 - 24,
        self.frame.right, self.frame.top - i * 24)
    end
    self.selected = 0
end

function VColorSlider:draw()
    pushStyle()
    fill(143, 158, 166, 255)
    stroke(25, 25, 25, 255)
    strokeWidth(1)
    self.frame:draw()
    for i = 1, 16 do
        fill(colors[i])
        self.pots[i]:draw()
    end
    popStyle()
end

function VColorSlider:touched(touch)
    if self.frame:touched(touch) then
        for i = 1, 16 do
            self.selected = 0
            if self.pots[i]:touched(touch) then
                strokeWidth(3)
                stroke(106, 130, 155, 255)
                self.selected = i
                fill(colors[i])
                self.pots[i]:draw()
                return true
            end
        end
    end
    return false
end
