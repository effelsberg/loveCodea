--
--  Copyright 2012 Two Lives Left Pty. Ltd.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--  http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

-- Class.lua
-- Compatible with Lua 5.1 (not 5.0).

-- Properties for physics API added. Maybe overkill, but seems to work.

function classWithProperties(base)
    local c = {}    -- a new class instance

    if type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        for i,v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end

    c.__index = function(tbl, key)
        if c.getProperty[key] then
            return c.getProperty[key](tbl)
        elseif c[key] then
            return c[key]
        end
        return rawget(tbl, key)
    end
    c.__newindex = function(tbl, key, val)
        if c.setProperty[key] then
            return c.setProperty[key](tbl, val)
        elseif c[key] then
            c[key] = val
        end
        rawset(tbl, key, val)
    end

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj, c)
        if class_tbl.init then
            class_tbl.init(obj, ...)
        elseif base and base.init then
            base.init(obj, ...)
        end

        return obj
    end

    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do
            if m == klass then return true end
            m = m._base
        end
        return false
    end

    c.getProperty = {}
    c.setProperty = {}

    setmetatable(c, mt)
    return c
end