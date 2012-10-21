-- Project: Backgammon
-- Author and (c): frosty
-- Link: http://twolivesleft.com/Codea/Talk/discussion/835/backgammon/p1
-- Link: https://gist.github.com/2346693

--# Counter
CTYPE_WHITE = 0
CTYPE_BLACK = 1
CTYPE_PLACEWHITE = 2
CTYPE_PLACEBLACK = 3

Counter = class()

function Counter:init(x, y, t)
    self.pos = vec2(x,y)
    self.selected = false
    self.c = color(255, 0, 0, 255)
    self:changeType(t)
end

function Counter:changeType(type)
    self.t = type
    if self.t == CTYPE_WHITE then
        self.c = color(222, 222, 222, 255)
    elseif self.t == CTYPE_BLACK then
        self.c = color(21, 21, 21, 255)
    elseif self.t == CTYPE_PLACEWHITE then
        self.c = color(221, 221, 221, 37)
    elseif self.t == CTYPE_PLACEBLACK then
        self.c = color(21, 21, 21, 147)
    end
end

function Counter:draw()
    pushStyle()

    strokeWidth(1)
    stroke(74, 74, 74, 255)
    fill(self.c)
    ellipseMode(CENTER)
    ellipse(self.pos.x, self.pos.y, 80, 80)
    popStyle()
end

function Counter:touched(touch)
    local dist = self.pos:dist(vec2(touch.x, touch.y))
    if dist < 40 then
        return true
    else
        return false
    end
end

--# Dice
Dice = class()

DICEWIDTH = 60

function Dice:init(x, y)
    self.pos = vec2(x,y)
    self.value = 1
    self.rolling = false
    self.delay = 0
end

function Dice:draw()
    if self.rolling then
        self.delay = self.delay + DeltaTime
        if self.delay > 0.1 then
            self.value = math.random(1,6)
            self.delay = 0
        end
    end

    pushMatrix()
    pushStyle()
    translate(self.pos.x, self.pos.y)
    rectMode(CENTER)
    ellipseMode(RADIUS)
    noStroke()
    fill(255, 255, 255, 255)
    rect(0,0,DICEWIDTH,DICEWIDTH)

    fill(0, 0, 0, 255)

    if self.value == 1 then
        ellipse(0, 0, 6)
    elseif self.value == 2 then
        ellipse(-DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, -DICEWIDTH/4, 6)
    elseif self.value == 3 then
        ellipse(0, 0, 6)
        ellipse(-DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, -DICEWIDTH/4, 6)
    elseif self.value == 4 then
        ellipse(-DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, -DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(-DICEWIDTH/4, -DICEWIDTH/4, 6)
    elseif self.value == 5 then
        ellipse(0, 0, 6)
        ellipse(-DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, -DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(-DICEWIDTH/4, -DICEWIDTH/4, 6)
    elseif self.value == 6 then
        ellipse(-DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, -DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, DICEWIDTH/4, 6)
        ellipse(-DICEWIDTH/4, -DICEWIDTH/4, 6)
        ellipse(DICEWIDTH/4, 0, 6)
        ellipse(-DICEWIDTH/4, 0, 6)
    end

    popStyle()
    popMatrix()
end

function Dice:touched(touch)
    if (touch.x > (self.pos.x-30)) and touch.x < (self.pos.x + 30) and
        touch.y > (self.pos.y-30) and touch.y < (self.pos.y + 30) then
            return true
        else
            return false
        end
end

function Dice:toggle()
    if self.rolling then
        self.rolling = false
        self.value = math.random(1,6)
    else
        self.rolling = true
    end
end

--# Tri
Tri = class()

function Tri:init(x, y, c, down)
    self.pos = vec2(x, y)
    self.c = c
    self.down = down
    self.m = trimesh
    self.stack = { }
    self.numItems = 0
    self.highlighted = false
end

function Tri:top()
    if self.numItems > 0 then
        return self.stack[self.numItems]
    else
        return nil
    end
end

function Tri:push(type)
    if self.numItems == 1 then
        local item = self:top()
        if item then
            if not (item.t == type) then
                self:pop()
                if item.t == CTYPE_WHITE then
                    pool1:push(item.t)
                else
                    pool2:push(item.t)
                end
            end
        end
    end

    table.insert(self.stack, Counter(0,0,type))
    self.numItems = self.numItems + 1

end

function Tri:pop()
    if self.numItems > 0 then
    table.remove(self.stack)
    self.numItems = self.numItems - 1
    end
end

function Tri:highlight(type)
    if not self.highlighted then
        if type == CTYPE_WHITE then
            self:push(CTYPE_PLACEWHITE)
        elseif type == CTYPE_BLACK then
            self:push(CTYPE_PLACEBLACK)
        end
    end
    self.highlighted = true
end

function Tri:unhighlight()
    if self.highlighted then
        self:pop()
        self.highlighted = false
    end
end

function Tri:pickup()
    local top = self:top()
    if top then
        local returnCounter = Counter(0,0,top.t)
        if top.t == CTYPE_WHITE then
            top:changeType(CTYPE_PLACEWHITE)
        elseif top.t == CTYPE_BLACK then
            top:changeType(CTYPE_PLACEBLACK)
        end
        return returnCounter
    else
        return nil
    end
end

function Tri:touched(touch)
    if not self.down then
        if touch.x > self.pos.x - 40 and touch.x < self.pos.x + 40 and
           touch.y > self.pos.y and touch.y < self.pos.y + 320 then
            return true
        end
    else
        if touch.x > self.pos.x - 40 and touch.x < self.pos.x + 40 and
           touch.y > self.pos.y - 320 and touch.y < self.pos.y then
            return true
        end
    end
    return false
end

function Tri:draw()
    pushMatrix()
    pushStyle()
        translate(self.pos.x, self.pos.y)
        if self.down then
            scale(80,-80)
        else
            scale(80)
        end

        if (self.selected) then
            self.m:setColors(color(0,255,0,255))
           -- zLevel(100)
        else
            self.m:setColors(self.c)
        end

        self.m:draw()

        popStyle()
        popMatrix()

        pushMatrix()
        --zLevel(1)
        translate(self.pos.x, self.pos.y)
        if self.down then
            scale(1,-1)
        end
        for i,v in ipairs(self.stack) do
            pushMatrix()
            pushStyle()
            translate(0,40*i)
            v:draw()
            popStyle()
            popMatrix()
        end

    popMatrix()
end
--# CenterRect
CenterRect = class(Tri)

function CenterRect:init(x, y, c)
    self.pos = vec2(x, y)
    self.c = c
    self.stack = { }
    self.numItems = 0
    self.highlighted = false
    self.hw = 100
    self.hh = 35
end

function CenterRect:draw()
    pushStyle()

    noStroke()
    fill(self.c)
    rectMode(CENTER)
    rect(self.pos.x, self.pos.y, self.hw*2, self.hh*2)
    popStyle()

    for i,v in ipairs(self.stack) do
        pushMatrix()
        pushStyle()
        translate(self.pos.x-self.hw+(20*i), self.pos.y)
        v:draw()
        popStyle()
        popMatrix()
    end
end

function CenterRect:touched(touch)
    if touch.x > self.pos.x - self.hw and touch.x < self.pos.x + self.hw and
           touch.y > self.pos.y - self.hh and touch.y < self.pos.y + self.hh then
            return true
        end
    return false
end

function CenterRect:push(type)
    table.insert(self.stack, Counter(0,0,type))
    self.numItems = self.numItems + 1
end

--# Main
displayMode(FULLSCREEN)
supportedOrientations(LANDSCAPE_ANY)

function setup()
    dice1 = Dice((WIDTH/2)-50, HEIGHT/2)
    dice2 = Dice((WIDTH/2)+50, HEIGHT/2)

    pool1 = CenterRect(WIDTH/4, HEIGHT/2, color(46, 46, 46, 255))
    pool2 = CenterRect(3*(WIDTH/4), HEIGHT/2, color(232, 17, 7, 255))

    trimesh = mesh()
    trimesh.vertices = {vec2(-0.5, 0), vec2(0.5, 0), vec2(0, 4) }

    tris = {}
    for i = 1,12,4 do
        local t = Tri(40*i, 0, color(232, 17, 7, 255) )
        table.insert(tris, t)

        local t2 = Tri((40*i)+80, 0, color(46, 46, 46, 255) )
        table.insert(tris, t2)

        local tt = Tri(40*i, HEIGHT, color(46, 46, 46, 255), true )
        table.insert(tris, tt)

        local tt2 = Tri((40*i)+80, HEIGHT, color(232, 17, 7, 255), true )
        table.insert(tris, tt2)
    end

    for i = 1,12,4 do
        local t = Tri(544 + (40*i), 0, color(232, 17, 7, 255) )
        table.insert(tris, t)

        local t2 = Tri(544 + (40*i)+80, 0, color(46, 46, 46, 255) )
        table.insert(tris, t2)

        local tt = Tri(544 + (40*i), HEIGHT, color(46, 46, 46, 255), true)
        table.insert(tris, tt)

        local tt2 = Tri(544 + (40*i)+80, HEIGHT, color(232, 17, 7, 255) , true)
        table.insert(tris, tt2)
    end

    table.sort(tris, function(one, two)
           return (one.pos.y > two.pos.y) or ((one.pos.y == two.pos.y) and (one.pos.x < two.pos.x))
        end)

    local whites = {5,0,0,0,0,0,0,0,0,0,0,2,
                    0,0,0,0,3,0,5,0,0,0,0,0}
    local blacks = {0,0,0,0,3,0,5,0,0,0,0,0,
                    5,0,0,0,0,0,0,0,0,0,0,2}

    for i, v in ipairs(tris) do
        if whites[i] > 0 then
            for j = 1, whites[i] do
                v:push(CTYPE_WHITE)
            end
        elseif blacks[i] > 0 then
            for j = 1, blacks[i] do
                v:push(CTYPE_BLACK)
            end
        end
    end

    table.insert(tris, pool1)
    table.insert(tris, pool2)
end

function draw()
    background(225, 206, 119, 255)

    dice1:draw()
    dice2:draw()

    for i,v in ipairs(tris) do
        v:draw()
    end

    if grabbed then
        grabbed:draw()
    end
end

function touched(touch)
    if (dice1:touched(touch) or dice2:touched(touch)) and touch.state == ENDED then
        dice1:toggle()
        dice2:toggle()
        return
    end
    if touch.state == BEGAN and not grabbed then
        for i,v in ipairs(tris) do
            if v:touched(touch) then
                grabbed = v:pickup()
                originTri = v
                break
            end
        end
        if grabbed then grabbed.pos = vec2(touch.x, touch.y) end
    elseif touch.state == MOVING then
        if grabbed then
            grabbed.pos = vec2(touch.x, touch.y)
        end
    elseif touch.state == ENDED then
        if grabbed then
            grabbed.pos = vec2(touch.x, touch.y)
            for i,v in ipairs(tris) do
                if v:touched(touch) then
                    originTri:pop()
                    v:push(grabbed.t)
                    grabbed = nil
                    originTri = nil
                    break
                end
            end
        end
    end
end