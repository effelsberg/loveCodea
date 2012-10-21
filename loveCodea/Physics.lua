-- -- ---- ------ ---------- ---------------- --------------------------
--
-- This file is part of loveCodea.
-- Copyright 2012 Stephan Effelsberg
-- Licensed under the MIT license:
--     http://www.opensource.org/licenses/mit-license.php
--
-- -- ---- ------ ---------- ---------------- --------------------------


physics = {}

CIRCLE   = 0
EDGE     = 1
POLYGON  = 2
CHAIN    = 3
COMPOUND = 4

STATIC    = 0
KINEMATIC = 1
DYNAMIC   = 2

REVOLUTE  = 0
PRISMATIC = 1
DISTANCE  = 2
WELD      = 3
ROPE      = 4

loco.DEFAULT_WORLD_GRAVITY_X = 0
loco.DEFAULT_WORLD_GRAVITY_Y = -9.8 * 5

loco.world = love.physics.newWorld(loco.DEFAULT_WORLD_GRAVITY_X, loco.DEFAULT_WORLD_GRAVITY_Y)
loco.physics_paused = false
-- pixel to meter
loco.ptm = 30

function physics.pause()
    loco.physics_paused = true
end

function physics.resume()
    loco.physics_paused = false
end

function loco.updatePhysics(dt)
    if not loco.physics_paused then
        loco.world:update(dt)
    end
end

function physics.gravity(x, y)
    if x == nil then
        x, y = loco.world:getGravity()
        return vec2(x, y)
    else
        if y == nil then
            -- x is (should be) a vector
            loco.world:setGravity(x.x, x.y)
        else
            loco.world:setGravity(x, y)
        end
    end
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Body
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.Body = classWithProperties()

function loco.Body:init()
    self.radius = 0
    self.points = {}
    self.position = vec2(0, 0)
end

function loco.Body:destroy()
    if self._fixture then self._fixture:destroy() end
    if self._body then self._body:destroy() end
    self._fixture = nil
    self._body = nil
end

function loco.Body.getProperty:type()
    local t = self._body:getType()
    if t == "static" then return STATIC end
    if t == "kinematic" then return KINEMATIC end
    return DYNAMIC
end
function loco.Body.setProperty:type(v)
    if v == STATIC then
        self._body:setType("static")
    elseif v == KINEMATIC then
        self._body:setType("kinematic")
    elseif v == DYNAMIC then
        self._body:setType("dynamic")
    end
end

function loco.Body.getProperty:x()
    return self._body:getX()
end
function loco.Body.setProperty:x(v)
    self._body:setX(v)
end

function loco.Body.getProperty:y()
    return self._body:getY()
end
function loco.Body.setProperty:y(v)
    self._body:setY(v)
end

function loco.Body.getProperty:angle()
    return math.deg(self._body:getAngle())
end
function loco.Body.setProperty:angle(v)
    self._body:setAngle(math.rad(v))
end

function loco.Body.getProperty:restitution()
    return self._fixture:getRestitution()
end
function loco.Body.setProperty:restitution(v)
    self._fixture:setRestitution(v)
end

function loco.Body:testPoint(worldpoint)
    return self._fixture:testPoint(worldpoint.x, worldpoint.y)
end

function loco.Body:getLocalPoint(touchpoint)
    local x, y = self._body:getLocalPoint(touchpoint.x, touchpoint.y)
    return vec2(x, y)
end

function loco.Body:getWorldPoint(localpoint)
    local x, y = self._body:getWorldPoint(localpoint.x, localpoint.y)
    return vec2(x, y)
end

function loco.Body:getLinearVelocityFromWorldPoint(worldpoint)
    local vx, vy = self._body:getLinearVelocityFromWorldPoint(worldpoint.x, worldpoint.y)
    return vec2(vx, vy)
end

function loco.Body:applyForce(force, worldpoint)
    if worldpoint ~= nil then
        self._body:applyForce(force.x, force.y, worldpoint.x, worldpoint.y)
    else
        self._body:applyForce(force.x, force.y)
    end
end

function physics.body(bodytype, ...)
    local body = loco.Body()
    --body.shapeType = bodytype
    body._body = love.physics.newBody(loco.world, 0, 0, "dynamic")
    if bodytype == POLYGON then
        body.shapeType = POLYGON
        local points = {}
        local parts = {}
        local npoints = 0
        for i = 1,arg.n do
            if type(arg[i]) == "number" then
                table.insert(parts, arg[i])
                npoints = npoints + 1
            else
                table.insert(parts, arg[i].x)
                table.insert(parts, arg[i].y)
                npoints = npoints + 2
            end
            table.insert(points, arg[i])
            -- Love limit: no more than 8 vertices
            if npoints >= 16 then break end
        end
        body._shape = love.physics.newPolygonShape(unpack(parts))
        body._fixture = love.physics.newFixture(body._body, body._shape)
        body.points = points
    end
    if bodytype == CIRCLE then
        body.shapeType = CIRCLE
        body.radius = arg[1]
        body._shape = love.physics.newCircleShape(body.radius)
        body._fixture = love.physics.newFixture(body._body, body._shape)
    end
    return body
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Joint
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.Joint = classWithProperties()

function loco.Joint:init()
end

function loco.Joint:destroy()
    -- FIXME Physics Lab Test 2 complains about using a destroyed joint
    --       the very first time this is called.
    --if self._joint then self._joint:destroy() end
    self._joint = nil
end

function loco.Joint.getProperty:anchorA()
    local x1, y1, x2, y2 = self._joint:getAnchors()
    return vec2(x1, y1)
end

function loco.Joint.getProperty:anchorB()
    local x1, y1, x2, y2 = self._joint:getAnchors()
    return vec2(x2, y2)
end

function loco.Joint.setProperty:enableLimit(v)
    self._joint:enableLimit(v)
end

function loco.Joint.getProperty:upperLimit(v)
    return self._joint:getUpperLimit()
end
function loco.Joint.setProperty:upperLimit(v)
    self._joint:setUpperLimit(v)
end

function physics.joint(jointtype, bodya, bodyb, anchora, anchorb)
    local joint
    local j

    if jointtype == REVOLUTE then
        j = love.physics.newRevoluteJoint(bodya._body, bodyb._body,
                anchora.x, anchora.y)
    elseif jointtype == PRISMATIC then
        j = love.physics.newPrismaticJoint(bodya._body, bodyb._body,
                anchora.x, anchora.y, anchorb.x * loco.ptm, anchorb.y * loco.ptm)
    elseif jointtype == DISTANCE then
        j = love.physics.newDistanceJoint(bodya._body, bodyb._body,
                anchora.x, anchora.y, anchorb.x, anchorb.y)
    end

    if j ~= nil then
        joint = loco.Joint()
        joint._joint = j
    end

    return joint
end
