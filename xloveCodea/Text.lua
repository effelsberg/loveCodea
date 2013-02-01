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
-- Render texts
--
-- Implements public Codea API:
--   text()
--   textSize()
--   textMode()
--   textWrapWidth()
--   textAlign()
--   font()
--   fontSize()
--   fontMetrics()
--
-- -- ---- ------ ---------- ---------------- --------------------------

function text(str, x, y)
    x = x or 0
    y = y or 0
    love.graphics.push()
    local f = love.graphics.getFont()
    local w = f:getWidth(str)
    local h = f:getHeight()
    love.graphics.setColor(unpack(loco.style.fillcolor))
    love.graphics.translate(x, y)
    love.graphics.scale(1, -1)
    if loco.style.textwrapwidth == 0 then
        if loco.style.textmode == CENTER then
            love.graphics.print(str, -w / 2, -h / 2)
        else
            -- CORNER (lower left)
            love.graphics.print(str, 0, -h)
        end
    else
        local align = "left"
        if loco.style.textalign == RIGHT then align = "right" end
        if loco.style.textalign == CENTER then align = "center" end
        love.graphics.printf(str, 0, -h, loco.style.textwrapwidth, align)
    end
    love.graphics.pop()
end

function textSize(str)
    local f = love.graphics.getFont()
    local w = f:getWidth(str)
    local h = f:getHeight()
    return w, h
end

function textMode(mode)
    loco.style.textmode = mode
end

function textWrapWidth(w)
    if w == nil then return loco.style.textwrapwidth end
    loco.style.textwrapwidth = w
end

function textAlign(a)
    if a == nil then return loco.style.textalign end
    loco.style.textalign = a
end

loco.fontcache = {}

function fontSize(size)
    size = math.floor(size)
    local fullname = loco.style.fontname .. size
    if loco.fontcache[fullname] == nil then
        if loco.style.fontname == "" then
            loco.fontcache[fullname] = love.graphics.newFont(size)
        else
            loco.fontcache[fullname] = love.graphics.newFont(loco.style.fontname, size)
        end
    end
    love.graphics.setFont(loco.fontcache[fullname])
    loco.style.fontsize = size
end

function font(fontname)
    local ttf = fontname .. ".ttf"
    if love.filesystem.isFile(ttf) then
        loco.style.fontname = ttf
    else
        loco.style.fontname = ""
    end
    fontSize(loco.style.fontsize or 17)
end

function fontMetrics()
    local met = {}
    met.ascent = loco.style.fontsize * 0.9
    met.descent = loco.style.fontsize * 0.1
    met.leading = 0
    met.xHeight = loco.style.fontsize * 0.6
    met.capHeight = 0
    met.underlinePosition = 0
    met.underlineThickness = 0
    met.slantAngle = 0
    return met
end
