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
-- Basic drawing functions and style
--
-- Implements public Codea API:
--   color()
--   background()
--   clip()
--   noClip()
--   ellipse()
--   line()
--   rect()
--   popStyle()
--   pushStyle()
--   resetStyle()
--   fill()
--   noFill()
--   lineCapMode()
--   smooth()
--   noSmooth()
--   ellipseMode()
--   rectMode()
--   stroke()
--   noStroke()
--   strokeWidth()
--   tint()
--   noTint()
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.bgcolor = {0, 0, 0, 255}
loco.style = {}

function color(r, g, b, a)
    local color = {}
    color.r = r
    color.g = g
    color.b = b
    color.a = a or 255
    return color
end

function background(red, green, blue, alpha)
    if red == nil then
        return unpack(loco.bgcolor)
    end
    loco.bgcolor = {loco.makeFullColor(red, green, blue, alpha)}
    love.graphics.setBackgroundColor(unpack(loco.bgcolor))
    -- Not nice: This resets the transformation stack ...
    --love.graphics.clear()
end

function clip(x, y, w, h)
    if x == nil then
        love.graphics.setScissor()
    else
        local x_ = (x + loco.mainwinoffset) / loco.SCALE
        local y_ = (HEIGHT - y - h) / loco.SCALE
        local w_ = w / loco.SCALE
        local h_ = h / loco.SCALE
        love.graphics.setScissor(x_, y_, w_, h_)
    end
end

function noClip()
    love.graphics.setScissor()
end

-- Sets line color, width and smoothness according to current style settings.
function loco.applyLineStyle()
    love.graphics.setLineWidth(loco.style.strokewidth)
    if loco.style.smooth then
        love.graphics.setLineStyle("smooth")
    else
        love.graphics.setLineStyle("rough")
    end
    love.graphics.setLineWidth(loco.style.strokewidth)
    love.graphics.setColor(unpack(loco.style.strokecolor))
end

-- Codea: Outlines are not drawn if line width is 0.
-- Outlines with line width of 1 are only drawn when not smooth.
function loco.isOutlineVisible(shape)
    local lw = loco.style.strokewidth
    if lw > 1 or (lw > 0 and not loco.style.smooth) then
        return true
    end
    if lw == 1 and shape == "ellipse" then
        return true
    end
    return false
end

function ellipse(x, y, width, height)
    if height == nil then
        height = width
    end
    local radiusx = width
    local radiusy = height
    if loco.style.ellipsemode == CENTER or loco.style.ellipsemode == CORNER then
        radiusx = radiusx / 2
        radiusy = radiusy / 2
    end
    if loco.style.ellipsemode == CORNERS then
        -- width and height are the other corner
        if x > width then x, width = width, x end
        if y > height then y, height = height, y end
        radiusx = (width - x) / 2
        radiusy = (height - y) / 2
    end
    if loco.style.ellipsemode == CORNER or loco.style.ellipsemode == CORNERS then
        x = x + radiusx
        y = y + radiusy
    end
    if radiusx == radiusy then
        -- use Love's circle
        if not loco.style.nofill then
            love.graphics.setColor(unpack(loco.style.fillcolor))
            love.graphics.circle("fill", x, y, radiusx, 50)
        end
        if loco.isOutlineVisible("ellipse") then
            local lw = loco.style.strokewidth
            loco.applyLineStyle()
            love.graphics.circle("line", x, y, radiusx - lw / 2, 50)
        end
    else
        if not loco.style.nofill then
            love.graphics.setColor(unpack(loco.style.fillcolor))
            loco.ellipse2("fill", x, y, radiusx, radiusy)
        end
        if loco.isOutlineVisible("ellipse") then
            loco.applyLineStyle()
            loco.ellipse2("line", x, y, radiusx, radiusy)
        end
    end
end

-- Love2d does not have an ellipse function, approximate with a polygon.
function loco.ellipse2(mode, x, y, a, b)
    local stp=50  -- Step is # of line segments (more is "better")
    local rot=0 -- Rotation in degrees
    local m,rad,sa,ca,sb,cb,x1,y1,ast
    m = math; rad = m.pi/180; ast = rad * 360/stp;
    sb = m.sin(-rot * rad); cb = m.cos(-rot * rad)
    local vertices = {}
    for n = 1, stp do
        sa = m.sin(ast*n) * b
        ca = m.cos(ast*n) * a
        x1 = x + ca * cb - sa * sb
        y1 = y + ca * sb + sa * cb
        table.insert(vertices, x1)
        table.insert(vertices, y1)
    end
    love.graphics.polygon(mode, vertices)
end

function line(x1, y1, x2, y2)
    love.graphics.setColor(unpack(loco.style.strokecolor))
    if (x1==x2 and y1==y2) then
        love.graphics.point(x1, y1)
    else
        if loco.style.smooth then
            if loco.style.linecapmode == ROUND then
                -- layering will be visible when using transparency
                local radius = loco.style.strokewidth / 2
                love.graphics.setLineWidth(1)
                love.graphics.circle("fill", x1, y1, radius, 50)
                love.graphics.circle("fill", x2, y2, radius, 50)
            end
            if loco.style.linecapmode == PROJECT then
                local alpha = math.atan2(y2 - y1, x2 - x1)
                local project = loco.style.strokewidth / 2
                x1 = x1 - project * math.cos(alpha)
                y1 = y1 - project * math.sin(alpha)
                x2 = x2 + project * math.cos(alpha)
                y2 = y2 + project * math.sin(alpha)
            end
        end
        loco.applyLineStyle()
        -- Codea: A line is not visible with widths of 0 and 1
        -- if smoothness is on.
        if (not loco.style.smooth) or loco.style.strokewidth > 1 then
            if loco.style.strokewidth == 0 then
                love.graphics.setLineWidth(1)
            end
            love.graphics.line(x1, y1, x2, y2)
        end
    end
end

function rect(x, y, width, height)
    if loco.style.rectmode == CENTER then
        x = x - width / 2
        y = y - height / 2
    elseif loco.style.rectmode == RADIUS then
        x = x - width
        y = y - height
        width = width * 2
        height = height * 2
    elseif loco.style.rectmode == CORNERS then
        -- width and height are the other corner
        if x > width then x, width = width, x end
        if y > height then y, height = height, y end
        width = width - x
        height = height - y
    end
    if not loco.style.nofill then
        love.graphics.setColor(unpack(loco.style.fillcolor))
        love.graphics.rectangle("fill", x, y, width, height)
    end
    if loco.isOutlineVisible("rect") then
        local lw = loco.style.strokewidth
        loco.applyLineStyle()
        love.graphics.rectangle("line",
                x + lw / 2, y + lw / 2, width - lw, height - lw)
    end
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Style Management
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.style_stack = {}

function popStyle()
    local style = table.remove(loco.style_stack)
    -- No need to deepcopy because it was deepcopied on push.
    --loco.style = loco.deepcopy(style)
    loco.style = style
    strokeWidth(style.strokewidth)
    if style.smooth then smooth() else noSmooth() end
    font(style.fontname)
    -- font also sets font size
    --fontSize(loco.style.fontsize)
end

function pushStyle()
    local style = loco.deepcopy(loco.style)
    table.insert(loco.style_stack, style)
end

function resetStyle()
    --[[
    loco.style.strokewidth = 0
    loco.style.strokecolor = {255, 255, 255, 255}
    loco.style.fillcolor = {128, 128, 128, 255}
    loco.style.pointsize = 3
    loco.style.tintcolor = {255, 255, 255, 255}
    loco.style.rectmode = CORNER
    loco.style.ellipsemode = CENTER
    loco.style.spritemode = CENTER
    loco.style.textmode = CENTER
    loco.style.linecapmode = ROUND
    --loco.style.fontname = "Helvetica"
    loco.style.fontname = ""
    loco.style.fontsize = 17
    loco.style.textwrapwidth = 0
    loco.style.textalign = LEFT
    loco.style.smooth = true
    loco.style.nofill = true
    loco.style.notint = true
    --]]

    loco.style.fontname = ""
    strokeWidth(0)
    stroke(255, 255, 255, 255)
    fill(128, 128, 128, 255)
    tint(255, 255, 255, 255)
    pointSize(3)
    spriteMode(CENTER)
    rectMode(CORNER)
    ellipseMode(CENTER)
    textMode(CENTER)
    lineCapMode(ROUND)
    smooth()
    textAlign(LEFT)
    fontSize(17)
    textWrapWidth(0)
    --font("Helvetica")
end

function loco.makeFullColor(red, green, blue, alpha)
    if (red and green and blue and alpha) then
        return red, green, blue, alpha
    elseif (red and green and blue) then
        return red, green, blue, 255
    elseif (type(red) == "number" and type(green) == "number") then
        -- gray, alpha
        return red, red, red, green
    elseif (type(red) == "number") then
        -- gray
        return red, red, red, 255
    elseif red and (red.r and red.g and red.b and red.a) then
        -- color
        return red.r, red.g, red.b, red.a
    end
    return red, green, blue, alpha
end

function fill(red, green, blue, alpha)
    if red == nil then
        return unpack(loco.style.fillcolor)
    end
    loco.style.fillcolor = {loco.makeFullColor(red, green, blue, alpha)}
    loco.style.nofill = false
end

function noFill()
    loco.style.fillcolor = {0, 0, 0, 0}
    loco.style.nofill = true
end

function lineCapMode(mode)
    if mode == nil then
        return loco.style.linecapmode
    end
    loco.style.linecapmode = mode
end

function smooth()
    loco.style.smooth = true
    love.graphics.setPointStyle("smooth")
    love.graphics.setLineStyle("smooth")
end

function noSmooth()
    loco.style.smooth = false
    love.graphics.setPointStyle("rough")
    love.graphics.setLineStyle("rough")
end

function ellipseMode(mode)
    loco.style.ellipsemode = mode
end

function rectMode(mode)
    loco.style.rectmode = mode
end

function stroke(red, green, blue, alpha)
    if red == nil then
        return unpack(loco.style.strokecolor)
    end
    loco.style.strokecolor = {loco.makeFullColor(red, green, blue, alpha)}
end

function noStroke()
    love.graphics.setLineWidth(0)
    loco.style.strokewidth = 0
end

function strokeWidth(width)
    if width == nil then
        return loco.style.strokewidth
    end
    love.graphics.setLineWidth(width)
    loco.style.strokewidth = width
end

function tint(red, green, blue, alpha)
    loco.style.notint = false
    loco.style.tintcolor = {loco.makeFullColor(red, green, blue, alpha)}
end

function noTint()
    loco.style.notint = true
end
