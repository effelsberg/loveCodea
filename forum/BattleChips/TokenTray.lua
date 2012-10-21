TokenTray = class()

function TokenTray:init(x, y)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.frame = Frame(x, y, x + 200, y + 850)
    self.selected = 0
    self.tokens = {}
    self.tokens[1] = Token(codes[1], 30, 0, 1) 
    self.tokens[2] = Token(codes[2], 30, 0, 1)
    self.tokens[3] = Token(codes[3], 30, 0, 1)
    self.tokens[4] = Token(codes[4], 30, 0, 1)
    self.tokens[5] = Token(codes[5], 30, 0, 3)
    self.tokens[6] = Token(codes[6], 30, 0, 2)
    self.tokens[7] = Token(codes[7], 30, 0, 2)
    self.tokens[8] = Token(codes[8], 30, 0, 2)
    self.tokens[9] = Token(codes[9], 30, 0, 2)
    self.tokens[10] = Token(codes[10], 30, 0, 2)
    self.tokens[11] = Token(codes[11], 30, 0, 4)
    self.tokens[12] = Token(codes[12], 30, 0, 4)
    self.tokens[13] = Token(codes[13], 30, 0, 4)
    self.tokens[14] = Token(codes[14], 30, 0, 3)
    self.tokens[15] = Token(codes[15], 30, 0, 3)
    self.tokens[16] = Token(codes[16], 30, 0, 3)
    self.tokens[17] = Token(codes[17], 30, 0, 4)
    self.tokens[18] = Token(codes[18], 30, 0, 4)
    self.tokens[19] = Token(codes[19], 30, 0, 3)
    self.tokens[20] = Token(codes[20], 30, 0, 3)
    self.tokens[21] = Token(codes[21], 30, 0, 3)
    for i = 1, #self.tokens do
        self.tokens[i].y = 2000
    end
    self.dividers = {}
    self.dividers[1] = Divider("Movement", 1, 800, 199, 830)
    self.dividers[2] = Divider("Sensors", 1, 800, 199, 830)
    self.dividers[3] = Divider("Equipment", 1, 800, 199, 830)
    self.dividers[4] = Divider("Control", 1, 800, 199, 830)
    self:selectDivider(1)
end

function TokenTray:selectDivider(i)
    local y
    self.selectedDivider= i
    for i = 1, self.selectedDivider do
        y = self.frame:height() - 1 - i * 30
        self.dividers[i].frame.bottom = y
        self.dividers[i].frame.top = y + 30
    end
    for i = self.selectedDivider + 1, #self.dividers do
        y = (#self.dividers - i) * 30
        self.dividers[i].frame.bottom = y
        self.dividers[i].frame.top = y + 30
    end
    count = 0
    for i = 1, #self.tokens do
        if self.tokens[i].divide == self.selectedDivider then
            count = count + 1
            self.tokens[i].y = 
            self.dividers[self.selectedDivider].frame.bottom
             - count * 70 
        else
            self.tokens[i].y = 2000
        end
    end
end

function TokenTray:draw()
    pushStyle()
    pushMatrix()
    fontSize(18)
    tint(25, 27, 46, 255)
    sprite(boardImg, self.frame.left, self.frame.bottom, 
        self.frame.right, self.frame.top)
    stroke(249, 249, 249, 255)
    noFill()
    strokeWidth(2)
    self.frame:draw()
    fill(87, 87, 87, 221)
    
    noStroke()
    translate(self.x, self.y)

    for i = 1, #self.dividers do
       self.dividers[i]:draw()
    end
    for i = 1, #self.tokens do
        if self.tokens[i].divide == self.selectedDivider then
            self.tokens[i]:draw()
        end
    end
    popMatrix()
    popStyle()
end

function TokenTray:touched(touch)
    t = Ttouch(touch)
    self.selected = 0
    t:translate(self.x, self.y)
    for i = 1, #self.tokens do
        if self.tokens[i]:touched(t) then
            self.selected = i
            return true
            --sound(SOUND_SHOOT, 773)
        end
    end
    for i = 1, #self.dividers do
        if self.dividers[i]:touched(t) then
            self:selectDivider(i)
            sound(SOUND_BLIT, 4824)
            return false
            --sound(SOUND_SHOOT, 773)
        end
    end
    return false
end
