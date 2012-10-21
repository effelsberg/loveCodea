VRobotSlider = class()

function VRobotSlider:init(x, y)
    self.frame = Frame(x - 25, y - 640, x + 35, y + 210)
    self.previousY = 0
    self.pots = {}
    for i = 1, 21 do
        self.pots[i] = Frame(self.frame.left + 2, 
        self.frame.top - (i) * 40,
        self.frame.right - 2, self.frame.top - (i) * 40 + 40)
    end
    self.selected = 0
end

function VRobotSlider:draw(robots)
    pushStyle()
    textMode(CENTER)
    fontSize(32)
        fill(0, 0, 0, 255)
        stroke(255, 255, 255, 155)
        strokeWidth(1)
        self.frame:draw()
        fontSize(32)
        for i = 1, 21 do
            if i == 1 then
                fill(92, 92, 92, 183)
                text("?", self.pots[1]:midX(), self.pots[1]:midY())
            end
            if i > 1 then
                noStroke()
                --self.pots[i]:draw()
                pushMatrix()
                translate(self.pots[i]:midX(), 
                self.pots[i]:midY())
                scale(0.5)
                if i > 1 then
                    robots[i - 1]:drawBase()
                end
                popMatrix()
            end
        end
   popStyle()
end

function VRobotSlider:touched(touch)
    if self.frame:touched(touch) then
        for i = 1, 21 do
            self.selected = 0
            if self.pots[i]:touched(touch) then
                strokeWidth(3)
                noFill()
                stroke(106, 130, 155, 255)
                self.pots[i]:draw()
                self.selected = i - 1
                print(i, self.selected, self.pots[1].left)
                return true
            end
        end
    end
    return false
end
