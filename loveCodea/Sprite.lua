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
-- Draw sprites
--
-- Implements public Codea API:
--   sprite()
--   spriteSize()
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.sprite_list = {}

function spriteMode(mode)
    loco.style.spritemode = mode
end

-- Load & Register Sprite and Draw it
function sprite(name_or_image, x, y, width, height)
    x = x or 0
    y = y or 0
    if type(name_or_image) == "string" then
        loco.loadSprite(name_or_image)
        loco.spriteDraw(loco.sprite_list[name_or_image], x, y, width, height)
    else
        loco.spriteDraw(name_or_image, x, y, width, height )
    end
end

function spriteSize(filename)
    loco.loadSprite(filename)
    local img = loco.sprite_list[filename]
    local w = img:getWidth()
    local h = img:getHeight()
    return w, h
end

function loco.loadSprite(filename)
    if loco.sprite_list[filename] == nil then
        local realname1 = filename:gsub("%:",".spritepack/") .. ".png"
        local realname2 = filename:gsub("%:","/") .. ".png"
        if love.filesystem.isFile(realname1) then
            loco.sprite_list[filename] = love.graphics.newImage(realname1)
        else
            loco.sprite_list[filename] = love.graphics.newImage(realname2)
        end
    end
    return loco.sprite_list[filename]
end

function loco.spriteDraw(image, x, y, width, height)
    -- image dimensions
    local w = image:getWidth()
    local h = image:getHeight()
    -- image dimension scale factors
    local sx = 1
    local sy = 1
    if width ~= nil then
        sx = width / w
        -- scale height properly if only width is given
        if height == nil then
            sy = sx
            height = h * sy
        end
    end
    if height ~= nil then
        sy = height / h
    end
    width = width or w
    height = height or h

    if loco.style.notint then
        love.graphics.setBlendMode("replace")
    else
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(unpack(loco.style.tintcolor))
    end
    x = x or 0
    y = y or 0
    if loco.style.spritemode == CORNERS then
        if x > width then
            x, width = width, x
        end
        if y < height then
            y, height = height, y
        end
    end
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(1, -1)
    if image._getDrawable ~= nil then
        image = image:_getDrawable()
    end
    if loco.style.spritemode == CENTER then
        love.graphics.draw(image, -width / 2, -height / 2, 0, sx, sy)
    elseif loco.style.spritemode == CORNERS then
        sx = (width - x) / w
        sy = (y - height) / h
        love.graphics.draw(image, 0, 0, 0, sx, sy)
    else
        -- CORNER (lower left)
        love.graphics.draw(image, 0, -height, 0, sx, sy)
    end
    love.graphics.pop()
    love.graphics.setBlendMode("alpha")
end
