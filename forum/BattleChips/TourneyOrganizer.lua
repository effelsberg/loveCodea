TourneyOrganizer = class()

function TourneyOrganizer:init(x, y)
    local i
    self.x = x
    self.y = y
    self.frame = Frame(x, y, x + 710, y + 850)
    self.header = Frame(self.frame.left + 4, self.frame.top - 40,
    self.frame.right - 4, self.frame.top - 4)

    self.action = 0
    self.contestantFrames = {}
    self.contestants = {}
    for i = 1,4 do
        self.contestantFrames[i] = Frame(i * 175 - 100, 800, 
        i * 175 , 880)
        self.contestants[i] = 0
    end
    self.selected = 0
    self.showSlider = false
    self.slider = VRobotSlider(self.contestantFrames[1].left,
    self.contestantFrames[1].bottom)
    self.robothonBtn = BigButton("Quartet", 570, 400)
    self.skeetBtn = BigButton("Skeet", 75, 600)
    self.mazeBtn = BigButton("Maze", 240, 600)
    self.chaseBtn = BigButton("Chase", 405, 600)
    self.meleeBtn = BigButton("Melee", 570, 600)
    --self.mazeBtn.active = false
    self.chaseBtn.active = false
    self.robothonBtn.active = false
end

function TourneyOrganizer:loadRobot(i)
    self.contestants[1] = i
end

function TourneyOrganizer:draw(robots)
    local i
    pushStyle()
    noFill()
    strokeWidth(2)
    stroke(246, 246, 246, 255)
    self.frame:draw()
    self.header:draw()
    textMode(CENTER)
    strokeWidth(1)
    for i = 1,4 do
        stroke(255, 255, 255, 255)
        noFill()
        self.contestantFrames[i]:draw()
        if self.contestants[i] > 0 then
            pushMatrix()
            translate(self.contestantFrames[i]:midX(), 
            self.contestantFrames[i]:midY())
            robots[self.contestants[i]]:drawBase()
            fontSize(16)
            fill(255, 255, 255, 224)
            text(robots[self.contestants[i]].name, 0, -55)
            popMatrix()
        else
            fontSize(48)
            fill(115, 115, 115, 190)
            text("?", self.contestantFrames[i]:midX(), 
            self.contestantFrames[i]:midY())
            fill(154, 126, 126, 224)
            fontSize(16)
            text("Random", self.contestantFrames[i]:midX(), 
            self.contestantFrames[i]:midY()-55)
        end
    end
    fill(165, 165, 188, 255)
    stroke(147, 153, 173, 255)
    strokeWidth(1)
    line(self.contestantFrames[2].left, 
    self.contestantFrames[1].top + 20,
    self.contestantFrames[2].left + 145, 
    self.contestantFrames[1].top + 20)
    line(self.contestantFrames[2].left, 
    self.contestantFrames[1].top + 15,
    self.contestantFrames[2].left, 
    self.contestantFrames[1].top + 25)
    line(self.contestantFrames[4].left - 45, 
    self.contestantFrames[1].top + 20,
    self.contestantFrames[4].right, 
    self.contestantFrames[1].top + 20)
    line(self.contestantFrames[4].right, 
    self.contestantFrames[1].top + 15,
    self.contestantFrames[4].right, 
    self.contestantFrames[1].top + 25)
    text("Melee Opponents", self.contestantFrames[3]:midX(), 
    self.contestantFrames[1].top + 20)
    noFill()
    stroke(255, 255, 255, 154)
    strokeWidth(2)
    rect(self.frame.left + 35, 400, self.frame.left + 95, 460)
    line(self.frame.left + 95, 430, self.frame.left + 155, 430)
    rect(self.frame.left + 155, 400, self.frame.left + 215, 460)
    line(self.frame.left + 215, 430, self.frame.left + 275, 430)
    rect(self.frame.left + 275, 400, self.frame.left + 335, 460)
    line(self.frame.left + 335, 430, self.frame.left + 395, 430)
    rect(self.frame.left + 395, 400, self.frame.left + 455, 460)
    line(self.frame.left + 215, 430, self.frame.left + 275, 430)
    fill(255, 255, 255, 255)
    fontSize(32)
    text("1", self.frame.left + 65, 430)
    text("2", self.frame.left + 185, 430)
    text("3", self.frame.left + 305, 430) 
    text("4", self.frame.left + 425, 430)
    
    self.meleeBtn:draw()
    self.skeetBtn:draw()
    self.mazeBtn:draw()
    
    stroke(113, 102, 159, 255)
    fill(109, 111, 169, 255)
    
    self.chaseBtn:draw()
    self.robothonBtn:draw()

    fontSize(16)
    textMode(CORNER)
    text("TOURNEY ORGANIZER", self.frame.left + 15, 
    self.frame.top - 32)
    text("Four Event Robothon", self.frame.left + 20, 
    self.frame.bottom + 330)
    
    
    
    
    if self.showSlider then self.slider:draw(robots) end
    popStyle()
end

function TourneyOrganizer:touched(touch)
    local i
    for i = 1,4 do
        if self.contestantFrames[i]:touched(touch) then
            self.showSlider = true
            self.slider = VRobotSlider(
            self.contestantFrames[i].right,
            self.contestantFrames[i].bottom)
            self.selected = i
        end
    end
    if self.showSlider then
        if self.slider:touched(touch) then
            self.contestants[self.selected] = self.slider.selected
        end
    end
end
