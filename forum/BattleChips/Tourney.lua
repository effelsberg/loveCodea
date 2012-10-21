Tourney = class()

function Tourney:init()
    self.matches = {}
    self.scores = {}
    self.robots = {}
    self.matchNum = 0
    self.matchCount = 1
    self.isActive = false
    self.frame = Frame(50, 500, WIDTH - 50, HEIGHT - 50)
    self.type = 0
    self.timer = 0
end

function Tourney:load(t, a, b, c, d)
    self.matchNum = 0
    self.scores = {}
    self.type = t
    self.robots = {a, b, c, d}
    if self.type == 1 then
        self.matches[1] = {a, b, c, d}
        self.matches[2] = {a, b, c, d}
        self.matches[3] = {a, b, c, d}
        self.matches[4] = {a, b, c, d}
        self.timer = 100
        self.matchNum = 0
        self.matchCount = 4
    else
        self.matches[1] = {a, d, nil, nil}
        self.matches[2] = {b, c, nil, nil}
        self.matches[3] = {a, b, nil, nil}
        self.matches[4] = {a, b, nil, nil}
        self.timer = 100
        self.matchNum = 0
        self.matchCount = 4
    end
end

function Tourney:getNextMatch()
    self.matchNum = self.matchNum + 1
    if self.matchNum <= self.matchCount then
        return self.matches[self.matchNum]
    end
end

function Tourney:recordScores(a, b, c, d)
    self.scores[self.matchNum] = {a, b, c, d}
end

function Tourney:draw()
    local bot, round, temp
    fill(192, 174, 174, 218)
    stroke(255, 255, 255, 104)
    strokeWidth(3)
    self.frame:draw()
    noFill()
    fontSize(32)
    textMode(CORNER)
    text("Tourney Results", self.frame.left + 35, self.frame.top - 50)
    
    fontSize(22)
    text("Bot", self.frame.left + 50, self.frame.top - 90)
    text("1", self.frame.left + 275, self.frame.top - 90)
    text("2", self.frame.left + 350, self.frame.top - 90)
    text("3", self.frame.left + 425, self.frame.top - 90)
    text("4", self.frame.left + 500, self.frame.top - 90)
    line(self.frame.left + 50, self.frame.top - 100,
    self.frame.left + 500, self.frame.top - 100)
    text("Total", self.frame.left + 575, self.frame.top - 90)
    for bot = 1,4 do
        textAlign(LEFT)
        text(self.matches[1][bot].name, self.frame.left + 50, 
        self.frame.top - 100 - bot * 35)
        temp = 0
        for round = 1, 4 do
            textAlign(RIGHT)
            text(self.scores[round][bot], 
            self.frame.left + 200 + round * 75, 
            self.frame.top - 100 - bot * 35)
            temp = temp + self.scores[round][bot]
        end
        text(temp, self.frame.left + 575, 
        self.frame.top - 100 - bot * 35)
    end
end
