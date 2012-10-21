-- Project: Pastel Bon Bons
-- Author and (c): mpilgrem
-- Link: http://www.twolivesleft.com/Codea/Talk/discussion/1781

--
-- Pastel Bon Bons
--

-- A function to generate a spectrum of pastel colours
-- h is [0, 1); strength is [0, 1]
function pastelH2RGB(h, strength)
    local s = strength / 2 + 0.25
    local r, g, b = 1, 1, 1
    local i = h * 3
    local x = (i % 1) * (1 - s)
    if i < 1 then r, g = 1 - x, s + x
    elseif i < 2 then r, b = s + x, 1 - x
    else g, b = 1 - x, s + x end
    return color(255 * r, 255 * g, 255 * b)
end

displayMode(STANDARD)
supportedOrientations(LANDSCAPE_ANY)
function setup()
    -- Vary the pastel strength
    parameter("pastelStrength", 0, 1, 0.5)
    dim = math.min(WIDTH, HEIGHT) * 0.8 / 2
    sn = 100
    n = 20
    local l = 80
    sImg = image(l, l)
    setContext(sImg)
    translate(l/2, l/2)
    for j = 50, l, 3 do
        fill(0, 8)
        ellipse(0, 0, j)
    end
    setContext()
    sw = {}
    for i = 1, sn do
        sw[i] = {}
        sw[i].x, sw[i].y = math.random(WIDTH), math.random(HEIGHT)
        sw[i].vx = math.random(3) * (math.random(2) * 2 - 3)
        sw[i].vy = math.random(3) * (math.random(2) * 2 - 3)
        sw[i].dx = math.random(50) + 50
        sw[i].dy = math.random(50) + 50
        sw[i].c = math.random()
    end
end

function draw()
    moveSwatches()
    background(0)
    drawSwatches(pastelStrength)
end

function moveSwatches()
    for i = 1, sn do
        sw[i].x, sw[i].y = sw[i].x + sw[i].vx, sw[i].y + sw[i].vy
        if sw[i].x < 1 or sw[i].x > WIDTH then
            sw[i].x = math.max(1, math.min(sw[i].x, WIDTH))
            sw[i].vx = - sw[i].vx
        end
        if sw[i].y < 1 or sw[i].y > HEIGHT then
            sw[i].y = math.max(1, math.min(sw[i].y, HEIGHT))
            sw[i].vy = - sw[i].vy
        end
    end
end

function drawSwatches(strength)
    for i = 1, sn do
        fill(pastelH2RGB(sw[i].c, strength))
        resetMatrix()
        translate(sw[i].x, sw[i].y)
        rotate(ElapsedTime * sw[i].dx)
        ellipse(0, 0, sw[i].dx, sw[i].dy)
    end
    resetMatrix()
    translate(WIDTH / 2, HEIGHT / 2)
    for i = 0, n - 1 do
        local a = i / n * 2 * math.pi + ElapsedTime / 10
        local x, y = dim * math.cos(a), dim * math.sin(a)
        sprite(sImg, x - 5, y - 5)
    end
    for i = 0, n - 1 do
        local a = i / n * 2 * math.pi + ElapsedTime / 10
        local x, y = dim * math.cos(a), dim * math.sin(a)
        fill(pastelH2RGB(i / n, strength))
        ellipse(x, y, 50)
    end
end
