Robot = class()
    
function Robot:init(x, y)
    -- position and bounds
    self.penStart = false
    self.penStatus = false
    self.pen = {}
    self.x = x
    self.y = y
    self.oldX = x
    self.oldY = y
    self.bounds = Frame(0,0,0,0)
    self.direction = 0
    self.fromDir = 0
    self.toDir = 0
    
    -- code related values
    self.program = {}
    for i = 1, 30 do self.program[i] = nil end
    self.step = 1
    self.aEntry = 1
    self.bEntry = 1
    
    -- sensor values
    self.bump = false
    self.radar = false
    self.treadTick = 0
    self.fireLaser = false
    self.fireRadar = false
    self.delay = 0
    
    -- tourney-telated values
    self.hp = 10
    self.damage = self.hp
    self.wins = 0
    self.losses = 0
    self.heat = 0
    self.repeatCounter = 1
    self.points = 0
    self.redirectValue = 0
    self.rf = Frame(0,0,0,0)
    self.limits = Frame(0,0,0,0)
    
    -- design-related values
    self.name = "Generobot"
    self.treadColor = 14
    self.bodyColor = 14
    self.headColor = 15
    self.dishColor = 4
    self.head = 1
    self.dish = 1
    self.body = 2
    self.tread = 2
    self.range = 20
    self.speed = 5
    self.turnDelay = 5
    self.turnTarget = 1
    self.flameTimer = 0
    self.shield = 0
    self.repairRate = 0

    self.img = image(60, 60)
    
end

function Robot:createImage()
    -- create an image of the bot for use in menus, etc
    pushMatrix()
    strokeWidth(2)
    translate(30,30)
    setContext(self.img)
    self:drawBase()
    setContext()
    popMatrix()
end

function Robot:redirect(v)
    -- set correct step number depending on board
    if self.step > 60 then
        return v + 60
    elseif self.step > 30 then
        return v + 30
    else
        return v
    end
end

function Robot:createDetectionFrame(dir)
    -- used by radar and laser
    if dir == 1 then
        -- up
        self.rf = Frame(self.x + 24, self.y + 36, 
        self.x + 36, self.range *  60)
        if self.rf.top > self.limits:height() then
            self.rf.top = self.limits:height()
        end
    elseif dir == 2 then
        -- right
        self.rf = Frame(self.x + 33, self.y + 24, 
        self.x + self.range *  60, self.y + 36)
        if self.rf.right > self.limits:width() then
            self.rf.right = self.limits:width()
        end
    elseif dir == 3 then
        -- down
        self.rf = Frame(self.x + 24, self.y - self.range *  60, 
        self.x + 36, self.y + 33)
        if self.rf.bottom < 0 then
            self.rf.bottom = 0
        end
    elseif dir == 4 then
        -- left
        self.rf = Frame(self.x - self.range *  60, self.y + 24, 
        self.x + 33, self.y + 36)
        if self.rf.left < 0 then
            self.rf.left = 0
        end
    end
end

function Robot:drawLaser()
    -- create the rectangle for laser fire
    if self.rf == nil then 
        self:createDetectionFrame(self.direction)
    end
    noStroke()
    fill(212, 60, 55, 92)
    self.rf:draw()
    sound(SOUND_SHOOT, 9773)
end

function Robot:drawRadar(dir)
    -- create the rectangle for radar detection
    self:createDetectionFrame(dir)
    --noStroke()
    --fill(81, 85, 175, 50)
    --self.rf:draw()
    --sound(SOUND_JUMP, 9772)
end

function Robot:run()
    local p, rf, redirected
    --displayMode(STANDARD)
    if self.delay > 0 then
        self.delay = self.delay - 1
        return true
    end
    self.hp = self.hp + self.repairRate / 100
    if self.hp > 10 then self.hp = 10 end
    if self.radar then 
        self.step = self.redirectValue
        --sound(SOUND_HIT, 17131)
        self.radar = false
    end
    -- get executable token
    p = self.program[self.step]
    redirected = false
    if p == nil or p.code == nil then
        if self.step > 60 then 
            self.step = self.bEntry + 1
        elseif self.step > 30 then
            self.step = self.aEntry + 1
        else   
            self.step = 1
        end
        redirected = true
        return false
    end
    -- execute control
    if p.code.short == "G" then
        -- Goto
        self.step = self:redirect(p.value)
        redirected = true
    elseif p.code.short == "5" then
        -- 50/50 random
        if math.random(2) > 1 then
            self.step = self:redirect(p.value)
            redirected = true   
        end 
    elseif p.code.short == "P" then
        -- repeat
        if self.repeatCounter < p.value then 
            self.repeatCounter = self.repeatCounter + 1
            self.step = self.step - 1
            redirected = true   
        else
            self.repeatCounter = 1
        end 
    -- check sensors
    elseif p.code.short == "D" then
        -- damage sensor
        if self.hp < self. damage then
            self.damage = self.hp
            self.step = self:redirect(p.value)
            redirected = true
        end
    elseif p.code.short == "H" then
        -- bump sensor
        if self.bump then 
            self.step = self:redirect(p.value)
            sound(SOUND_HIT, 17131)
            redirected = true
        end
        self.bump = false
    elseif p.code.short == "A" then
        -- radar sensor
        self:drawRadar(self.direction)
        self.delay = 5
        self.fireRadar = true
        self.redirectValue = self:redirect(p.value)
    elseif p.code.short == "I" then
        -- radar sensor right
        i = self.direction + 1
        if i > 4 then i = 1 end
        self:drawRadar(i)
        self.delay = 5
        self.fireRadar = true
        self.redirectValue = self:redirect(p.value)
    elseif p.code.short == "T" then
        -- radar sensor left
        i = self.direction - 1
        if i < 1 then i = 4 end
        self:drawRadar(i)
        self.delay = 5
        self.fireRadar = true
        self.redirectValue = self:redirect(p.value)
    -- take action
    elseif p.code.short == "F" then
        -- Forward
        self.treadTick = self.treadTick + 1
        if self.treadTick > 9 then
            self.treadTick = 0
        end
        if not self.bump then
            self.oldX = self.x
            self.oldY = self.y
            if self.direction == 1 then
                self.y = self.y + self.speed
            elseif self.direction == 2 then
                self.x = self.x + self.speed
            elseif self.direction == 3 then
                self.y = self.y - self.speed
            elseif self.direction == 4 then
                self.x = self.x - self.speed
            end
            if self.penStart then
                self.pen[#self.pen + 1] = 
                PenPoint(self.x + 30, self.y + 30, self.penStatus)
            end
        end
    elseif p.code.short == "B" then
        -- Reverse
        self.treadTick = self.treadTick - 1
        if self.treadTick < 0 then
            self.treadTick = 9
        end
        if not self.bump then
            self.oldX = self.x
            self.oldY = self.y
            if self.direction == 3 then
                self.y = self.y + self.speed
            elseif self.direction == 4 then
                self.x = self.x + self.speed
            elseif self.direction == 1 then
                self.y = self.y - self.speed
            elseif self.direction == 2 then
                self.x = self.x - self.speed
            end
            if self.penStart then
                self.pen[#self.pen + 1] = 
                PenPoint(self.x + 30, self.y + 30, self.penStatus)
            end
        end
    elseif p.code.short == "L" then
        self.direction = self.direction - 1
        if self.direction == 0 then self.direction = 4 end
        self.delay = self.delay + self.turnDelay
    elseif p.code.short == "R" then
        self.direction = self.direction + 1
        if self.direction == 5 then self.direction = 1 end
        self.delay = self.delay + self.turnDelay
    elseif p.code.short == "W" then
        -- fire laser
        self.delay = self.dish * 15
        self.fireLaser = true
        self:drawLaser()
    elseif p.code.short == "1" then
        -- Daughterboard A
        if self.step < 31 then
            self.aEntry = self.step
        end
        self.step = 31
        redirected = true
    elseif p.code.short == "2" then
        -- Daughterboard B
        if self.step < 61 then 
            self.bEntry = self.step
        end
        self.step = 61
        redirected = true
    elseif p.code.short == "S" then
        -- Sound Horn
        sound(SOUND_RANDOM, 19024)
    elseif p.code.short == "v" then
        -- pen down
        self.penStart = true
        self.penStatus = true
    elseif p.code.short == "^" then
        -- pen up
        self.penStart = true
        self.penStatus = false
    end
    -- step forward
    if not redirected then
        self.step = self.step + 1
    end
    self.treadTick = self.treadTick + 1
    if self.treadTick > 9 then
        self.treadTick = 0
    end
end

function Robot:draw(size)
    local i
    -- draw
    pushMatrix()
    translate(self.x + 30, self.y + 30)
    scale(size)
    if self.direction == 2 then
        rotate(270)
    elseif self.direction == 3 then
        rotate(180)
    elseif self.direction == 4 then
        rotate(90)
    end 
    strokeWidth(1)
    self:drawBase()
    popMatrix()
    self.bounds.left = self.x
    self.bounds.right = self.x + 60
    self.bounds.top = self.y + 60
    self.bounds.bottom = self.y
    if self.heat > 0 then self.heat = self.heat - 0.1 end
end

function Robot:drawDish(x, y)
    c1 = colors[self.dishColor]
    c2 = color(c1.r + self.heat * 22, c1.g, c1.b)
    stroke(c2)
    fill(backClr)
    if self.dish == 1 then
        line(x - 3, y, x, y + 15)
        line(x + 3, y, x, y + 15)
        line(x - 20, y + 7, x - 15, y + 3)
        line(x - 15, y + 3, x, y)
        line(x + 20, y + 7, x + 15, y + 3)
        line(x + 15, y + 3, x, y)
        line(x, y + 15, x, y + 20)
        ellipse(x, y + 15, 3)
        self.range = 20
    end
    if self.dish == 2 then
        rect(x - 3, y, x + 3, y + 20)
        line(x - 15, y, x, y)
        line(x + 15, y, x, y)
        line(x - 20, y + 10, x, y)
        line(x + 20, y + 10, x, y)
        self.range = 7
    end
    if self.dish == 3 then
        line(x - 15, y, x + 15, y)
        line(x - 10, y + 3, x + 10, y + 3)
        line(x - 7, y + 7, x + 7, y + 7)
        line(x - 3, y + 10, x + 3, y + 10)
        line(x, y, x, y + 20)
        ellipse(x, y + 20, 7)
        self.range = 3
    end
end

function Robot:drawHead(x, y)
    c1 = colors[self.headColor]
    c2 = color(c1.r + self.heat * 22, c1.g, c1.b)
    stroke(c2)
    fill(backClr)
    if self.head == 1 then
        ellipse(x, y, 30)
        ellipse(x, y, self.treadTick * 2)
        rect(x - 15, y - 5, x - 15, y + 5)
        rect(x + 15, y - 5, x + 15, y + 5)
        line(x - 15, y, x - 20, y)
        line(x + 15, y, x + 20, y)
    end
    if self.head == 2 then
        ellipse(x, y, 30)
        ellipse(x, y, 20)
        rotate(self.treadTick * 9)
        line(x+6,y+6,x-6,y-6)
        line(x+6,y-6,x-6,y+6)
        rotate(self.treadTick * -9)
    end
    if self.head == 3 then
        ellipse(x, y, 30)
        ellipse(x, y + 10, 20, 10)
        ellipse(x, y + 10, 15, 5)
        line(x - 15, y - 5, x - 20, y - 15) 
        line(x + 15, y - 5, x + 20, y - 15)
        fill(255, 0, 0, 255)
        ellipse(x, y + 5, 20, self.treadTick * 2)
    end
end

function Robot:drawBody(x, y)
    c1 = colors[self.bodyColor]
    c2 = color(c1.r + self.heat * 22, c1.g, c1.b)
    stroke(c2)
    fill(backClr)
    if self.body == 1 then
        ellipse(x, y, 40, 20)
        ellipse(x - 20, y, 15, 15)
        ellipse(x + 20, y, 15, 15)
    end
    if self.body == 2 then
        rect(x - 25, y - 10, x + 25, y + 10)
        ellipse(x - 25, y, 20)
        ellipse(x + 25, y, 20)
        rect(x - 15, y - 15, x + 15, y - 10)
    end
    if self.body == 3 then
        ellipse(x - 20, y, 30, 30)
        ellipse(x + 20, y, 30, 30)
        rect(x - 20, y - 15, x + 20, y + 15)
        ellipse(x, y, 40, 30)
    end
end

function Robot:drawTreads(x, y)
    local i
    c1 = colors[self.treadColor]
    c2 = color(c1.r + self.heat * 22, c1.g, c1.b)
    stroke(c2)
    fill(backClr)
    if self.tread == 1 then
        ellipse(20, -20, 20)
        ellipse(20, -20, 20, 5 + self.treadTick)
        ellipse(-20, -20, 20)
        ellipse(-20, -20, 20, 5 + self.treadTick)
        ellipse(-20, 20, 20)
        ellipse(-20, 20, 20, 5 + self.treadTick)
        ellipse(20, 20, 20)
        ellipse(20, 20, 20, 5 + self.treadTick)
        line(-20, -11, 0, 2)
        line(-17, -14, 0, -2)
        line(20, -11, 0, 2)
        line(17, -14, 0, -2)
        line(-20, 11, 0, 2)
        line(-17, 14, 0, -2)
        line(20, 11, 0, 2)
        line(17, 14, 0, -2)
    end
    if self.tread == 2 then
        rect(-30, -30, -15, 30)
        rect(15, -30, 30, 30)
        for i = 0,5 do
            line(-30, i * 10 - 30 + self.treadTick, 
               -15, i * 10 - 30 + self.treadTick)
            line(15, i * 10 -30 + self.treadTick, 
               30, i * 10 - 30 + self.treadTick)
        end
    end
    if self.tread == 3 then
        rect(-30, -30, -15, -15)
        rect(-27, -33, -17, -12)
        rect(15, -30, 30, -15)
        rect(17, -33, 27, -12)
        rect(-30, 15, -15, 30)
        rect(-27, 12, -17, 33)
        rect(15, 15, 30, 30)
        rect(17, 12, 27, 33)
        rect(-15, 20, 15, 25)
        rect(-15, -20, 15, -25)
        rect(-3, -10, 3, -20)
        rect(-3, 10, 3, 20)
        line(-27, self.treadTick - 30 + self.treadTick, 
        -17, self.treadTick - 30 + self.treadTick)
        line(17, self.treadTick - 30 + self.treadTick, 
        27, self.treadTick - 30 + self.treadTick)
        line(17, self.treadTick + 15 + self.treadTick, 
        27, self.treadTick + 15 + self.treadTick)
        line(-27, self.treadTick + 15 + self.treadTick, 
        -17, self.treadTick + 15 + self.treadTick)
    end
end

function Robot:drawBase()
    pushStyle()
    self:drawTreads(0, 0)
    self:drawBody(0, 0)
    self:drawHead(0, 0)
    self:drawDish(0, 10)
    popStyle()
end
