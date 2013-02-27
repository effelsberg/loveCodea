-- -- ---- ------ ---------- ---------------- --------------------------
--
-- This file is part of loveCodea.
-- Copyright 2012 Stephan Effelsberg
-- Licensed under the MIT license:
--     http://www.opensource.org/licenses/mit-license.php
--
-- -- ---- ------ ---------- ---------------- --------------------------


------------------------
-- loveCodea SETTINGS
------------------------

-- This is shorter than a loveCodea namespace.
-- Also, I'm a mad scientist, "un científico loco".
loco = {}

if loco.SCALE == nil then
    loco.SCALE = 1
end

--------------------------------------------------
--[[ CODEA Constants, Variables and Functions ]]--
--------------------------------------------------

CORNER  = 0
CORNERS = 1
CENTER  = 2
RADIUS  = 3

LEFT    = 0
RIGHT   = 1

BEGAN   = 1
MOVING  = 2
ENDED   = 4

--HEIGHT  = 748
--WIDTH   = 748

STANDARD   = 0
FULLSCREEN = 1
FULLSCREEN_NO_BUTTONS = 2

PORTRAIT_ANY         = 0
PORTRAIT_UPSIDE_DOWN = 1
LANDSCAPE_LEFT       = 2
LANDSCAPE_RIGHT      = 3
PORTRAIT             = 4
LANDSCAPE_ANY        = 5
ANY                  = 6

ROUND      = 0
SQUARE     = 1
STATIONARY = 3
PROJECT    = 2

--[[
SOUND_BLIT = "blit"
SOUND_EXPLODE = "explode"
SOUND_HIT = "hit"
SOUND_JUMP = "jump"
SOUND_PICKUP = "pickup"
SOUND_RANDOM = "random"
SOUND_SHOOT = "shoot"
--]]
SOUND_BLIT    = "sounds/blit.ogg"
SOUND_EXPLODE = "sounds/explode.ogg"
SOUND_HIT     = "sounds/hit.ogg"
SOUND_JUMP    = "sounds/jump.ogg"
SOUND_PICKUP  = "sounds/pickup.ogg"
SOUND_RANDOM  = "sounds/random.ogg"
SOUND_SHOOT   = "sounds/shoot.ogg"
loco.soundCache = {}

DeltaTime   = 0
ElapsedTime = 0

point = point or function() end
pointSize = pointSize or function() end
rsqrt = rsqrt or function() end
setInstructionLimit = setInstructionLimit or function() end
setup = setup or function() end
UserAcceleration = {} --[[ (0.000000, 0.000000, 0.000000)]]--
zLevel = zLevel or function() end


CurrentTouch = {}
CurrentTouch.x = 0
CurrentTouch.y = 0
CurrentTouch.prevX = 0
CurrentTouch.prevY = 0
CurrentTouch.deltaX = 0
CurrentTouch.deltaY = 0
CurrentTouch.id = 0
CurrentTouch.state = ENDED
CurrentTouch.tapCount = 0

Gravity = {}
Gravity.x = 0
Gravity.y = 0
Gravity.z = 0
Gravity.y = -1

-------------------
-- Sound
-------------------

function sound(name)
    if name == nil then return end
    local cachedSound = loco.soundCache[name];

    if not cachedSound then
        if love.filesystem.isFile(name) then
            local data = love.sound.newSoundData(name)
            cachedSound = love.audio.newSource(data)
            --cachedSound = love.audio.newSource(name, "static");
            loco.soundCache[name] = cachedSound;
        end
    end

    if cachedSound then
        love.audio.play(cachedSound);
    end
end

function soundBufferSize()
    return 1000, 500
end

-------------------
-- Math
-------------------

function rsqrt(value)
    return math.pow(value, -0.5);
end

-------------------
-- love functions
-------------------
function love.load()
    --fontSize(17)
    --love.graphics.setLine(1, "rough")
    --noTint()
    --noStroke()
    --fill(128, 128, 128, 255)
    --stroke(255, 255, 255, 255)
    love.graphics.setColorMode("modulate")
    loco.setupCurrentContext()
    setup()
    loco.teardownCurrentContext()
    love.graphics.setCanvas()
end

--[[
-- Love 0.8.0: events are processed BEFORE update()!
-- All touch processing now done in update().
function love.mousepressed(x, y, button)
    if button == "l" then
        CurrentTouch.state = BEGAN
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
        CurrentTouch.state = ENDED
    end
end
]]--

function love.keypressed(key)
    if loco.focus ~= nil then
        loco.parameterKeyboard(key)
    elseif love.keyboard.isDown("lctrl", "rctrl") then
        if key == "h" then
            loco.showhud = not loco.showhud
        elseif key == "8" then
            loco.SCALE = loco.SCALE / 1.1
            loco.updateDisplayDimensions()
        elseif key == "9" then
            loco.SCALE = loco.SCALE * 1.1
            loco.updateDisplayDimensions()
        elseif key == "0" then
            loco.SCALE = 1
            loco.updateDisplayDimensions()
        end
        return
    elseif keyboard then
        if string.len(key) == 1 then
            if love.keyboard.isDown("lshift", "rshift") then
                key = key:upper()
            end
            keyboard(key)
        elseif key == "return" then
            keyboard("\n")
        elseif key == "backspace" then
            keyboard("")
        end
    end
end

loco.touch_is_in_output = false
loco.focus = nil

function love.update(dt)

    -- Use sleep to cap FPS at 60
    if dt < 1/60 then
        love.timer.sleep(1/60 - dt)
        dt = 1/60
    end

    -- use Mouse for Touch interaction
    local touch_changed = false
    if love.mouse.isDown("l") then
        -- get Mouse position as Touch position
        -- publish globally
        local mousex = love.mouse.getX() / loco.SCALE - loco.mainwinoffset
        local mousey = HEIGHT - 1 - love.mouse.getY() / loco.SCALE
        mousey = mousey - loco.win_y_offset

        if CurrentTouch.x ~= mousex or CurrentTouch.y ~= mousey then
            touch_changed = true
        end
        if CurrentTouch.state == ENDED then
            touch_changed = true
        end
        if touch_changed then
            CurrentTouch.prevX = CurrentTouch.x
            CurrentTouch.prevY = CurrentTouch.y
            CurrentTouch.x = mousex
            CurrentTouch.y = mousey
            if CurrentTouch.state == ENDED then
                CurrentTouch.state = BEGAN
                CurrentTouch.prevX = CurrentTouch.x
                CurrentTouch.prevY = CurrentTouch.y
                CurrentTouch.deltaX = 0
                CurrentTouch.deltaY = 0
                CurrentTouch.tapCount = CurrentTouch.tapCount + 1
                loco.touch_is_in_output = mousex < 0
                loco.focus = nil
            else
                CurrentTouch.state = MOVING
                CurrentTouch.deltaX = CurrentTouch.x - CurrentTouch.prevX
                CurrentTouch.deltaY = CurrentTouch.y - CurrentTouch.prevY
            end
        end
    else
        if CurrentTouch.state ~= ENDED then
            CurrentTouch.state = ENDED
            touch_changed = true
        end
    end

    -- has to be outside of mouse.isDown
    if touched and touch_changed and not loco.touch_is_in_output then
        -- publish to touched callback
        local touch = {}
        touch.x = CurrentTouch.x
        touch.y = CurrentTouch.y
        touch.prevX  = CurrentTouch.prevX
        touch.prevY  = CurrentTouch.prevY
        touch.deltaX = CurrentTouch.deltaX
        touch.deltaY = CurrentTouch.deltaY
        touch.state  = CurrentTouch.state
        touch.tapCount = CurrentTouch.tapCount
        touch.id = 1
        loco.setupCurrentContext()
        touched(touch)
        loco.teardownCurrentContext()
        love.graphics.setCanvas()
    end

    if touch_changed and loco.displaymode == STANDARD and loco.touch_is_in_output then
        -- Parameter Widgets expect 0,0 in the upper left corner
        local touch = {}
        touch.x = CurrentTouch.x
        touch.y = CurrentTouch.y
        touch.state  = CurrentTouch.state
        touch.id = 1
        touch.x = touch.x + loco.mainwinoffset
        touch.y = HEIGHT - touch.y
        --print(touch.x .. "  " .. touch.y)
        loco.touchOutputpane(touch)
    end

    -- use Up,Down,Left,Right Keys to change Gravity
    if love.keyboard.isDown("up") then
        if love.keyboard.isDown("lshift", "rshift") then
            loco.win_y_offset = 300
        else
            Gravity.y = Gravity.y + 0.01
        end
    elseif love.keyboard.isDown("down") then
        if love.keyboard.isDown("lshift", "rshift") then
            loco.win_y_offset = 0
        else
            Gravity.y = Gravity.y - 0.01
        end
    elseif love.keyboard.isDown("left") then
        --Gravity.x = Gravity.x + 0.01
        Gravity.x = Gravity.x - 0.01
    elseif love.keyboard.isDown("right") then
        --Gravity.x = Gravity.x - 0.01
        Gravity.x = Gravity.x + 0.01
    elseif love.keyboard.isDown("pageup") then
        Gravity.z = Gravity.z + 0.01
    elseif love.keyboard.isDown("pagedown") then
        Gravity.z = Gravity.z - 0.01
    end

    -- set Time Values
    DeltaTime = love.timer.getDelta()
    ElapsedTime = love.timer.getTime()

    loco.updatePhysics(dt)
    tween.update(dt)
end

function love.draw()
    loco.setupCurrentContext()
    draw()
    loco.teardownCurrentContext()
    love.graphics.setCanvas()

    if loco.displaymode == STANDARD then
        pushStyle()
        love.graphics.push()
        love.graphics.setScissor(0, 0, loco.mainwinoffset * loco.SCALE, 10000)
        love.graphics.scale(loco.SCALE, loco.SCALE)
        loco.drawOutputpane()
        love.graphics.setScissor()
        if loco.showhud then
            loco.drawHud()
        end
        love.graphics.pop()
        popStyle()
    end
    love.graphics.setScissor()
end

function loco.drawOutputpane()
    fontSize(12)

    -- background
    love.graphics.setColor(59, 61, 66)
    love.graphics.rectangle("fill", 0, 0, loco.mainwinoffset - 1, HEIGHT)

    -- draw paramters
    loco.drawParameterWidgets()
    --for _,w in ipairs(loco.parameterWidgetList) do
    --    w:draw()
    --end

    -- frame around pane
    --love.graphics.setColor(125, 125, 125)
    --love.graphics.setLine(2, "rough")
    --love.graphics.rectangle("line", 0, 0, loco.mainwinoffset - 1, HEIGHT)
end

function loco.touchOutputpane(touch)
    for _,w in ipairs(loco.parameterWidgetList) do
        w:touched(touch)
    end
end

function loco.drawHud()
    -- print FPS
    love.graphics.setColor(255,0,0,255)
    local x = loco.totalwidth - 100
    love.graphics.print("FPS: " .. love.timer.getFPS(), x, 5)

    -- print Gravity
    love.graphics.print("GravityX: " .. Gravity.x, x, 40)
    love.graphics.print("GravityY: " .. Gravity.y, x, 60)
    love.graphics.print("GravityZ: " .. Gravity.z, x, 80)
end

-------------------------
-- loveCodify Internals
-------------------------

-- deepcopy http://lua-users.org/wiki/CopyTable
function loco.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

loco.displaymode = STANDARD
loco.orient = LANDSCAPE_ANY
loco.displayw = 0
loco.displayh = 0
loco.mainwinoffset = 0
loco.win_y_offset = 0
loco.showhud = false

function displayMode(mode)
    loco.displaymode = mode
    loco.updateDisplayDimensions()
end

function supportedOrientations(orient)
    loco.orient = orient
    loco.updateDisplayDimensions()
end

function loco.updateDisplayDimensions()
    if loco.orient == PORTRAIT or loco.orient == PORTRAIT_ANY or
        loco.orient == PORTRAIT_UPSIDE_DOWN then
        loco.totalwidth  =  768
        loco.totalheight = 1024
        WIDTH  =  768
        HEIGHT = 1024
        if loco.displaymode == STANDARD then
            WIDTH = WIDTH - 274
            loco.mainwinoffset = 274
        else
            loco.mainwinoffset = 0
        end
    else
        loco.totalwidth  = 1024
        loco.totalheight =  768
        WIDTH  = 1024
        HEIGHT =  768
        if loco.displaymode == STANDARD then
            WIDTH = WIDTH - 274
            loco.mainwinoffset = 274
        else
            loco.mainwinoffset = 0
        end
    end
    -- avoid flickering
    local displayw = loco.totalwidth * loco.SCALE
    local displayh = loco.totalheight * loco.SCALE
    if displayw ~= loco.displayw or displayh ~= loco.displayh then
        loco.displayw = displayw
        loco.displayh = displayh
        love.graphics.setMode(displayw, displayh)
    end
end

function backingMode(mode)
end

function showKeyboard()
end

function hideKeyboard()
end

function isKeyboardShowing()
    return false
end

function clearOutput()
end

output = {}
function output.clear()
end
