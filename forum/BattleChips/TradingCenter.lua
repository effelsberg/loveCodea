TradingCenter = class()

function TradingCenter:init()
    local i, x, y
    self.frame = Frame(20, 160, WIDTH - 10, HEIGHT - 20)
    self.cards = {}
    self.images = {}
    for x = 1, 5 do
        for y = 1, 4 do
            i = x + (y-1) * 5
            self.cards[i] =
            Frame(x * 140 - 100, y * 200 - 10 ,
            x * 140 + 30, y * 200 + 180)
            w = self.cards[i]:width()
            h = self.cards[i]:height()
            self.images[i] = image(w, h)
        end
    end

    self.center = 1
end

function TradingCenter:initImages()
    local i, w, h
    for i = 1,20 do
        setContext(self.images[i]) 
        w = self.cards[i]:width()
        h = self.cards[i]:height()
        fill(179, 179, 179, 255)
        stroke(57, 54, 54, 255)
        strokeWidth(6)
        rect(1, 1, w, h)
        strokeWidth(2)
        stroke(112, 113, 115, 132)
        fill(0, 0, 0, 255)
        rect(10, 10, w - 10, h - 10)
        fill(0, 0, 0, 255)
        translate(w / 2 - 15, h / 2 + 50)
        robots[i]:drawBase()
        noStroke()
        fill(0, 0, 0, 255)
        rect(40,-130,65,30)
        for c = 1, 30 do
            fill(255, 255, 255, 255)
            if robots[i].program[c] ~= nil then
                p = robots[i].program[c].code
                if p ~= nil then
                    if p.short == "F" then
                        fill(255, 0, 0, 255)
                    elseif p.short == "L" then
                        fill(255, 0, 181, 255)
                    elseif p.short == "R" then
                        fill(255, 101, 0, 255)
                    elseif p.short == "B" then
                        fill(255, 220, 0, 255)
                    elseif p.short == "W" then
                        fill(255, 0, 241, 255)
                    elseif p.short == "H" then
                        fill(14, 0, 255, 255)
                    elseif p.short == "A" then
                        fill(0, 178, 255, 255)
                    elseif p.short == "D" then
                        fill(141, 0, 255, 255)
                    elseif p.short == "G" then
                        fill(3, 255, 0, 255)
                    elseif p.short == "5" then
                        fill(0, 255, 117, 255)
                    elseif p.short == "P" then
                        fill(95, 255, 0, 255)
                    end
                end
                rect(-30, -129 + c * 3, -20, -126 + c * 3)
                v = robots[i].program[c].value
                fill(255-v * 5, 255-v * 5, 255-v * 5)
                rect(-20, -129 + c * 3, -10, -126 + c * 3)
            end
        end
        strokeWidth(1)
        fill(156, 146, 146, 182)
        noFill()
        rect(-30, -129 + 1 * 3, -20, -126 + 30 * 3)
        rect(-20, -129 + 1 * 3, -10, -126 + 30 * 3)
        rotate(90)
        fill(255, 255, 255, 255)
        text(robots[i].name, -120, -65)
        resetMatrix()
        setContext()
    end
end

function TradingCenter:loadRobot(r)
    --self.robots[1] = r
    self:initImages()
    
end

function TradingCenter:draw()
    local i
    fill(174, 190, 195, 209)
    stroke(59, 111, 158, 190)
    strokeWidth(5)
    self.frame:draw()
    fontSize(120)
    fill(135, 171, 172, 207)
    text("Trade", 35, HEIGHT - 180)
    fontSize(20)
    for i = 1,20 do 
        sprite(self.images[i], 
        self.cards[i].left, self.cards[i].bottom,
        self.cards[i].right, self.cards[i].top)
    end
end

function TradingCenter:touched(touch)
    local i
    for i = 1,20 do
        if self.cards[i]:touched(touch) then
            saveImage("Dropbox:"..robots[i].name, self.images[i])
        end
    end 
            
end
