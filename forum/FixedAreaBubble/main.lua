-- Project: Fixed-area Bubble
-- Author and (c): mpilgrem
-- Link: http://twolivesleft.com/Codea/Talk/discussion/1572/fixed-area-bubble%3A-an-experiment-with-2d-soft-bodies/p1

--
-- Fixed-Area Bubble in Lua for Codea
--
-- Based on E W Jordan's algorithm implemented in Processing
-- http://www.ewjordan.com/processing/VolumeBlob/ConstantAreaBlob.pde
-- Licence: Unknown
--

supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN)
function setup()
    twoPi   = 2 * math.pi
    epsilon = .0001
    g       = 9.8 * 3 -- Gravity

    l = 10            -- Left edge
    r = WIDTH - 10    -- Right edge
    b = 10            -- Bottom edge
    t = HEIGHT - 10   -- Top edge

    tRadius = 50      -- Size of touch circle
    tX = WIDTH/4      -- Position of touch circle
    tY = HEIGHT/4
    tvX = 0           -- Velocity of touch circle
    tvY = 0
    k = 3             -- Spring strength
    drag = 2          -- Drag on movement
    destX = tX        -- Destination of touch circle
    destY = tY

    jForce = 200      -- Strength of jump, if double-tapped

    n           = 40  -- Number of points in bubble
    bRadius     = 100 -- Size of bubble
    nIters  = 5
    relax   = 0.9

    setupBubble()     -- Create the bubble
    textMode(CORNER)
end

function draw()
    respondToEvents()
    integrate(DeltaTime)
    constrainEdges()
    collideWithWalls()
    collideWithTouch()
    updateTouch(DeltaTime)

    background(0)
    fill(255)
    text("Fixed-area Bubble (with acknowledgements to E W Jordan)",
        10 , HEIGHT - 25)
    drawBubble()
    drawTouch()
end

function touched(touch)
    if isInsideBubble(touch.x, touch.y) then
        if touch.tapCount == 2 and touch.state == ENDED and
            hitFloor then
            jump = true
        end
    else
        destX = touch.x
        destY = touch.y
    end
end

function isInsideBubble(pX, pY)
    for i = 1, n do
        local c = (pY - y[i]) * (x[i % n + 1] - x[i]) -
            (pX - x[i]) * (y[i % n + 1] - y[i])
        if c > 0 then return false end
    end
    return true
end

function updateTouch(dt)
    local fX = (destX - tX) * k - tvX * drag
    local fY = (destY - tY) * k - tvY * drag
    tvX = tvX + fX * dt
    tvY = tvY + fY * dt
    tX = tX + tvX * dt
    tY = tY + tvY * dt
end

function respondToEvents()
    if jump and hitFloor then
        local cmx = 0
        local cmy = 0
        for i = 1, n do
            cmx = cmx + x[i]
            cmy = cmy + y[i]
        end
        cmx = cmx / n
        cmy = cmy / n
        for i = 1, n do
            ax[i] = ax[i] - (x[i] - cmx) * jForce
        end
        jump = false
    end
end

function drawTouch()
    stroke(0, 240, 255)
    strokeWidth(5)
    noFill()
    ellipse(tX, tY, 2 * tRadius)
end

function drawBubble()
    fill(255)
    stroke(255)
    strokeWidth(5)
    for i = 1, n do
        line(x[i], y[i], x[i % n + 1], y[i % n + 1])
    end
end

function setupBubble()
    x = {}
    y = {}
    xLast = {}
    yLast = {}
    ax = {}
    ay = {}

    local cx = WIDTH/2
    local cy = HEIGHT/2

    for i = 1, n do
        local a = (i - 1)/n * twoPi
        x[i] = cx + math.sin(a) * bRadius
        y[i] = cy + math.cos(a) * bRadius
        xLast[i] = x[i]
        yLast[i] = y[i]
        ax[i] = 0
        ay[i] = 0
    end
    local dx = x[2] - x[1]
    local dy = y[2] - y[1]
    len = math.sqrt(dx * dx + dy * dy)
    bubbleAreaTarget = bubbleArea()
end

function fixEdge()
    local dx = {}
    local dy = {}
    for i = 1, n do
        dx[i] = 0
        dy[i] = 0
    end
    for count = 1, nIters do
        for i = 1, n do
            local j = i % n + 1
            local eX = x[j] - x[i]
            local eY = y[j] - y[i]
            local d = math.sqrt(eX * eX + eY * eY)
            if d < epsilon then d = 1 end
            local ratio = 1 - len / d
            dx[i] = dx[i] + relax * eX * ratio / 2
            dy[i] = dy[i] + relax * eY * ratio / 2
            dx[j] = dx[j] - relax * eX * ratio / 2
            dy[j] = dy[j] - relax * eY * ratio / 2
        end
        for i = 1, n do
            x[i] = x[i] + dx[i]
            y[i] = y[i] + dy[i]
            dx[i] = 0
            dy[i] = 0
        end
    end
end

function constrainEdges()
    fixEdge()
    local edge = 0
    local nx = {}
    local ny = {}
    for i = 1, n do
        local j = i % n + 1
        local dx = x[j] - x[i]
        local dy = y[j] - y[i]
        local d = math.sqrt(dx * dx + dy * dy)
        if d < epsilon then d = 1 end
        nx[i] =  dy / d
        ny[i] = -dx / d
        edge = edge + d
    end
    local dArea = bubbleAreaTarget - bubbleArea()
    local dH = 0.5 * dArea / edge
    for i = 1, n do
        local j = i % n + 1
        x[j] = x[j] + dH * (nx[i] + nx[j])
        y[j] = y[j] + dH * (ny[i] + ny[j])
    end
end

function bubbleArea()
    local area = 0
    for i= 1, n do
        area = area + x[i] * y[i % n + 1] - x[i % n + 1] * y[i]
    end
    area = area/2
    return area
end

function integrate(dt)
    local dtSqr = dt * dt
    for i = 1, n do
        local tempX = x[i]
        local tempY = y[i]
        x[i] = 2 * x[i] - xLast[i] + ax[i] * dtSqr
        y[i] = 2 * y[i] - yLast[i] + ay[i] * dtSqr - g * dtSqr
        xLast[i] = tempX
        yLast[i] = tempY
        ax[i] = 0
        ay[i] = 0
    end
end

function collideWithWalls()
    hitFloor = false
    for i = 1, n do
        if x[i] < l then x[i] = l end
        if x[i] > r then x[i] = r end
        if y[i] < b then
            y[i] = b
            xLast[i] = x[i]
            hitFloor = true
        end
        if y[i] > t then y[i] = t end
    end
end

function collideWithTouch()
    for i = 1, n do
        local dx = tX - x[i]
        local dy = tY - y[i]
        local dSqr = dx * dx + dy * dy
        if not (dSqr > tRadius*tRadius or
            dSqr < epsilon * epsilon) then
            local d = math.sqrt(dSqr)
            x[i] = x[i] - dx * (tRadius/d - 1)
            y[i] = y[i] - dy * (tRadius/d - 1)
        end
    end
end
