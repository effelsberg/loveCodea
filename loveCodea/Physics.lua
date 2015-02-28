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

-- pixel to meter
loco.ptm = 32

loco.DEFAULT_WORLD_GRAVITY_X = 0
loco.DEFAULT_WORLD_GRAVITY_Y = -9.8 * loco.ptm

loco.world = love.physics.newWorld(loco.DEFAULT_WORLD_GRAVITY_X, loco.DEFAULT_WORLD_GRAVITY_Y)
loco.physics_paused = false

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

loco.body_list = {}
-- Next unique ID to use for fixture
loco.fixture_id = 0

loco.Body = classWithProperties()

function loco.Body:init()
    self.points = {}
    self.position = vec2(0, 0)
end

function loco.Body:destroy()
    -- Remove body from my list
    for i, bd in ipairs(loco.body_list) do
        if bd == self then
            table.remove(loco.body_list, i)
            break
        end
    end
    -- Destroy body in Love
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

function loco.Body.getProperty:radius()
    return self._shape:getRadius()
end
function loco.Body.setProperty:radius(v)
    self._shape:setRadius(v)
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

function loco.Body.getProperty:density()
    return self._fixture:getDensity()
end
function loco.Body.setProperty:density(v)
    self._fixture:setDensity(v)
end

function loco.Body.getProperty:friction()
    return self._fixture:getFriction()
end
function loco.Body.setProperty:friction(v)
    self._fixture:setFriction(v)
end

function loco.Body.getProperty:linearVelocity()
    local x, y = self._body:getLinearVelocity()
    return vec2(x, y)
end
function loco.Body.setProperty:linearVelocity(v)
    self._body:setLinearVelocity(v.x, v.y)
end

function loco.Body.setProperty:bullet(v)
    self._body:setBullet(v)
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
        self._body:applyForce(force.x * loco.ptm, force.y * loco.ptm, worldpoint.x, worldpoint.y)
    else
        self._body:applyForce(force.x * loco.ptm, force.y * loco.ptm)
    end
end

function physics.body(bodytype, ...)
    local body = loco.Body()
    local make_fixture = false
    --body.shapeType = bodytype
    local arg = {...}
    body._body = love.physics.newBody(loco.world, 0, 0, "dynamic")
    if bodytype == POLYGON then
        body.shapeType = POLYGON
        local points = {}
        local parts = {}
        local npoints = 0
        for i = 1,#arg do
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
        make_fixture = true
        body.points = points
    end
    if bodytype == CIRCLE then
        body.shapeType = CIRCLE
        body._shape = love.physics.newCircleShape(arg[1])
        make_fixture = true
    end
    if bodytype == EDGE then
        body.shapeType = EDGE
        body._body:setType("static")
        body._shape = love.physics.newEdgeShape(arg[1].x, arg[1].y, arg[2].x, arg[2].y)
        make_fixture = true
    end
    if make_fixture then
        body._fixture = love.physics.newFixture(body._body, body._shape)
        body._fixture:setUserData({id = loco.fixture_id})
        loco.fixture_id = loco.fixture_id + 1
    end
    table.insert(loco.body_list, body)
    return body
end

function loco.findBodyByFixtureId(fid)
    for i, bd in ipairs(loco.body_list) do
        local ud = bd._fixture:getUserData()
        if ud.id == fid then
            return bd
        end
    end
    return nil
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
    -- not all joints have limits
    if self._joint.enableLimit then
        self._joint:enableLimit(v)
    end
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
                --anchora.x, anchora.y, anchorb.x * loco.ptm, anchorb.y * loco.ptm)
                anchora.x, anchora.y, anchorb.x, anchorb.y)
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

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Contacts
--
-- -- ---- ------ ---------- ---------------- --------------------------

-- Contact fields needed for Physics Lab:
--   .id
--   .state
--   .points
-- For Cargo-Bot
--   .normalImpulse
-- For Orbital by Spirikoi
--   .bodyA  Must be loco's body
--   .bodyB
-- Private fields:
--   ._id_a  ID of fixture a
--   ._id_b  ID of fixture b

loco.contact_list = {}
-- Next unique ID to use for contact
loco.contact_id = 0

-- Called by Love's physics engine when a new contact occurs.
function loco.beginContact(fixa, fixb, ct)
    -- Make a new unique contact
    local contact = {}
    contact.id = loco.contact_id
    loco.contact_id = loco.contact_id + 1
    contact.state = BEGAN
    -- A contact can have 1 or 2 points
    local points = {}
    local x1, y1, x2, y2 = ct:getPositions()
    table.insert(points, vec2(x1, y1))
    if x2 ~= nil then
        table.insert(points, vec2(x2, y2))
    end
    contact.points = points
    contact.normalImpulse = 0
    -- Bodies
    local ud_a = fixa:getUserData()
    local ud_b = fixb:getUserData()
    contact.bodyA = loco.findBodyByFixtureId(ud_a.id)
    contact.bodyB = loco.findBodyByFixtureId(ud_b.id)
    -- Private data
    contact._id_a = ud_a.id
    contact._id_b = ud_b.id
    -- Register contact in my list
    table.insert(loco.contact_list, contact)
    -- Call user's collide if provided
    if collide ~= nil then
        collide(contact)
    end
end

-- Find a contact in |contact_list| by the participating fixtures' IDs.
function loco.findContactIdx(id_a, id_b)
    for i, ct in ipairs(loco.contact_list) do
        if ct._id_a == id_a and ct._id_b == id_b then
            return i
        end
    end
    return nil
end

-- Called by Love's physics engine when a new contact end.
function loco.endContact(fixa, fixb, ct)
    -- Find my corresponding contact
    local ud_a = fixa:getUserData()
    local ud_b = fixb:getUserData()
    local contact_idx = loco.findContactIdx(ud_a.id, ud_b.id)
    if contact_idx == nil then
        print("Unregistered contact ended")
    else
        local contact = loco.contact_list[contact_idx]
        -- Call user's collide if provided
        if collide then
            contact.state = ENDED
            collide(contact)
        end
        table.remove(loco.contact_list, contact_idx)
    end
end

-- Called by Love's physics engine when a new contact moves.
function loco.postSolve(fixa, fixb, ct, normal_impulse)
    -- Find my corresponding contact
    local ud_a = fixa:getUserData()
    local ud_b = fixb:getUserData()
    local contact_idx = loco.findContactIdx(ud_a.id, ud_b.id)
    if contact_idx == nil then
        print("Unregistered contact moves")
    else
        local contact = loco.contact_list[contact_idx]
        -- Update points
        local points = {}
        local x1, y1, x2, y2 = ct:getPositions()
        table.insert(points, vec2(x1, y1))
        if x2 ~= nil then
            table.insert(points, vec2(x2, y2))
        end
        contact.points = points
        contact.normalImpulse = normal_impulse
        contact.state = MOVING
        loco.contact_list[contact_idx] = contact
        -- Call user's collide if provided
        if collide then
            collide(contact)
        end
    end
end

-- Register collision callbacks
loco.world:setCallbacks(loco.beginContact, loco.endContact, nil, loco.postSolve)

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Raycast
--
-- -- ---- ------ ---------- ---------------- --------------------------

function physics.raycast(p1, p2)
    loco.raycast_collection = {}
    loco.world:rayCast(p1.x, p1.y, p2.x, p2.y, loco.raycastCollector)
    -- Love's doc says that no assumption shall be made.
    -- Nevertheless, I'll make one.
    return loco.raycast_collection[1]
end

function physics.raycastAll(p1, p2)
    local raycast_collection = {}
    loco.world:rayCast(p1.x, p1.y, p2.x, p2.y,
        function (fixture, x, y, xn, yn, fraction)
            local r = {}
            r.body = loco.findBodyByFixtureId(fixture:getUserData().id)
            r.point = vec2(x, y)
            r.normal = vec2(xn, yn)
            r.fraction = fraction
            table.insert(raycast_collection, r)
            -- -1: ignore
            return -1
        end
    )
    return raycast_collection
end

function physics.queryAABB(lowerleft, upperright)
    local aabb_collection = {}
    -- Expected parameters:
    --   queryBoundingBox( topLeftX, topLeftY, bottomRightX, bottomRightY, callback )
    -- Doesn't seem to matter if lower, upper, left and right are really
    -- what they mean to be. Seems they get sorted anyway.
    --loco.world:queryBoundingBox(lowerleft.x, upperright.y, upperright.x, lowerleft.y,
    loco.world:queryBoundingBox(lowerleft.x, lowerleft.y, upperright.x, upperright.y,
        function (fixture)
            local body = loco.findBodyByFixtureId(fixture:getUserData().id)
            table.insert(aabb_collection, body)
            -- true: continue query
            return true
        end
    )
    return aabb_collection
end
