-- Batlle Chips 26 Jun 12
-- Mark Sumner
-- devilstower@gmail.com

displayMode(FULLSCREEN)
supportedOrientations(PORTRAIT_ANY)
rectMode(CORNERS)
spriteMode(CORNERS)
textMode(CORNER)
noSmooth()
font("Copperplate")

function setup()
    local y, x, i

    -- create background images
    gridImg = image(200, 200)
    fill(25, 27, 46, 255)
    stroke(255, 255, 255, 25)

    setContext(gridImg)
    noStroke()
    rect(0,0,200,200)
    strokeWidth(1)
    r = HEIGHT/WIDTH
    for y = 0, 59 do
        line(0, y * 4, 200, y * 4)
    end
    for x = 0,39 do
        line(x * 4 * r, 0, x * 4 * r, 200)
    end

    -- chip texture
    setContext()
    chipImg = image(145, 30)
    fill(79, 79, 79, 255)
    stroke(131, 123, 123, 135)
    strokeWidth(1)
    setContext(chipImg)
    rect(0,0,200,200)
    for y = 0, 20 do
        line(0, y * 3, 200, y * 3)
    end
    for x = 0,70 do
        line(x * 3, 0, x * 3 + 30, 200)
    end
    setContext()

    -- circut board texture
    boardImg = image(200, 200)
    fill(255, 255, 255, 255)
    strokeWidth(1)
    setContext(boardImg)
    rect(0,0,200,200)
    stroke(29, 54, 30, 135)
    for x = 0, 200 do
        line(x * 2, 0, x * 2, 200)
    end
    stroke(72, 72, 72, 135)
    for x = 0, 200 do
        line(0, x * 2, 200, x * 2)
    end
    setContext()

    -- robot array
    robots = {}
    for i = 1,20 do
        robots[i] = Robot(17 + i * 70,300)
    end

    -- definition of program codes
    codes = {}
    color(219, 11, 10, 255)
    codes[1] = Code("F", "Forward", "", false, color(219, 11, 10, 255))
    codes[2] = Code("L", "Turn", "Left", false, color(219, 11, 10, 255))
    codes[3] = Code("R", "Turn", "Right",
    false, color(219, 11, 10, 255))
    codes[4] = Code("B", "Reverse", "", false, color(219, 11, 10, 255))
    codes[5] = Code("W", "Fire!", "",
    false, color(251, 215, 9, 255))
    codes[6] = Code("H", "Bump", "", true, color(95, 99, 229, 255))
    codes[7] = Code("A", "Radar", "", true, color(95, 99, 229, 255))
    codes[8] = Code("I", "Radar", "Right",
    true, color(95, 99, 229, 255))
    codes[9] = Code("T", "Radar", "Left",
    true, color(95, 99, 229, 255))
    codes[10] = Code("D", "Damage", "", true, color(95, 99, 229, 255))
    codes[11] = Code("G", "Goto", "", true, color(31, 195, 17, 255))
    codes[12] = Code("5", "Random", "", true, color(31, 195, 17, 255))
    codes[13] = Code("P", "Repeat", "", true, color(31, 195, 17, 255))
    codes[14] = Code("+", "Shields", "On", false,
    color(251, 215, 9, 255))
    codes[15] = Code("-", "Shields", "Off", false,
    color(251, 215, 9, 255))
    codes[16] = Code("E", "Conduct", "Repairs",
    false, color(251, 215, 9, 255))
    codes[17] = Code("1", "Board", "A", false, color(42, 251, 8, 255))
    codes[18] = Code("2", "Board", "B", false, color(42, 251, 8, 255))
    codes[19] = Code("S", "Sound", "Horn", false,
     color(251, 215, 9, 255))
    codes[20] = Code("v", "Pen", "Down", false,
     color(251, 215, 9, 255))
    codes[21] = Code("^", "Pen", "Up", false,
     color(251, 215, 9, 255))
    mode = 1
    dragToken = Token(codes[1], 0, 0)
    bench = CodeBench(35, 150)
    scheduler = TourneyOrganizer(35, 150)
    tray = TokenTray(550, 150)
    oldState = nil
    doneBtn = BigButton("Done", 550, 25)
    doneBtn.frame.right = doneBtn.frame.right + 60
    codeBtn = BigButton("Code", 220, 100)
    designBtn = BigButton("Design", 30, 100)
    tourneyBtn = BigButton("Compete", 410, 100)
    tradeBtn = BigButton("Trade", 600, 100)

    arena = Arena(10, HEIGHT - 650, WIDTH - 10, HEIGHT - 10)
    arena:draw()
    studio = DesignStudio(20, 410, WIDTH - 20, HEIGHT - 20)
    vslider = Vslider(0,0,0)
    vcslider = VColorSlider(0,0,0)
    trader = TradingCenter()
    showSlider = false
    sliderPosition = 0
    leftBot = 1
    selectedRobot = 0
    botFrames = {}
    loadRobots()
    for i = 1,7 do
        botFrames[i] = Frame(i * 87, 200,
        i * 87 + 80, 300)
    end
    leftRobot = 1
    rightBtn = Frame(WIDTH - 80, 260, WIDTH, 360)
    leftBtn = Frame(0, 260, 80, 360)
    -- tourney variables
    tourney = Tourney()
end

function saveRobots()
    local k, s, i, c
    s = table.maxn(robots)..","

    for i, r in ipairs(robots) do
        r.wins = r.body * 10 + r.tread
        r.losses = r.head * 10 + r.dish
        s = s..r.name..","..r.wins..","..r.losses..","
        s = s..r.treadColor..","..r.bodyColor..","
        s = s..r.headColor..","..r.dishColor..","
        c = table.maxn(r.program)
        s = s..c
        if i < table.maxn(robots) or c > 0 then s = s.."," end
        for k, p in ipairs(r.program) do
            if p.code ~= nil then
                s = s..k..","..p.code.short..","..p.value
                s=s..","
            else
                s = s..k..",nil"..","..p.value
                s=s..","
            end
        end
    end
    saveProjectData("BCBots", s)
end

function loadRobots()
    local k, s, i, robotCount, d, c
    local w = {}
    --displayMode(STANDARD)
    s = readProjectData("BCBots")
    --print(s)
    if s == nil then
        s = getDefault()
    end
    if s ~= nil then
        i = 0
        for k in string.gmatch(s,"([^,]+)") do
            i = i + 1
            w[i] = k
        end
        robotCount = w[1]
        top = 2
        for r = 1, robotCount do
            robots[r].name = w[top]
            robots[r].wins = tonumber(w[top + 1])
            robots[r].losses = tonumber(w[top + 2])
            robots[r].treadColor = tonumber(w[top + 3])
            robots[r].bodyColor = tonumber(w[top + 4])
            robots[r].headColor = tonumber(w[top + 5])
            robots[r].dishColor = tonumber(w[top + 6])
            robots[r].body = math.floor(robots[r].wins / 10)
            robots[r].head = math.floor(robots[r].losses / 10)
            robots[r].tread = math.fmod(robots[r].wins , 10)
            robots[r].dish = math.fmod(robots[r].losses , 10)
            if robots[r].body == 0 then robots[r].body = 2 end
            if robots[r].head == 0 then robots[r].head = 1 end
            if robots[r].tread == 0 then robots[r].tread = 2 end
            if robots[r].dish == 0 then robots[r].dish = 1 end
            programSize = tonumber(w[top + 7])
            i = 0
            if programSize > 0 then
                for i = 1, programSize do
                    socketNum = tonumber(w[i * 3 - 2 + top + 7])
                    codeShort = w[i * 3 - 1 + top + 7]
                    value = tonumber(w[i * 3 + top + 7])
                    -- find the right code
                    code = nil
                    for d, c in ipairs(codes) do
                        if c.short == codeShort then
                            code = c
                        end
                    end
                    robots[r].program[socketNum] = Socket(code, 0, 0)
                    robots[r].program[socketNum].value = value
                end
            end
            top = top + 8 + programSize * 3
        end
    end
end

function drawMain()
    local i
    pushStyle()
    fill(0, 0, 0, 255)
    stroke(0, 69, 255, 255)
    tint(249, 249, 249, 255)

    strokeWidth(2)
    textMode(CENTER)

    fontSize(12)
    stroke(255, 255, 255, 255)
    for i = 1, 7 do
        noFill()
        noStroke()
        botFrames[i]:draw()
        robots[i + leftRobot - 1].x = botFrames[i].left + 10
        robots[i + leftRobot - 1].y = botFrames[i]:midY()
        fill(255, 255, 255, 255)
        text(robots[i + leftRobot - 1].name, botFrames[i]:midX(),
         botFrames[i].bottom+32)
    end
    codeBtn:draw()
    designBtn:draw()
    tourneyBtn:draw()
    tradeBtn:draw()

    textMode(CORNER)
    stroke(255, 255, 255, 255)

    fill(255, 255, 255, 255)
    stroke(213, 213, 213, 255)
    strokeWidth(1)
    line(arena.frame.left, arena.frame.bottom - 15,
    arena.frame:midX() - 50, arena.frame.bottom - 15)
    line(arena.frame.right, arena.frame.bottom - 15,
    arena.frame:midX() + 60, arena.frame.bottom - 15)
    line(arena.frame.left, arena.frame.bottom - 20,
    arena.frame.left, arena.frame.bottom - 10)
    line(arena.frame.right, arena.frame.bottom - 20,
    arena.frame.right, arena.frame.bottom - 10)
    fontSize(16)
    text("10.3 meters", arena.frame:midX() - 45,
    arena.frame.bottom - 25)
    stroke(255, 255, 255, 255)
    strokeWidth(1)
    if leftRobot > 1 then
        line(10, 280, 50, 310)
        line(10, 280, 50, 250)
        line(50, 310, 50, 250)
    end
    if leftRobot < 13 then
        line(WIDTH - 10, 280, WIDTH - 50, 310)
        line(WIDTH - 10, 280, WIDTH - 50, 250)
        line(WIDTH - 50, 250, WIDTH - 50, 310)
    end
    strokeWidth(1)
    popStyle()
end

function draw()
    local i, m
    noSmooth()
    background(255, 255, 255, 255)
    tint(255, 255, 255, 255)
    sprite(gridImg, 0, 0, WIDTH, HEIGHT)

    if mode == 1 then
        arena:draw()
    end

    if mode == 1 and arena.game == 1 then
        drawMain()
        for i = 1,7 do
            s = math.abs(4 - i) / 10
            robots[i + leftRobot - 1]:draw(1)
        end
    elseif mode == 2 then
        bench:draw()
        tray:draw()
        if showSlider then
            vslider:draw()
        end
        doneBtn:draw()

    elseif mode == 3 then
        studio:draw()
        doneBtn:draw()
    elseif mode == 4 then
        scheduler:draw(robots)
        doneBtn:draw()
    elseif mode == 5 then
        trader:draw(robots)
        doneBtn:draw()
    end
    -- touch handling
    if mode == 1 then
        if CurrentTouch.state == BEGAN and
            CurrentTouch.state ~= oldState then
            if arena:touched(CurrentTouch) then
            end
            if arena.stop:touched(CurrentTouch) then
                arena:sizeFrames(10, HEIGHT - 650,
                WIDTH - 10, HEIGHT - 10)
                arena:clear()
            end
            if leftBtn:touched(CurrentTouch) and leftRobot > 1 then
                leftRobot = leftRobot - 1
            end
            if rightBtn:touched(CurrentTouch) and
                leftRobot < 13 then
                leftRobot = leftRobot + 1
            end
            selectedRobot = 0
            -- check to see if a robot was selected
            for i = 1, 7 do
                if botFrames[i]:touched(CurrentTouch) then
                    selectedRobot = i + leftRobot - 1
                end
            end
        end
        if CurrentTouch.state == MOVING then
            if selectedRobot > 0 then
                robots[selectedRobot].x = CurrentTouch.x - 20
                robots[selectedRobot].y = CurrentTouch.y - 20
                robots[selectedRobot]:draw(1)
            end
        end
        if CurrentTouch.state == ENDED
        and CurrentTouch.state ~= oldState then
            if selectedRobot > 0 then
                if codeBtn:touched(CurrentTouch) then
                    bench:loadRobot(robots[selectedRobot])
                    mode = 2
                end
                if designBtn:touched(CurrentTouch) then
                    showKeyboard()
                    doneBtn.frame.top = 380
                    doneBtn.frame.bottom = 300
                    studio:setBot(robots[selectedRobot])
                    mode = 3
                end
                if tourneyBtn:touched(CurrentTouch) then
                    scheduler:loadRobot(selectedRobot)
                    selectedRobot = 0
                    mode = 4
                end
                if tradeBtn:touched(CurrentTouch) then
                    trader:loadRobot(selectedRobot)
                    selectedRobot = 0
                    mode = 5
                end
                if arena:touched(CurrentTouch) then
                    if table.maxn(arena.robots) < 4 then
                        arena:loadRobot(robots[selectedRobot],
                        CurrentTouch.x, 111)
                    else
                        sound(SOUND_BLIT, 30424)
                    end
                end

            end
        end
    end
    if mode == 2 then
        if CurrentTouch.state == BEGAN and
            CurrentTouch.state ~= oldState then
            selectedToken = 0
            -- check to see if a token was selected
            if tray:touched(CurrentTouch) then
                dragToken = Token(tray.tokens[tray.selected].code,
                CurrentTouch.x - 20, CurrentTouch.y,
                tray.tokens[tray.selected].color)
            end
            if bench:touched(CurrentTouch) then
                -- touched a socket
                c = bench.sockets[bench.selectedSocket].code
                if c ~= nil and bench.action == 0 then
                    if c.hasValue then
                        vslider = Vslider(CurrentTouch.x,
                        CurrentTouch.y,
                        bench.sockets[bench.selectedSocket].value)
                        showSlider = true
                    end
                end
                if c ~= nil and bench.action == 1 then
                    dragToken =
                    Token(bench.sockets[bench.selectedSocket].code,
                    CurrentTouch.x - 20, CurrentTouch.y,
                    bench.sockets[bench.selectedSocket].color)
                    bench.sockets[bench.selectedSocket].code = nil
                end
            end
        end
        if CurrentTouch.state == MOVING then
            if dragToken ~= nil
             then
                dragToken.x = CurrentTouch.x - 20
                dragToken.y = CurrentTouch.y
                dragToken:draw()
            end
            if showSlider then
                if vslider:touched(CurrentTouch) then
                    bench.sockets[bench.selectedSocket].value =
                    vslider.value
                end
            end
        end
        if CurrentTouch.state == ENDED
        and CurrentTouch.state ~= oldState then
            if dragToken ~= nil then
                if bench:touched(CurrentTouch) then
                    bench.sockets[bench.selectedSocket].code =
                    dragToken.code
                    sound(SOUND_HIT, 30249)
                end
                dragToken = nil
            end
            for i = 1,3 do
                if bench.mini[i]:touched(CurrentTouch) then
                    if bench.board ~= i then
                        bench.board = i
                        sound(DATA, "ZgNAZgBBASw/EiBhpHA9PqcNdD6dNtA9GAADTRUtLU4wP3wA")
                    end
                end
            end
            if showSlider then showSlider = false end
            if doneBtn:touched(CurrentTouch) then
                -- save code
                for i = 1,90 do
                    if bench.sockets[i].code ~= nil then
                        b = bench.sockets[i]
                        robots[selectedRobot].program[i] =
                        Socket(b.code, 0, 0)
                        robots[selectedRobot].program[i].value = b.value
                    else
                        robots[selectedRobot].program[i] =
                        Socket(nil, 0, 0)
                        robots[selectedRobot].program[i].value = 1
                    end
                end
                saveRobots()
                mode = 1
            end
        end
    end
    if mode == 3 then
        if CurrentTouch.state == BEGAN and
            CurrentTouch.state ~= oldState then
            -- check to see if a robot was selected
            studio:touched(CurrentTouch)
            if doneBtn:touched(CurrentTouch) then
                doneBtn.frame.top = 140
                doneBtn.frame.bottom = 60
                hideKeyboard()
                mode = 1
                saveRobots()
            end
        end
        if CurrentTouch.state == MOVING then
            studio:touched(CurrentTouch)
        end
        if CurrentTouch.state == ENDED
        and CurrentTouch.state ~= oldState then
            studio.showColorSlider = false
        end
    end
    if mode == 4 then
        if CurrentTouch.state == BEGAN and
            CurrentTouch.state ~= oldState then
            -- check to see if a robot was selected
            scheduler:touched(CurrentTouch)
            if doneBtn:touched(CurrentTouch) then
                mode = 1
                saveRobots()
            end
            if scheduler.meleeBtn:touched(CurrentTouch) then
                mode = 1
                arena:clear()
                for i = 1, 4 do
                    if scheduler.contestants[i] == 0 then
                        scheduler.contestants[i] = math.random(20)
                    end
                end
                arena:loadRobot(robots[scheduler.contestants[1]],
                60, 60)
                arena:loadRobot(robots[scheduler.contestants[2]],
                60, arena.field:height() - 60)
                arena:loadRobot(robots[scheduler.contestants[3]],
                arena.field:height() - 60, arena.field:height() - 60)
                arena:loadRobot(robots[scheduler.contestants[4]],
                arena.field:height() - 60, 60)
                arena.game = 4
                arena.tourney = true
                arena:sizeFrames(10, 60, WIDTH - 10, HEIGHT - 10)
            end
            if scheduler.skeetBtn:touched(CurrentTouch) then
                mode = 1
                arena:sizeFrames(10, 60, WIDTH - 10, HEIGHT - 10)
                arena:skeetMatch(robots[scheduler.contestants[1]])
            end
            if scheduler.mazeBtn:touched(CurrentTouch) then
                mode = 1
                arena:sizeFrames(10, 60, WIDTH - 10, HEIGHT - 10)
                arena:mazeRace(robots[scheduler.contestants[1]])
            end
        end
        if CurrentTouch.state == MOVING then
            scheduler:touched(CurrentTouch)
        end
        if CurrentTouch.state == ENDED
        and CurrentTouch.state ~= oldState then
            scheduler.showSlider = false
        end
    end
    if mode == 5 then
        if CurrentTouch.state == BEGAN and
            CurrentTouch.state ~= oldState then
            -- check to see if a robot was selected
            trader:touched(CurrentTouch)
            if doneBtn:touched(CurrentTouch) then
                mode = 1
                saveRobots()
            end
        end
        if CurrentTouch.state == MOVING then
            trader:touched(CurrentTouch)
        end
        if CurrentTouch.state == ENDED
        and CurrentTouch.state ~= oldState then

        end
    end
    oldState = CurrentTouch.state

end

function keyboard(key)
    if mode == 3 then
        if key ~= nil then
            if string.byte(key) == 10 then
                --
            else
                if string.byte(key) ~= 44 then -- filter out commas
                    studio.tb:acceptKey(key)
                end
            end
        end
    end
end
