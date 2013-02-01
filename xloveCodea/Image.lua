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
-- Pixel images
--
-- Implements public Codea API:
--   image()
--   image:get()
--   image:set()
--   image:copy()
--   image:getHeight()
--   image:getWidth()
--
-- -- ---- ------ ---------- ---------------- --------------------------

-- An image in Codea can be used like a good old pixel-wise image but also as
-- a rendering context.
-- For pixel-wise imaging it would be enough to keep an ImageData structure
-- around and create an image from it when needed, but ImageData cannot be
-- used to render into.
-- A Canvas can be rendered into and setting individual pixels is possible,
-- just a bit difficult because the render context must be changed to the
-- canvas and the transformation matrix must be reset.

image = class()

function image:init(w, h)
    -- Either self._canvas or self._imagedata is valid (non-nil) and the source
    -- for drawing.
    -- FIXME: It seems that Love doesn't properly delete canvases (at least
    -- under Windows). Keep the canvas and only rebuild the imagedata.
    -- Start with a canvas.
    self._canvas = love.graphics.newCanvas(w, h)
    self._canvas:clear()
    self._imagedata = nil
    -- Representaion of _imagedata as it cannot be rendered directly by Love.
    self._image = nil
    self.width  = w
    self.height = h
end

function image:_workOnCanvas()
    if self._imagedata ~= nil then
        if self._image == nil then
            self._image = love.graphics.newImage(self._imagedata)
        end
        loco.unwindTransformations()
        --self._canvas = love.graphics.newCanvas(w, h)
        self._canvas:clear()
        love.graphics.setCanvas(self._canvas)
        love.graphics.setScissor()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(self._image, 0, 0)
        --loco.setupCurrentContext()
        love.graphics.push()
        loco.replayTransformations()
        self._imagedata = nil
    end
end

function image:_workOnImageData()
    if self._imagedata == nil then
        self._imagedata = self._canvas:getImageData()
        self._image = nil
        --self._canvas = nil
    end
end

function image:get(x, y)
    self:_workOnImageData()
    return self._imagedata:getPixel(x - 1, self.height - y)
    --[[
    if self._imagedata ~= nil then
        return self._imagedata:getPixel(x - 1, self.height - y)
    else
        return self._canvas:getImageData():getPixel(x - 1, self.height - y)
    end
    --]]
end

-- x : 1 ... width
-- y : 1 ... height
function image:set(x, y, r, g, b, a)
    r, g, b, a = loco.makeFullColor(r, g, b, a)
    self:_workOnImageData()
    self._imagedata:setPixel(x - 1, self.height - y, r, g, b, a)
    -- Image representation must be rebuilt
    self._image = nil
end

-- untested
function image:copy(x, y, w, h)
    x = x or 1
    y = y or 1
    w = w or self.width
    h = h or self.height
    local newimage = image(w, h)
    for xi = 1, w do for yi = 1, h do
        local r, g, b, a = self:get(x + xi - 1, y + yi - 1)
        newimage:set(xi, yi, r, g, b, a)
    end end
    return newimage
end

function image:_getDrawable()
    if self._imagedata ~= nil then
        if self._image == nil then
            self._image = love.graphics.newImage(self._imagedata)
        end
        return self._image
    else
        return self._canvas
    end
end

function image:getHeight()
    return self.height
end

function image:getWidth()
    return self.width
end
