Arena = class()

function Arena:init(l, b, r, t)
    self.robots = {}
    self.timer = 0
    self.tourney = false
    self.gameOver = false
    self.game = 1
    self.pulse = 0
    self.pulseDirection = 2
    self.skeet = {}
    self.walls = {}
    self.tracks = {}
    self.launchTime = ElapsedTime
    self:sizeFrames(l, b, r, t)
end

function Arena:sizeFrames(l, b, r, t)
    -- define bounds for the arena
    self.frame = Frame(l, b, r, t)
    self.panel = Frame(l + 1, t - 90, r - 1, t - 1)
    self.stop = Frame(r - 70, t - 65, r - 30, t - 25)
    self.field = Frame(l + 5, b + 20, r - 5, t - 90)
    self.launch = Frame(self.frame:midX() - 30, self.frame.bottom - 15,
    self.frame:midX() + 30, self.frame.bottom + 30)
    for i,r in ipairs(self.robots) do
        r.limits = self.field
    end
end

function Arena:loadRobot(r, x, y)
    -- copy a robot into the arena, and set up for action
    -- much of this is only needed because deep copy is losing
    -- table order.
    local i, nr
    
   -- nr = Robot(math.random(self.field:width() - 90) + 30, 
   -- math.random(self.field:height() - 90) + 30)
    nr = Robot(x, y)
    nr.hp = r.hp
    nr.direction = math.random(4)
    for i = 1, table.maxn(r.program) do
        nr.program[i] = r.program[i]
    end
    nr.bounds = Frame(nr.x, nr.y,  nr.x + 60, nr.y + 60)
    nr.program = r.program
    nr.bump = false
    nr.radar = false
    nr.heat = 0
    nr.step = 1
    nr.wins = r.wins
    nr.losses = r.losses
    nr.name = r.name
    nr.repeatCounter = 1
    nr.points = 0
    nr.treadColor = r.treadColor
    nr.bodyColor = r.bodyColor
    nr.headColor = r.headColor
    nr.dishColor = r.dishColor
    nr.head = r.head
    nr.dish = r.dish
    nr.body = r.body
    nr.tread = r.tread
    nr.limits = self.field
    i = #self.robots + 1
    -- design stuff here for now. should probably move.
    nr.speed = r.tread * 4 - (r.body - 1)
    nr.turnDelay = r.tread * 15 - 10
    nr.shield = (r.head - 1) * 3.5
    nr.repairRate = 1 / r.head
    nr.weaponStrength = nr.dish * 2.5 - 2
    self.robots[i] = nr
    self.robots[i]:createImage()
end

function Arena:copyRobot(r)
    -- copy using deepcopy
    -- seems to have trouble with otder of code
    local i, nr
    nr = deepcopy(r)
    nr.direction = math.random(4)
    nr.bounds = Frame(nr.x, nr.y,  nr.x + 60, nr.y + 60)
    nr.bump = false
    nr.radar = false
    nr.heat = 0
    nr.step = 1
    nr.points = 0
    i = table.maxn(self.robots) + 1
    self.robots[i] = nr
end

function Arena:skeetMatch(r)
    self.game = 2
    self.robots ={}
    self.tracks = {}
    self.walls = {}
    self:loadRobot(r, arena.field:midX(), arena.field:midY())
    self.robots[1].bounds = Frame(self.robots[1].x, 
    self.robots[1].y,  self.robots[1].x + 60, self.robots[1].y + 60)
    self.skeet[1] = Skeet(30, 30, self.field)
    self.skeet[2] = Skeet(30, self.field:height() / 2, self.field)
    self.skeet[3] = Skeet(30, self.field:height() - 30, self.field)
    self.skeet[4] = Skeet(self.field:width() / 2, 
    self.field:height() - 30, self.field)
    self.skeet[5] = Skeet(self.field:width() - 30, 
    self.field:height() - 30, self.field)
    self.skeet[6] = Skeet(self.field:width() - 30, 
    self.field:height() / 2, self.field)
    self.skeet[7] = Skeet(self.field:width() - 30, 30, self.field)
    self.skeet[8] = Skeet(self.field:width() / 2, 30, self.field)
    self.timer = 300
    self.tourney = true
end

function Arena:mazeRace(r)
    self.game = 3
    self:loadRobot(r, 10, 10)
    self.robots[1].bounds = Frame(self.robots[1].x, 
    self.robots[1].y,  self.robots[1].x + 60, self.robots[1].y + 60)
    self.robots[1].dir = 3
    -- base walls
    self.walls[1] = Frame(80, 10, 81, self.field:height() - 80)
    self.walls[2] = Frame(160, 90, 161, self.field:height() + 20)
    self.walls[3] = Frame(240, 10, 241, self.field:height() - 80)
    self.walls[4] = Frame(325, 510, 326, self.field:height())
    self.walls[5] = Frame(245, 415, 400, 416)
    self.walls[6] = Frame(325, 505, 480, 506)
    self.walls[7] = Frame(485, 340, 486, 500)
    self.walls[8] = Frame(325, 330, 580, 331)
    self.walls[9] = Frame(325, 90, 326, 330)
    self.walls[10] = Frame(405, 10, 406, 235)
    self.walls[11] = Frame(500, 85, 501, 235)
    self.walls[12] = Frame(580, 85, 581, 330)
    self.walls[13] = Frame(500, 80, 660, 81)
    self.walls[14] = Frame(660, 85, 661, 330)
    self.walls[15] = Frame(575, 410, self.field:width(), 411)
    self.walls[16] = Frame(570, 415, 571, self.field:height() - 80)
    self.walls[17] = Frame(405, 585, 565, 586)
    self.walls[18] = Frame(405, 590, 406, self.field:height() - 80)
    self.walls[19] = Frame(485, 670, 486, self.field:height() + 20)
    self.walls[20] = Frame(660, 505, 661, self.field:height() + 20)
    
    self.tracks = {}
    self.tracks[1] = Track(40, 300, 0)
    self.tracks[2] = Track(40, 600, 0)
    self.tracks[3] = Track(40, 820, -45)
    self.tracks[4] = Track(120, 820, 225)
    self.tracks[5] = Track(120, 500, 180)
    self.tracks[6] = Track(120, 200, 180)
    self.tracks[7] = Track(120, 50, 225)
    self.tracks[8] = Track(200, 50, -45)
    self.tracks[9] = Track(200, 500, 0)
    self.tracks[10] = Track(200, 830, -45)
    self.tracks[11] = Track(280, 830, 225)
    self.tracks[12] = Track(280, 455, 225)
    self.tracks[13] = Track(440, 455, 225)
    self.tracks[14] = Track(440, 375, 225)
    self.tracks[15] = Track(285, 375, 135)
    self.tracks[16] = Track(285, 50, 225)
    self.tracks[17] = Track(365, 50, -45)
    self.tracks[18] = Track(365, 280, -45)
    self.tracks[19] = Track(445, 280, 225)
    self.tracks[20] = Track(450, 50, 225)
    self.tracks[21] = Track(705, 50, -45)
    self.tracks[22] = Track(705, 370, 45)
    self.tracks[23] = Track(525, 370, 45)
    self.tracks[24] = Track(525, 540, 45)
    self.tracks[25] = Track(365, 540, 45)
    self.tracks[26] = Track(365, 830, -45)
    self.tracks[27] = Track(445, 830, 225)
    self.tracks[28] = Track(445, 625, 225)
    self.tracks[29] = Track(525, 625, -45)
    self.tracks[30] = Track(525, 830, -45)
    self.tracks[31] = Track(615, 830, 225)
    self.tracks[32] = Track(615, 625, 180)
    self.tracks[33] = Track(615, 460, 225)
    self.tracks[34] = Track(700, 460, -45)
    self.tracks[35] = Track(700, 830, 0)
    
    self.timer = 1000
    self.tourney = true
end

function Arena:clear()
    -- pop robots from arena
    sound(SOUND_POWERUP, 2591)
    self.robots = {}
    self.skeet = {}
    self.walls = {}
    self.tracks = {}
    self.timer = 0
    self.game = 1
    self.gameOver = false
    self.tourney  = false
    
end

function Arena:testBounds(type, num, bounds)
    for i, r in ipairs(self.robots) do
        if type ~= 1 or num ~= i then 
            if r.bounds:overlaps(bounds) and r.hp > 0 then
                if r.bounds.left < bounds.left then
                    return 1
                elseif r.bounds.left > bounds.left then
                    return 2
                elseif r.bounds.top < bounds.top then
                    return 3
                elseif r.bounds.top > bounds.left then
                    return 4
                end
            end
        end
    end
    for i, s in ipairs(self.skeet) do
        if (type ~= 2 or num ~= i) and s.active == 1 then
            if s.bounds:overlaps(bounds) then
                if s.bounds.left < bounds.left then
                    return 1
                elseif s.bounds.left > bounds.left then
                    return 2
                elseif s.bounds.top < bounds.top then
                    return 3
                elseif s.bounds.top > bounds.left then
                    return 4
                end
            end
        end
    end
    return 0
end

function Arena:checkRadar(k, r)
    local i, robot
    r.radar = false
    -- trim against walls
    for i, wall in ipairs(self.walls) do
        if r.rf:overlaps(wall) then
            if r.direction == 1 then
                r.rf.top = wall.bottom
            elseif r.direction == 2 then
                r.rf.right = wall.left
            elseif r.direction == 3 then
                r.rf.bottom = wall.top
            elseif r.direction == 4 then
                r.rf.left = wall.right
            end
        end
    end
    for i, robot in ipairs(self.robots) do
        if i ~= k then
            if r.rf:overlaps(robot.bounds) and robot.hp > 0 then
                r.radar = true
            end
        end
    end
    for i, skeet in ipairs(self.skeet) do
        if r.rf:overlaps(skeet.bounds) and skeet.active == 1 then
            r.radar = true
        end
    end
    for i, track in ipairs(self.tracks) do
        if r.rf:overlaps(track.bounds) and track.active == 1 then
            r.radar = true
        end
    end
    pushStyle()
    fill(90, 181, 230, 74)
    noStroke()
    r.rf:draw()
    popStyle()
    r.fireRadar = false
end

function Arena:checkLaser(k, r)
    local i, robot
    for i, robot in ipairs(self.robots) do
        if i ~= k then
            if r.rf:overlaps(robot.bounds) then
                if robot.hp > 0 then 
                    -- distance between
                    --d = robot.bounds.
                    robot.hp = robot.hp - r.weaponStrength
                    r.points = r.points + 1
                    if robot.heat < 20 then 
                        robot.heat = robot.heat + 5
                    end
                end
            end
        end
    end
    for i, s in ipairs(self.skeet) do 
        if r.rf:overlaps(s.bounds) and s.active == 1 then
            r.points = r.points + 1
            s.active = 2
        end
    end
    r.fireLaser = false
end

function Arena:checkCollisions(k, r)
    local i, b
      -- test outer walls
    if r.x < 5 then
        r.x = r.oldX
        r.bump = true
    elseif r.x > self.field:width() - 50 then
        r.x = r.oldX
        r.bump = true
    elseif r.y < 5 then
        r.y = r.oldY
        r.bump = true
    elseif r.y > self.field:height() - 30 then
        r.y = r.oldY
        r.bump = true
    end
    
    -- test interior walls
    for w, wall in ipairs(self.walls) do
        --wall:draw()
        if r.bounds:overlaps(wall) then
            r.bump = true
            r.y = r.oldY
            r.x = r.oldX
            --displayMode(STANDARD)
            --print(w)
        end
    end
    
    -- test tracks
    -- track collisions do not activate the bump sensor
    for i, track in ipairs(self.tracks) do 
        if r.bounds:overlaps(track.bounds) and track.active == 1 then
            r.points = r.points + 1
            track.active = 2
            sound(SOUND_POWERUP, 7170)
        end
    end
    
    -- test other bot collisions
    b = self:testBounds(1, k, r.bounds) 
    if b == 1 then
    -- hit from left
        if r.x < self.field:width() - 60 then r.x = r.x + 5 end
    elseif b == 2 then
    -- hit from right
        if r.x > 30 then r.x = r.x - 5 end
    elseif b == 1 then
    -- hit from bottom
        if r.y < self.field:height() - 30 then r.y = r.y + 5 end
    elseif b == 1 then
    -- hit from top
        if r.y > 30 then r.y = r.y - 5 end
    end 
    if b > 0 then r.bump = true end
end

function Arena:checkSkeetCollisions(k, s)
    local i, b
    
    b = self:testBounds(2, k, s.bounds) 
    if b > 0 then
        s.dx = - s.dx
        s.dy = - s.dy
    end
end

function Arena:setMatch(a, b, c, d)
    self.robots = {}
    self:loadRobot(a, 60, 60)
    self:loadRobot(b, 60, self.field:height() - 60)
    self:loadRobot(c, self.field:width() - 60, 60)
    self:loadRobot(d, self.field:width() - 60, self.field:height() - 60)
    self.timer = 100
end

function Arena:drawPen(r)
    local prevX, prevY, prevStatus, i, p
    prevStatus = false
    pushStyle()
    stroke(111, 333 - self.pulse, 111, 111)
    for i, p in ipairs(r.pen) do
        if prevStatus then
            line(prevX, prevY, p.x, p.y)
        end
        prevX = p.x
        prevY = p.y
        prevStatus = p.status
    end
    popStyle()
end

function Arena:draw()
    local k, robot, liveCount, i
    
    -- base elements
    pushStyle()
    stroke(255, 255, 255, 255)
    strokeWidth(2)
    noFill()
    self.frame:draw()
    self.panel:inset(10, 10)
    self.panel:draw()
    self.panel:inset(-10, -10)
    line(20, 40, WIDTH - 20, 40)
    
    if self.game == 2 then
        if self.robots[1].points == 8 or self.timer == 0 then
            self.gameOver = true
        end
    end
    
    if self.game == 3 then
        if self.robots[1].points == 30 or self.timer == 0 then
            self.gameOver = true
        end
        
    end
        
    self.stop:draw()
    for i = 1,3 do
        y = self.field.bottom + self.field:height() / 4 * i
        line(self.field.left, y, self.field.left + 10, y)
        line(self.field.right - 10, y, self.field.right, y)
    end
    self.pulse = self.pulse + self.pulseDirection
    if self.pulse > 255 or self.pulse < 0 then
        self.pulseDirection = 0 - self.pulseDirection
    end
    stroke(255, 55, 55, self.pulse)
    ellipse(self.stop:midX(), self.stop:midY(), 30)
    ellipse(self.stop:midX(), self.stop:midY(), 20)
    fill(255, 255, 255, 255)
    fontSize(36)
    text("Battle Chips",self.panel.left + 50, self.panel.top - 60)
    noFill()
    stroke(255, 255, 255, 255)
    pushMatrix()
    translate(self.panel.left + 32, self.panel.top - 40)
    for i = 0, 8 do
        rotate(i * 45)
        rect(-3,0,3,15)
    end
    fill(25, 27, 46, 255)
    ellipse(0, 0, 25)
    popMatrix()
    fill(255, 255, 255, 255)
    
    -- translate to field
    pushMatrix()
    translate(self.frame.left, self.frame.bottom)
    
    if not self.gameOver then
        -- draw walls
        stroke(111 + self.pulse, 111 + self.pulse, 255, 
        111 + self.pulse)
        for i, w in ipairs(self.walls) do
            w:draw()
        end
        
        -- draw skeet
        for i, s in ipairs(self.skeet) do
            if s.active <  10 then
                s:draw()
                self:checkSkeetCollisions(i, s)
            end
        end
        
        -- draw tracks
        for t, track in ipairs(self.tracks) do
            if track.active <  10 then
                track:draw()
            end
        end
        
        -- draw robots
        noSmooth()
        liveCount = 0
        for k, robot in ipairs(self.robots) do
            self:drawPen(robot)
            if robot.hp > 0 then liveCount = liveCount + 1 end
            if robot.fireRadar then
                self:checkRadar(k, robot)
            end
            if robot.fireLaser then
                self:checkLaser(k, robot)
            end
            self:checkCollisions(k, robot)
            robot:draw(1)
            if robot.hp > 0 then 
                robot:run()
            else 
                robot.hp = 0
            end
            
        end
        if liveCount < 2 and self.game == 4 then 
            self.timer = self.timer - 1
        else
            self.timer = self.timer - 0.1
        end
        if self.timer < 0 then self.timer = 0 end
        popMatrix()
        fontSize(12)
        textMode(LEFT)
        for k, robot in ipairs(self.robots) do
            
            if self.game < 2 then
                fill(159, 201, 223, 255)
                text(robot.name, 30, 900)
                s = robot.step - 30 * math.floor(robot.step / 30)
                if robot.program[robot.step] ~= nil and 
                   robot.program[robot.step].code ~= nil then
                    --displayMode(STANDARD)
                    
                    s = s.."  "..robot.program[robot.step].code.long1
                    --print(s)
                else
                    fill(223, 174, 174, 255)
                    s = s.."  NIL"
                end
                x = math.floor(robot.step / 30) * 250 + 50
                y = 850 - robot.step * 15 + 
                math.floor(robot.step / 30) * 450
                text(s, x, y)
            end
            x = self.frame.right - k * 60 - 100
            y = self.panel.bottom + 35
            sprite(robot.img, x - 15, y, x + 15, y + 30)
            
            fill(26, 26, 26, 255)
            stroke(130, 154, 221, 255)
            rect(self.frame.right - k * 60 - 127, 
            self.panel.bottom + 35,
            self.frame.right - k * 60 - 120, self.panel.bottom + 65)
            if robot.hp > 7 then 
                fill(72, 255, 0, 255)
            elseif robot.hp > 4 then
                fill(244, 255, 0, 255)
            else
                fill(255, 0, 13, 255)
            end
            noStroke()
            rect(self.frame.right - k * 60 - 126, 
            self.panel.bottom + 36,
            self.frame.right - k * 60 - 121, self.panel.bottom + 36 +
            robot.hp * 3)
            fill(248, 248, 248, 255)
            text(robot.points, self.frame.right - k * 60 - 100, 
            self.panel.bottom + 25)
        end
        
        if self.tourney then 
            textMode(CORNER)
            fontSize(48)
            fill(218, 214, 214, 81)
            if self.game == 1 then
                text("Melee", self.field.left + 15, self.field.top - 60)
            end
            if self.game == 2 then
                text("Skeet", self.field.left + 15, self.field.top - 60)
            end
            if self.game == 3 then
                text("Maze", self.field.left + 15, self.field.top - 60)
            end
            text(math.floor(self.timer), 
            self.frame.left + 15, self.field.bottom)
        else
            strokeWidth(1)
            stroke(255, 255, 255, 255)
            line(self.field:midX() - 5, self.field.bottom , 
            self.field:midX() + 5, self.field.bottom )
            line(self.field:midX(), self.field.bottom + 5, 
            self.field:midX(), self.field.bottom - 5)
            line(self.field:midX() - 5, self.field.bottom + 5, 
            self.field:midX() + 5, self.field.bottom  - 5)
            line(self.field:midX() - 5, self.field.bottom - 5, 
            self.field:midX() + 5, self.field.bottom  + 5)
        end
    else 
    -- game over
        if self.game == 2 then
            self.robots[1].x = 100
            self.robots[1].y = 700
            self.robots[1]:draw(1)
            fontSize(32)
            text("Skeet Results", 100, 800)
            fontSize(24)
            text(self.robots[1].name, 200, 700)
            text("Skeet destroyed", 100, 600)
            text("Time remaining", 100, 500)
            text("Total Score", 100, 400)
            text(self.robots[1].points, 500, 600)
            text(math.floor(self.timer), 500, 500)
            score = self.robots[1].points * 10 + math.floor(self.timer)
            text(score, 500, 400)
        end
        if self.game == 3 then
            self.robots[1].x = 100
            self.robots[1].y = 700
            self.robots[1]:draw(1)
            fontSize(32)
            text("Maze Results", 100, 800)
            fontSize(24)
            text(self.robots[1].name, 200, 700)
            text("Tracks stomped", 100, 600)
            text("Time remaining", 100, 500)
            text("Total Score", 100, 400)
            text(self.robots[1].points, 500, 600)
            text(math.floor(self.timer), 500, 500)
            score = self.robots[1].points * 5 + math.floor(self.timer)
            text(score, 500, 400)
        end
    end
    popStyle()
end

function Arena:touched(touch)
    if self.launch:touched(touch) and 
        ElapsedTime > self.launchTime + 1 then
        sound(SOUND_POWERUP, 26548)
        self.skeet[#self.skeet + 1] = Skeet(self.field:midX(), 
        20, self.field)
        self.launchTime = ElapsedTime
    end
    if self.frame:touched(touch) then
        return true
    end
    return false
end

