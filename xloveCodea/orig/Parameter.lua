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
-- Deprecated for Codea >= 1.5:
--   iparameter()
--   parameter()
--
-- -- ---- ------ ---------- ---------------- --------------------------

parameter = {}

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
    loco.addParameterWidget(name, min, max, "int")
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
    loco.addParameterWidget(name, min, max, "float")
end

function loco.addParameterWidget(name, min, max, type)
    local y = loco.parameterCount * 50
    local w = ParameterWidget(0, y, name, min, max, type)
    loco.parameterCount = loco.parameterCount + 1
    table.insert(loco.parameterWidgetList, w)
end

ParameterWidget = class()

function ParameterWidget:init(x, y, name, min, max, type)
    self.x = x
    self.y = y
    self.w = 240
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
    self.x1 = self.x + 30
    self.x2 = self.x + self.w - 30
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

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("smooth")
    local value = _G[self.name]
    local xp = self:getxp()
    local y = self.y + 30
    -- draw slider in white and gray
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.line(self.x1, y, xp, y)
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
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(self.name, self.x + 10, self.y)
    local f = love.graphics.getFont()
    local valuestr = tostring(value)
    -- limit fractional part if present
    if string.find(valuestr, "%.") ~= nil then
        valuestr = string.format("%.3f", value)
    end
    local strw = f:getWidth(valuestr)
    love.graphics.setColor(255, 128, 0, 255)
    love.graphics.print(valuestr, self.x +self.w - 10 - strw, self.y)

    popStyle()
end
