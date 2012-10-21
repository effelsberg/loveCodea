TextBox = class()

-- TextBox 
-- ver. 1.0
-- a control for basic string editing
-- ====================

function TextBox:init(x, y, w, s)
    self.x = x
    self.y = y
    self.w = w
    self.text = s
    self.blink = ElapsedTime
    self.blinkstate = true
end

function TextBox:draw()
    local x, w, h
    pushStyle()
    pushMatrix()
    textMode(CENTER)
    fontSize(18)
    rectMode(CORNER)
    strokeWidth(1)
    stroke(0, 0, 0, 255)
    fill(30, 30, 30, 180)
    translate(self.x, self.y)
    rect(0, 0, self.w, 24)
    stroke(255, 255, 255, 255)
    --noFill()
    rect(2, 2, self.w - 4, 20)
    fill(255, 255, 255, 255)
    text(self.text, self.w / 2, 12)
    w, h = textSize(self.text)
    if self.blink < ElapsedTime - 0.3 then
        self.blink = ElapsedTime
        self.blinkstate = not self.blinkstate
    end
    if self.blinkstate then
        strokeWidth(2)
        stroke(255, 255, 255, 255)
        
        x = self.w / 2 + w / 2 + 2
        line(x, 3, x, 21)
    end
    popMatrix()
    popStyle()
end

function TextBox:touched(touch)
    -- move cursor? For the moment, touching a textbox has no function
end

function TextBox:acceptKey(k)
    if k ~= nil then
        if string.byte(k) == nil then
            if string.len(self.text) > 0 then
                self.text = string.sub(self.text, 
                1, string.len(self.text) - 1)
            end
        end
        self.text = self.text..k
    end
end
