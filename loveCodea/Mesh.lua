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
-- Meshes
--
-- Implements public Codea API:
--   mesh()
--   triangulate()
--
-- -- ---- ------ ---------- ---------------- --------------------------

mesh = class()

function mesh:init()
    self.vertices = {}
    self.rectlist = {}
    self.recttexlist = {}
    self.rectcolorlist = {}
    self.texture = nil
    self._oldtexture = nil
    self._image = nil
    self.colors = nil
end

function mesh:setColors(c)
    local col1 = {loco.makeFullColor(c)}
    local col2 = color(unpack(col1))
    self.colors = {}
    for i = 1, #self.vertices do
        table.insert(self.colors, col2)
    end
end

function mesh:addRect(x, y, w, h, r)
    r = r or 0
    table.insert(self.rectlist, {x, y, w, h, r})
    return #self.rectlist
end

function mesh:setRect(i, x, y, w, h, r)
    r = r or 0
    self.rectlist[i] = {x, y, w, h, r}
end

function mesh:setRectTex(i, s, t, w, h)
    self.recttexlist[i] = {s, t, w, h}
end

function mesh:setRectColor(i, c)
    self.rectcolorlist[i] = c
end

function mesh:draw()
    self:_drawTriangles()
    self:_drawRectangles()
end

function mesh:_textureToImage()
    if self.texture ~= self._oldtexture then
        if self.texture == nil then
            self._image = nil
        elseif type(self.texture) == "string" then
            self._image = loco.loadSprite(self.texture)
        else
            self._image = self.texture
        end
        self._oldtexture = self.texture
    end
end

function mesh:_drawRectangles()
    for i = 1,#self.rectlist do
        local r = self.rectlist[i]
        local x, y, w, h, rot = r[1], r[2], r[3], r[4], r[5]
        local c = self.rectcolorlist[i]
        love.graphics.push()
        if c ~= nil then
            love.graphics.setColor(c.r, c.g, c.b, c.a)
        end
        if self.texture == nil then
            love.graphics.translate(x ,y)
            love.graphics.rotate(rot)
            love.graphics.rectangle("fill", - w / 2, - h / 2, w, h)
        else
            -- texture coordinates and scales
            local tex_x, tex_y, tex_xs, tex_ys = 0, 0, 1, 1
            if self.recttexlist[i] ~= nil then
                local rt = self.recttexlist[i]
                tex_x, tex_y, tex_xs, tex_ys = rt[1], rt[2], rt[3], rt[4]
            end
            self:_textureToImage()
            local drawable
            local image_w
            local image_h
            if self._image ~= nil then
                drawable = self._image
                if drawable._getDrawable == nil then
                    image_w = drawable:getWidth()
                    image_h = drawable:getHeight()
                else
                    image_w = drawable:getWidth()
                    image_h = drawable:getHeight()
                    drawable = drawable:_getDrawable()
                end
            end
            local xscale = w / image_w
            local yscale = h / image_h
            love.graphics.translate(x ,y)
            love.graphics.rotate(rot)
            -- mini implementation for texture directions -1 / -1 (Space Puzzle 8)
            local x0 = 0
            local y0 = h
            if tex_xs < 0 then
                x0 = w
                xscale = xscale * tex_xs
            end
            if tex_ys < 0 then
                y0 = 0
                yscale = yscale * tex_ys
            end
            if c ~= nil then
                --love.graphics.setColorMode("modulate")
            else
                --love.graphics.setColorMode("replace")
            end
            love.graphics.draw(drawable, x0 - w / 2, y0 - h / 2, 0, xscale, -yscale)
            --love.graphics.setColorMode("modulate")
        end
        love.graphics.pop()
    end
end

function colorwrap(c)
    if c < 0 then c = -c end
    if c > 510 then c = c % 510 end
    if c > 255 then c = 255 - c end
    return c
end

function mesh:_drawTriangles()
    local c = self.colors
    local v = self.vertices

    if c == nil then
        love.graphics.setColor(loco.style.fillcolor)
    elseif #c ~= #v then
        return
    end

    local nvertices = #v
    for i = 1, nvertices, 3 do
        local x1, y1 = v[i]:unpack()
        local x2, y2 = v[i + 1]:unpack()
        local x3, y3 = v[i + 2]:unpack()
        if c == nil then
            love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
        else
            local c1 = c[i]
            local c2 = c[i + 1]
            local c3 = c[i + 2]
            -- TODO Better compare the contained values
            if c1 == c2 and c1 == c3 then
                love.graphics.setColor(c1.r, c1.g, c1.b, c1.a)
                love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
            else
                --love.graphics.setColor(c1.r, c1.g, c1.b, c1.a)
                --love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
                local vertices = {
                    --{ x1, y1,    0, 0,    c1.r, c1.g, c1.b, c1.a },
                    --{ x2, y2,    1, 0,    c2.r, c2.g, c2.b, c2.a },
                    --{ x3, y3,    0, 1,    c3.r, c3.g, c3.b, c3.a },
                    { x1, y1,    0, 0,    colorwrap(c1.r), colorwrap(c1.g), colorwrap(c1.b), colorwrap(c1.a) },
                    { x2, y2,    1, 0,    colorwrap(c2.r), colorwrap(c2.g), colorwrap(c2.b), colorwrap(c2.a) },
                    { x3, y3,    0, 1,    colorwrap(c3.r), colorwrap(c3.g), colorwrap(c3.b), colorwrap(c3.a) },
                }
                --local mesh = love.graphics.newMesh(vertices, nil, "fan")
                local mesh = love.graphics.newMesh(vertices)
                love.graphics.draw(mesh, 0, 0)
            end
        end
    end
end

-- Draw rasterized triangles.
-- Usually, rasterized triangles are drawn line by line in steps of 1.
-- If triangles are drawn this way and the matrix is rotated, it will have
-- empty spots, therefore the rasterizer advances in steps of 2, drawing
-- points with a size of 3 for a slight overlap.
-- (This also improves the poor rendering speed, steps of 1 and a point size
-- of 2 would take much longer.)

function mesh:_drawTriangle(x1, y1, c1, x2, y2, c2, x3, y3, c3)
    local dy12 = math.abs(y2 - y1)
    local dy23 = math.abs(y3 - y2)
    local dy31 = math.abs(y1 - y3)
    local startx, starty, startc
    local stopx, stopx, stopc
    local othx, othy, othc

    if dy12 > dy23 and dy12 > dy31 then
        -- v1 and v2 span the largest vertical distance
        startx, starty, startc = x1, y1, c1
        stopx, stopy, stopc = x2, y2, c2
        othx, othy, othc = x3, y3, c3
    elseif dy23 > dy31 then
        -- v2 and v3 span the largest vertical distance
        startx, starty, startc = x2, y2, c2
        stopx, stopy, stopc = x3, y3, c3
        othx, othy, othc = x1, y1, c1
    else
        -- v3 and v1 span the largest vertical distance
        startx, starty, startc = x3, y3, c3
        stopx, stopy, stopc = x1, y1, c1
        othx, othy, othc = x2, y2, c2
    end

    if starty > stopy then
        startx, stopx = stopx, startx
        starty, stopy = stopy, starty
        startc, stopc = stopc, startc
    end

    -- Go from starty to stopy, interpolating the color from startc to stopc.
    -- This is the main slope.
    -- For every vertical position on the main slope draw a line from the
    -- current position and color to the other slope.
    -- The other slope is split into two parts, from start to other and from
    -- other to stop.

    -- m.  main
    -- md. main deltas
    -- mi. main increments
    -- o.  other
    -- od. other deltas
    -- oi. other increments
    local mx, my, mr, mg, mb, ma = startx, starty, startc.r, startc.g, startc.b, startc.a
    local mdx = stopx - startx
    local mdy = stopy - starty
    local mix = mdx / mdy
    local mir = (stopc.r - mr) / mdy
    local mig = (stopc.g - mg) / mdy
    local mib = (stopc.b - mb) / mdy
    local mia = (stopc.a - ma) / mdy

    --local ox, oy, o_r, og, ob, oa = othx, othy, othc.r, othc.g, othc.b, othc.a
    local ox, o_r, og, ob, oa = startx, startc.r, startc.g, startc.b, startc.a
    local odx = othx - startx
    local ody = othy - starty
    local oix = odx / ody
    local oir = (othc.r - startc.r) / ody
    local oig = (othc.g - startc.g) / ody
    local oib = (othc.b - startc.b) / ody
    local oia = (othc.a - startc.a) / ody

    while my < stopy do
        if my == othy then
            -- First "other" slope done, prepare for the second "other" slope
            ox, o_r, og, ob, oa = othx, othc.r, othc.g, othc.b, othc.a
            odx = stopx - othx
            ody = stopy - othy
            oix = odx / ody
            oir = (stopc.r - othc.r) / ody
            oig = (stopc.g - othc.g) / ody
            oib = (stopc.b - othc.b) / ody
            oia = (stopc.a - othc.a) / ody
        end
        mc = color(mr, mg, mb, ma)
        oc = color(o_r, og, ob, oa)
        mesh:_drawHLine(mx, ox, my, mc, oc)
        my = my + 2
        mx = mx + mix * 2
        ox = ox + oix * 2
        mr = mr + mir * 2
        mg = mg + mig * 2
        mb = mb + mib * 2
        ma = ma + mia * 2
        o_r = o_r + oir * 2
        og = og + oig * 2
        ob = ob + oir * 2
        oa = oa + oia * 2
    end
end

-- Draws a horizontal line with color interpolation.
-- Used for rasterizing triangles.
function mesh:_drawHLine(x1, x2, y, c1, c2)
    local psize = love.graphics.getPointSize()
    local pstyle = love.graphics.getPointStyle()
    if x1 > x2 then
        x1, x2 = x2, x1
        c1, c2 = c2, c1
    end
    local dx = x2 - x1
    if dx < 1 then dx = 1 end
    local r, g, b, a = c1.r, c1.g, c1.b, c1.a
    local dr, dg, db, da
    ir = (c2.r - c1.r) / dx
    ig = (c2.g - c1.g) / dx
    ib = (c2.b - c1.b) / dx
    ia = (c2.a - c1.a) / dx
    love.graphics.setPointSize(3)
    love.graphics.setPointStyle("rough")
    while x1 < x2 do
        if r > 255 then r = 255 end
        if g > 255 then g = 255 end
        if b > 255 then b = 255 end
        if a > 255 then a = 255 end
        if r < 0 then r = 0 end
        if g < 0 then g = 0 end
        if b < 0 then b = 0 end
        if a < 0 then a = 0 end
        love.graphics.setColor(r, g, b, a)
        love.graphics.point(x1, y)
        x1 = x1 + 2
        r = r + ir * 2
        g = g + ig * 2
        b = b + ib * 2
        a = a + ia * 2
    end
    --love.graphics.setPoint(psize, pstyle)
    love.graphics.setPointSize(psize)
    love.graphics.setPointStyle(pstyle)
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- triangulate
--
-- -- ---- ------ ---------- ---------------- --------------------------

-- Assumes counter-clockwise direction
function triangulate(points)
    local mypoints = loco.deepcopy(points)
    --local mypoints = {}
    --for i = 1, #points do
    --    table.insert(mypoints, vec2(points[i].x, points[i].y))
    --end

    if #points == 1 then
        return {mypoints[1], mypoints[1], mypoints[1]}
    elseif #points == 2 then
        return {mypoints[1], mypoints[1], mypoints[2]}
    elseif #points == 3 then
        return mypoints
    end

    -- result
    local trivecs = {}

    local steps_without_reduction = 0
    local i = 1
    while #mypoints >= 3 and steps_without_reduction < #mypoints do
        local v2i = i % #mypoints + 1
        local v3i = (i + 1) % #mypoints + 1
        local v1 = mypoints[i]
        local v2 = mypoints[v2i]
        local v3 = mypoints[v3i]
        local da = loco.enclosedAngle(v1, v2, v3)
        local reduce = false
        if da >= 0 then
            -- The two edges bend inwards, candidate for reduction.
            reduce = true
            -- Check that there's no other point inside.
            for ii = 1, (#mypoints - 3) do
                local mod_ii = (i + 2 + ii - 1) % #mypoints + 1
                if loco.isInsideTriangle(mypoints[mod_ii], v1, v2, v3) then
                    reduce = false
                end
            end
        end
        if reduce then
            table.insert(trivecs, v1)
            table.insert(trivecs, v2)
            table.insert(trivecs, v3)
            table.remove(mypoints, v2i)
            steps_without_reduction = 0
        else
            i = i + 1
            steps_without_reduction = steps_without_reduction + 1
        end
        if i > #mypoints then
            i = i - #mypoints
        end
    end
    return trivecs
end

--[[ alternate function
function triangulate(points)
    if #points == 1 then
        return {points[1], points[1], points[1]}
    elseif #points == 2 then
        return {points[1], points[1], points[2]}
    elseif #points == 3 then
        return points
    end

    -- resulting triangle vectors
    local trivecs = {}
    -- holds the triangle to cut out
    local tri = {}
    for i = 1, 3 do
        table.insert(tri, points[i])
    end
    -- holds the rest of the polygon
    local rest = {}
    for i = 4, #points do
        table.insert(rest, points[i])
    end

    local steps_without_reduction = 0
    while #tri >= 3 and steps_without_reduction < (#tri + #rest) do
        local da = loco.enclosedAngle(unpack(tri))
        local reduce = false
        if da >= 0 then
            -- The two edges bend inwards, candidate for reduction.
            reduce = true
            -- Check that there's no other point inside.
            for i, p in ipairs(rest) do
                if loco.isInsideTriangle(p, unpack(tri)) then
                    reduce = false
                end
            end
        end
        if reduce then
            table.insert(trivecs, vec2(tri[1].x, tri[1].y))
            table.insert(trivecs, vec2(tri[2].x, tri[2].y))
            table.insert(trivecs, vec2(tri[3].x, tri[3].y))
            table.remove(tri, 2)
            steps_without_reduction = 0
        else
            steps_without_reduction = steps_without_reduction + 1
        end
        if #rest > 0 then
            table.insert(tri, table.remove(rest, 1))
        end
        if #tri > 3 then
            table.insert(rest, table.remove(tri, 1))
        end
    end
    return trivecs
end
--]]

function loco.enclosedAngle(v1, v2, v3)
    local a1 = math.atan2(v1.y - v2.y, v1.x - v2.x)
    local a2 = math.atan2(v3.y - v2.y, v3.x - v2.x)
    -- for clockwise order
    local da = math.deg(a2 - a1)
    -- for counter-clockwise order
    --local da = math.deg(a1 - a2)
    if da < -180 then da = da + 360 elseif da > 180 then da = da - 360 end
    return da
end

-- Determines if a vector |v| is inside a triangle described by the vectors
-- |v1|, |v2| and |v3|.
function loco.isInsideTriangle(v, v1, v2, v3)
    local a1
    local a2
    a1 = loco.enclosedAngle(v1, v2, v3)
    a2 = loco.enclosedAngle(v, v2, v3)
    if a2 > a1 or a2 < 0 then return false end
    a1 = loco.enclosedAngle(v2, v3, v1)
    a2 = loco.enclosedAngle(v, v3, v1)
    if a2 > a1 or a2 < 0 then return false end
    a1 = loco.enclosedAngle(v3, v1, v2)
    a2 = loco.enclosedAngle(v, v1, v2)
    if a2 > a1 or a2 < 0 then return false end
    return true
end
