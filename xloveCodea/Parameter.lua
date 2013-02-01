-- -- ---- ------ ---------- ---------------- --------------------------
--
-- This file is part of loveCodea.
-- Copyright 2012 Stephan Effelsberg
-- Licensed under the MIT license:
--     http://www.opensource.org/licenses/mit-license.php
--
-- -- ---- ------ ---------- ---------------- --------------------------


-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Parameters
--
-- Implements public Codea API:
--   parameter.number()
--   parameter.integer()
--   parameter.watch()
--   parameter.action()
--   parameter.text()
-- Deprecated for Codea >= 1.5:
--   iparameter()
--   parameter()
--   watch()
--
-- -- ---- ------ ---------- ---------------- --------------------------

parameter = {}

loco.width_of_output_pane = 274

-- Codea <  1.5: parameter is a function.
-- Codea >= 1.5: parameter is a namespace (table). If called as a function,
-- it will give a deprecation warning.

-- Implement deprecation warning for parameter and call parameter.number
-- if the table is called.
loco.parameter_mt = {}
setmetatable(parameter, loco.parameter_mt)
loco.parameter_mt.__call = function(t, ...)
    print("function `parameter´ is deprecated. Please use `parameter.number´ instead.")
    parameter.number(...)
end

-- Deprecated function iparameter
function iparameter(...)
    print("function `iparameter´ is deprecated. Please use `parameter.integer´ instead.")
    parameter.integer(...)
end

-- Deprecated function watch
function watch(...)
    print("function `watch´ is deprecated. Please use `parameter.watch´ instead.")
    parameter.watch(...)
end

loco.parameterCount = 0
loco.parameterWidgetList = {}

function clearParameters()
    loco.parameterCount = 0
    loco.parameterWidgetList = {}
end

function parameter.integer(name, min, max, initial)
    if min == nil then
        min = 0
        max = 10
    end
    if initial == nil then
        initial = min
    end
    _G[name] = initial
    local w = ParameterWidget(0, 0, name, min, max, "int")
    loco.addParameterWidget(w)
end

function parameter.number(name, min, max, initial)
    if min == nil then
        min = 0
        max = 1
    end
    if initial == nil then
        initial = min
    end
    _G[name] = initial
    local w = ParameterWidget(0, 0, name, min, max, "float")
    loco.addParameterWidget(w)
end

function parameter.watch(name)
    local w = WatchParameterWidget(0, 0, name)
    loco.addParameterWidget(w)
end

function parameter.text(name, initial)
    if initial == nil then
        initial = ""
    end
    _G[name] = initial
    local w = TextParameterWidget(0, 0, name)
    loco.addParameterWidget(w)
end

function parameter.action(text, callback)
    local w = ActionParameterWidget(0, 0, text, callback)
    loco.addParameterWidget(w)
end

function loco.addParameterWidget(w)
    loco.parameterCount = loco.parameterCount + 1
    table.insert(loco.parameterWidgetList, w)
end

function loco.drawParameterWidgets()
    local y = 0
    for _,w in ipairs(loco.parameterWidgetList) do
        w.y = y
        w:draw()
        y = y + w.h
        -- divider line
        love.graphics.setLineWidth(2)
        love.graphics.setLineStyle("rough")
        love.graphics.setColor(79, 81, 85, 255)
        love.graphics.line(0, y + 1, loco.width_of_output_pane - 1, y + 1)
        y = y + 2
    end
end

function loco.parameterKeyboard(key)
    if loco.focus and loco.focus.keyboard then
        loco.focus:keyboard(key)
    end
end

function loco.selectParameterNameColor()
    love.graphics.setColor(150, 150, 150, 255)
end

function loco.selectParameterValueColor()
    love.graphics.setColor(255, 200, 0, 255)
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Number and Integer
--
-- -- ---- ------ ---------- ---------------- --------------------------

ParameterWidget = class()

function ParameterWidget:init(x, y, name, min, max, type)
    self.x = x
    self.y = y
    self.w = loco.width_of_output_pane
    self.h = 50
    self.min = min
    self.max = max
    self.name = name
    self.type = type
    self.touchid = 0
    -- unclamped x position of touch, only valid if touchid ~= 0
    self.touchx = 0
    self:update()
end

function ParameterWidget:update()
    -- x1: left slider edge
    -- x2: right slider edge
    -- dx: delta x of slider
    -- dv: delta v, value span
    self.x1 = self.x + 20
    self.x2 = self.x + self.w - 20
    self.dx = self.x2 - self.x1
    self.dv = self.max - self.min
end

-- Returns x clamped to the edges of the slider.
function ParameterWidget:clamp(x)
    if x < self.x1 then x = self.x1 end
    if x > self.x2 then x = self.x2 end
    return x
end

-- Returns the x-coordinate the peg.
function ParameterWidget:getxp()
    local value = _G[self.name]
    local xp
    if self.touchid == 0 then
        xp = self.x1 + (value - self.min) * self.dx / self.dv
    else
        xp = self:clamp(self.touchx)
    end
    return xp
end

function ParameterWidget:touched(touch)
    local xp = self:getxp()
    local y = self.y + 30
    self.touchx = touch.x

    if touch.state == BEGAN then
        local dx = xp - touch.x
        local dy = y - touch.y
        if math.abs(dx) <= 5 and math.abs(dy) <= 5 then
            self.touchid = touch.id
        end
    elseif touch.state == MOVING then
        if touch.id == self.touchid then
            local tx = self:clamp(touch.x)
            local value = (tx - self.x1) * self.dv / self.dx
            if self.type == "int" then
                value = math.floor(value + 0.5)
            end
            _G[self.name] = value + self.min
        end
    elseif touch.state == ENDED then
        if touch.id == self.touchid then
            self.touchid = 0
        end
    end
end

function ParameterWidget:draw()
    pushStyle()

    love.graphics.setLineWidth(3)
    love.graphics.setLineStyle("smooth")
    local value = _G[self.name]
    local xp = self:getxp()
    local y = self.y + 30
    -- draw slider in white and gray
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.line(self.x1, y, xp, y)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(150, 150, 150, 255)
    love.graphics.line(xp, y, self.x2, y)

    -- draw peg
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.circle("fill", xp, y, 8, 20)
    love.graphics.setColor(0, 0, 0, 255)
    if self.touchid ~= 0 then
        --love.graphics.setColor(0, 255, 0, 255)
    end
    love.graphics.circle("fill", xp, y, 6, 20)

    -- name and value
    fontSize(12)
    loco.selectParameterNameColor();
    love.graphics.print(self.name, self.x + 15, self.y)
    local f = love.graphics.getFont()
    local valuestr = tostring(value)
    -- limit fractional part if present
    if string.find(valuestr, "%.") ~= nil then
        valuestr = string.format("%.2f", value)
    end
    local strw = f:getWidth(valuestr)
    loco.selectParameterValueColor();
    love.graphics.print(valuestr, self.x + self.w - 15 - strw, self.y)

    popStyle()
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Watch
--
-- -- ---- ------ ---------- ---------------- --------------------------

WatchParameterWidget = class()

function WatchParameterWidget:init(x, y, name)
    self.x = x
    self.y = y
    self.w = loco.width_of_output_pane
    self.h = 50
    self.name = name
    self:update()
end

function WatchParameterWidget:update()
end

function WatchParameterWidget:touched(touch)
end

function WatchParameterWidget:draw()
    pushStyle()

    -- Print name
    fontSize(12)
    loco.selectParameterNameColor();
    love.graphics.print(self.name, self.x + 15, self.y + 10)

    -- Print value
    loco.selectParameterValueColor();
    if _G[self.name] ~= nil then
        love.graphics.print(tostring(_G[self.name]), self.x + 15, self.y + 30)
    end

    --self.h = 50

    popStyle()
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Action
--
-- -- ---- ------ ---------- ---------------- --------------------------

ActionParameterWidget = class()

function ActionParameterWidget:init(x, y, text, callback)
    self.x = x
    self.y = y
    self.w = loco.width_of_output_pane
    self.h = 50
    self.text = text
    self.callback = callback
    self.touchid = 0
    self.highlight = false
    self:update()
end

function ActionParameterWidget:update()
end

function ActionParameterWidget:insideButton(x, y)
    if x >= self.x + 15 and x <= self.x + self.w - 15 and
            y >= self.y + 10 and y <= self.y + self.h - 10 then
        return true
    end
    return false
end

function ActionParameterWidget:touched(touch)
    local y = self.y + 30
    self.touchx = touch.x

    if touch.state == BEGAN then
        if self:insideButton(touch.x, touch.y) then
            self.touchid = touch.id
            self.highlight = true
        end
    elseif touch.state == MOVING then
        if touch.id == self.touchid then
            if self:insideButton(touch.x, touch.y) then
                self.highlight = true
            else
                self.highlight = false
            end
        end
    else
        if touch.id == self.touchid then
            if self:insideButton(touch.x, touch.y) then
                self.callback()
            end
            self.highlight = false
            self.touchid = 0
        end
    end
end

function ActionParameterWidget:draw()
    pushStyle()

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("smooth")

    -- Properties of text in button
    fontSize(12)
    local f = love.graphics.getFont()
    local fheight = f:getHeight()
    self.h = 20 + fheight + 20

    -- Draw button
    love.graphics.setColor(132, 145, 151, 255)
    if self.highlight then
        love.graphics.setColor(152, 165, 171, 255)
    end
    love.graphics.rectangle("fill", self.x + 15, self.y + 10, self.w - 30, self.h - 20)
    --love.graphics.setColor(200, 200, 200, 255)
    --love.graphics.rectangle("line", self.x + 15, self.y + 10, self.w - 30, self.h - 20)

    -- Draw text in button
    --local strw = f:getWidth(valuestr)
    love.graphics.setColor(0, 0, 0, 255)
    local textw = f:getWidth(self.text)
    local x0 = (self.w - 40 - textw) / 2
    love.graphics.print(self.text, self.x + 20 + x0, self.y + 20)

    popStyle()
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Text
--
-- -- ---- ------ ---------- ---------------- --------------------------

TextParameterWidget = class()

-- Terminology:
-- text: the whole text
-- line: a line in the text, delimiter is newline;
--   may be split up in more than one visual line if too long
-- vline: a visual line like it is presented on the display after application
--   of wrapping
-- pos: position of the caret inside the text, 1 is at the start of the text,
--   may go to text length + 1
-- start: the start position of a (visual) line
-- stop: the last position of a (visual) line so that
--   string.sub(text, start, stop) returns the (visual) line contents
--   (without the newline character if present)

function TextParameterWidget:init(x, y, name)
    self.x = x
    self.y = y
    self.w = loco.width_of_output_pane
    self.h = 50
    self.name = name
    self.caret_pos = 1
    self.touchid = 0
    self:update()
end

function TextParameterWidget:update()
    fontSize(12)
    local f = love.graphics.getFont()
    self.font = f
    self.fheight = f:getHeight()
    if _G[self.name] == nil then
        _G[self.name] = ""
    end
    self.text = _G[self.name]
end

function TextParameterWidget:insideText(x, y)
    if x >= self.x + 20 and x <= self.x + self.w - 20 and
            y >= self.y + 20 and y <= self.y + self.h -10 then
        return true
    end
    return false
end

function TextParameterWidget:touched(touch)
    local tx = touch.x - self.x - 20
    local ty = touch.y - self.y - 20

    if touch.state == BEGAN then
        if self:insideText(touch.x, touch.y) then
            self.touchid = touch.id
            local pos = self:pixelToPos(tx, ty)
            self.caret_pos = pos
            self.highlight = true
            loco.focus = self
        end
    elseif touch.state == MOVING then
        if touch.id == self.touchid then
            if self:insideText(touch.x, touch.y) then
                local pos = self:pixelToPos(tx, ty)
                self.caret_pos = pos
                self.highlight = true
            else
                self.highlight = false
            end
        end
    else
        if touch.id == self.touchid then
            self.highlight = false
            self.touchid = 0
        end
    end
end

function TextParameterWidget:calcLineIdxs(text)
    local line_idxs = {}
    local start, stop = 1, 1
    local idx = 0
    while idx ~= nil do
        idx = string.find(text, '\n', start)
        if idx == nil then
            stop = #text
        else
            stop = idx - 1
        end
        -- start < stop on an empty line.
        table.insert(line_idxs, {start, stop})
        start = stop + 2
    end
    return line_idxs
end

function TextParameterWidget:calcVisual(text)
    local vlines = {}
    self.line_idxs = self:calcLineIdxs(text)
    local f = self.font
    local maxw = self.w - 40
    local _, nlines = f:getWrap(text, maxw)
    local fheight = f:getHeight()
    local line_idxs = self.line_idxs
    local yoff = 0
    for i, line_idx in ipairs(line_idxs) do
        local lstart, lstop = line_idx[1], line_idx[2]
        local strw = f:getWidth(string.sub(text, lstart, lstop))
        if strw <= maxw then
            -- Line fits
            local vline = {i, lstart, lstop}
            table.insert(vlines, vline)
        else
            -- Line doesn't fit, find wrapping point
            local vstart = lstart
            local wrapping_point = 0
            for idx = lstart, lstop do
                strw = f:getWidth(string.sub(text, vstart, idx))
                if strw > maxw then
                    if wrapping_point == 0 then
                        wrapping_point = idx - 1
                    end
                    local vline = {i, vstart, wrapping_point}
                    table.insert(vlines, vline)
                    vstart = wrapping_point + 1
                    wrapping_point = 0
                end
                if idx == lstop then
                    local vline = {i, vstart, lstop}
                    table.insert(vlines, vline)
                end
                -- Remember possible wrapping point for next step
                if idx > vstart then
                    local char = string.sub(text, idx, idx)
                    if char == " " then
                        wrapping_point = idx
                    end
                end
            end
        end
    end
    self.vlines = vlines
end

function TextParameterWidget:dumpVisual()
    for i,v in ipairs(self.vlines) do
        local sub = string.sub(self.text, v[2], v[3])
        print(i..")  line "..v[1].."  "..v[2]..".."..v[3].."<"..sub..">")
    end
end

-- Calculate the text position of the caret from a pixel position.
--
-- x - x position in pixels, 0 is at the upper left corner of the text display.
-- x - y position in pixels.
--
-- Returns position in text.
function TextParameterWidget:pixelToPos(x, y)
    -- 0-based visual line
    local vline = math.floor(y / self.fheight)
    if vline < 0 then
        return 1
    end
    if vline >= #self.vlines then
        return #self.text + 1
    end

    local vline = self.vlines[vline + 1]
    local linenr, start, stop = vline[1], vline[2], vline[3]
    -- find position by increasingly measuring the string width
    for p = start, stop do
        local sub = string.sub(self.text, start, p)
        local w = self.font:getWidth(sub)
        if w > x then
            local pos = p
            return pos
        end
    end
    return stop + 1
end

function TextParameterWidget:draw()
    pushStyle()

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("smooth")
    local y = self.y + 20

    -- Draw name
    fontSize(12)
    loco.selectParameterNameColor();
    love.graphics.print(self.name, self.x + 15, self.y)
    if not self.calced then
        self.calced = true
        self:calcVisual(self.text)
        self:dumpVisual()
    end

    -- Draw text
    local f = love.graphics.getFont()
    local maxw = self.w - 40
    local caret_x = 0
    local caret_y = 0

    -- Draw frame around text
    local nlines = #self.vlines
    local frameheight = nlines * self.fheight + 10
    love.graphics.setColor(45, 46, 50, 255)
    love.graphics.rectangle("fill", self.x + 15, self.y + 15, self.w - 30, frameheight)
    love.graphics.setColor(100, 100, 100, 255)
    love.graphics.rectangle("line", self.x + 15, self.y + 15, self.w - 30, frameheight)

    loco.selectParameterValueColor();
    local x = self.x + 20
    local y = self.y + 20
    local yoff = 0
    for i,v in ipairs(self.vlines) do
        -- Draw visual line
        local linenr, start, stop = v[1], v[2], v[3]
        local sub = string.sub(self.text, start, stop)
        love.graphics.print(sub, x, y + yoff)

        -- Determine caret position if in line
        if self.caret_pos >= start and self.caret_pos <= stop + 1 then
            local line = string.sub(self.text, start, self.caret_pos - 1)
            caret_x = f:getWidth(line)
            caret_y = yoff
        end

        -- Prepare offset for next line
        yoff = yoff + self.fheight
    end

    -- Draw caret
    if loco.focus == self then
        local cx = x + caret_x
        local cy = y + caret_y
        love.graphics.setColor(50, 50, 255, 255)
        love.graphics.line(cx, cy, cx, cy + self.fheight)
    end

    self.h = 20 + nlines * self.fheight + 10

    popStyle()
end

function TextParameterWidget:keyboard(key)
    local insert = nil

    if string.len(key) == 1 then
        if love.keyboard.isDown("lshift", "rshift") then
            key = key:upper()
        end
        insert = key
    elseif key == "left" then
        if self.caret_pos > 1 then
            self.caret_pos = self.caret_pos - 1
        end
    elseif key == "right" then
        if self.caret_pos <= #self.text then
            self.caret_pos = self.caret_pos + 1
        end
    elseif key == "return" then
        insert = "\n"
    elseif key == "backspace" then
        if self.caret_pos > 1 then
            local t = self.text
            local t1 = string.sub(t, 1, self.caret_pos - 2)
            local t2 = string.sub(t, self.caret_pos)
            self.text = t1..t2
            self.caret_pos = self.caret_pos - 1
            self.calced = false
            _G[self.name] = self.text
        end
    end

    if insert ~= nil then
        local t = self.text
        local t1 = string.sub(t, 1, self.caret_pos - 1)
        local t2 = string.sub(t, self.caret_pos, -1)
        self.text = t1..insert..t2
        self.caret_pos = self.caret_pos + 1
        self.calced = false
        _G[self.name] = self.text
    end
end
