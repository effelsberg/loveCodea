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
-- Transformations and context
--
-- Implements public Codea API:
--   setContext()
--   pushMatrix()
--   popMatrix()
--   resetMatrix()
--   translate()
--   rotate()
--   scale()
--
-- -- ---- ------ ---------- ---------------- --------------------------


-- The current context is the context into the main screen (when nil) or into
-- a user provided context.
-- The pixel context is set internally by loveCodea to draw into images,
-- using the set method on user level. The pixel context is not reverted
-- immediately to allow speedy setting of a huge number of pixels.

loco.transformation_stack = {}
loco.push_count = 0
_context = nil

function setContext(context)
    if context ~= _context then
        loco.unwindTransformations()
        _context = context
        loco.setupCurrentContext()
        loco.replayTransformations()
    end
end

-- Prepares the current context (the one that was set with setContext).
-- Prepares either the main screen (when context is nil) or a different
-- context.
function loco.setupCurrentContext()
    love.graphics.push()
    if _context == nil then
        love.graphics.setCanvas()
        --love.graphics.translate(0, HEIGHT * loco.SCALE - loco.win_y_offset)
        love.graphics.translate(loco.mainwinoffset * loco.SCALE, HEIGHT * loco.SCALE - loco.win_y_offset)
        love.graphics.setScissor(loco.mainwinoffset * loco.SCALE, 0, 10000, 10000)
        love.graphics.scale(loco.SCALE, -loco.SCALE)
    else
        if _context._workOnCanvas ~= nil then
            _context:_workOnCanvas()
            love.graphics.setCanvas(_context:_getDrawable())
        else
            love.graphics.setCanvas(_context)
        end
        love.graphics.translate(0, _context:getHeight())
        love.graphics.setScissor()
        love.graphics.scale(1, -1)
    end
end

-- Pops all matrix transformations, keeps transformation stack.
-- Use loco.setupCurrentContext() and loco.replayTransformations() to
-- re-instatiate the setup.
function loco.unwindTransformations()
    for i = 1, loco.push_count do
        love.graphics.pop()
    end
    love.graphics.pop()
end

function loco.teardownCurrentContext()
    loco.unwindTransformations()
    loco.transformation_stack = {}
    loco.push_count = 0
end

function pushMatrix()
    love.graphics.push()
    table.insert(loco.transformation_stack, {"push"})
    loco.push_count = loco.push_count + 1
end

function popMatrix()
    love.graphics.pop()
    loco.push_count = loco.push_count - 1
    local do_replay = false
    for i = #loco.transformation_stack, 1, -1 do
        local t = table.remove(loco.transformation_stack)
        if t[1] == "reset" then
            do_replay = true
        elseif t[1] == "push" then
            break
        end
    end
    if do_replay then
        for i = 1, loco.push_count do
            love.graphics.pop()
        end
        loco.replayTransformations()
    end
end

function resetMatrix()
    loco.popTransformationStackUntilPush()
    loco.unwindTransformations()
    loco.setupCurrentContext()
    for i = 1, loco.push_count do
        love.graphics.push()
    end
    table.insert(loco.transformation_stack, {"reset"})
end

-- Pops transformations from the stack until it finds a push, not popping
-- the push itself.
function loco.popTransformationStackUntilPush()
    for i = #loco.transformation_stack, 1, -1 do
        local t = loco.transformation_stack[i]
        if t[1] == "push" then
            return
        end
        table.remove(loco.transformation_stack)
    end
end

-- Replays (executes) all transformations on the transformation stack.
-- Pushes are executed but not counted, the push count was and is always
-- the current push count.
function loco.replayTransformations()
    for i = 1, #loco.transformation_stack do
        local t = loco.transformation_stack[i]
        if t[1] == "push" then
            love.graphics.push()
        elseif t[1] == "translate" then
            love.graphics.translate(t[2], t[3])
        elseif t[1] == "rotate" then
            love.graphics.rotate(math.rad(t[2]))
        elseif t[1] == "scale" then
            love.graphics.scale(t[2], t[3])
        end
    end
end

function translate(dx, dy)
    love.graphics.translate(dx, dy)
    table.insert(loco.transformation_stack, {"translate", dx, dy})
end

function rotate(angle)
    love.graphics.rotate(math.rad(angle))
    table.insert(loco.transformation_stack, {"rotate", angle})
end

function scale(sx, sy)
    love.graphics.scale(sx, sy)
    table.insert(loco.transformation_stack, {"scale", sx, sy})
end
