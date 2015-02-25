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
-- Read and write plists
--
-- Implements public Codea API:
--   readLocalData()
--   saveLocalData()
--   listLocalData()
--   readProjectData()
--   saveProjectData()
--   listProjectData()
--   clearProjectData()
--   readProjectInfo()
--   saveProjectInfo()
--   readGlobalData()
--   saveGlobalData()
--   listGlobalData()
--
-- -- ---- ------ ---------- ---------------- --------------------------

-- Reads a plist file and returns the contents as a dict.
-- Returns status, dict.
-- |status| is eiter "ok" or an error message
-- |dict| is only returned if |status| is "ok"
function loco.readPlist(filename)
    if not love.filesystem.isFile(filename) then
        return "File not found: " .. filename
    end
    contents = love.filesystem.read(filename)

    pl1, pl2, m = string.find(contents, "<plist version=\"1.0\">.*<dict>(.*)</dict>.*</plist>")
    if m == nil then
        return "Not a valid plist file: " .. filename
    end

    local dict = {}
    local pos = 0
    local pos, key = loco.nextKey(m, pos)
    while key ~= nil do
        local v, n
        pos, v = loco.nextValue(m, pos)
        -- Reading hot fix. Interpret as a number if it looks like a number.
        n = tonumber(v)
        if n ~= nil then
            dict[key] = n
        else
            dict[key] = v
        end
        pos, key = loco.nextKey(m, pos)
    end
    return "ok", dict
end

function loco.nextKey(str, p)
    local k1, k2, key = string.find(m, "<key>(.-)</key>", p)
    if key ~= nil then
        p = k2 + 1
    end
    return p, key
end

function loco.nextValue(str, p)
    -- Find a tag
    local ts1, ts2, tag = string.find(str, "<(.-)>", p)
    if tag == nil then return
        p, nil
    end
    p = ts2 + 1
    -- Tags like <false/>
    if string.sub(tag, -1) == "/" then
        return p, string.sub(tag, 1, -2)
    end
    -- Find matching end tag
    local te1, te2, value = string.find(str, "(.-)</" .. tag .. ">", p)
    p = te2 + 1
    -- Recurse into arrays
    if tag == "array" then
        local array = {}
        local subidx = 0
        local subidx, subvalue = nextValue(value, subidx)
        while subvalue ~= nil do
            table.insert(array, subvalue)
            subidx, subvalue = loco.nextValue(value, subidx)
        end
        value = array
    end
    return p, value
end

function loco.writePlist(filename, dict)
    local plist = love.filesystem.newFile(filename)
    if plist == nil then return end
    plist:open("w")
    plist:write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    plist:write("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" ")
    plist:write("\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
    plist:write("<plist version=\"1.0\">\n")
    plist:write("<dict>\n")

    for k, v in pairs(dict) do
        plist:write("\t<key>" .. k .. "</key>\n")
        if type(v) == "table" then
            plist:write("\t<array>\n")
            for _, item in pairs(v) do
                plist:write("\t\t<string>" .. item .. "</string>\n")
            end
            plist:write("\t</array>\n")
        elseif type(v) == "boolean" then
            plist:write("\t<" .. v .. "/>\n")
        else
            plist:write("\t<string>" .. v .. "</string>\n")
        end
    end

    plist:write("</dict>\n")
    plist:write("</plist>\n")
    plist:close()
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Init plist dicts on demand
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.savedir = love.filesystem.getSaveDirectory()
-- Keep last part of save dir as identity
loco.identity = string.gsub(loco.savedir, ".*/", "")

function loco.initLocalData()
    love.filesystem.setIdentity(loco.identity)
    if loco.localdata == nil then
        status, dict = loco.readPlist("Local.plist")
        if status == "ok" then
            loco.localdata = dict
        else
            loco.localdata = {}
        end
    end
end

function loco.initProjectData()
    love.filesystem.setIdentity(loco.identity)
    if loco.projectdata == nil then
        status, dict = loco.readPlist("Data.plist")
        if status == "ok" then
            loco.projectdata = dict
        else
            loco.projectdata = {}
        end
    end
end

function loco.initGlobalData()
    love.filesystem.setIdentity("CodeaGlobal")
    if loco.globaldata == nil then
        status, dict = loco.readPlist("Global.plist")
        if status == "ok" then
            loco.globaldata = dict
        else
            loco.globaldata = {}
        end
    end
end

function loco.initProjectInfo()
    love.filesystem.setIdentity(loco.identity)
    if loco.projectinfo == nil then
        status, dict = loco.readPlist("Info.plist")
        if status == "ok" then
            loco.projectinfo = dict
        else
            loco.projectinfo = {}
        end
    end
end

-- -- ---- ------ ---------- ---------------- --------------------------
--
-- Codea functions
--
-- -- ---- ------ ---------- ---------------- --------------------------

function readLocalData(key, default)
    loco.initLocalData()
    return loco.localdata[key] or default
end

function saveLocalData(key, value)
    loco.initLocalData()
    loco.localdata[key] = value
    loco.writePlist("Local.plist", loco.localdata)
end

function listLocalData()
    local keys = {}
    loco.initLocalData()
    for k, v in pairs(loco.localdata) do
        table.insert(keys, k)
    end
    return keys
end

function readProjectData(key, default)
    loco.initProjectData()
    return loco.projectdata[key] or default
end

function saveProjectData(key, value)
    loco.initProjectData()
    loco.projectdata[key] = value
    loco.writePlist("Data.plist", loco.projectdata)
end

function listProjectData()
    local keys = {}
    loco.initProjectData()
    for k, v in pairs(loco.projectdata) do
        table.insert(keys, k)
    end
    return keys
end

function clearProjectData()
    loco.writePlist("Data.plist", {})
end

function readProjectInfo(key, default)
    loco.initProjectInfo()
    return loco.projectinfo[key] or default
end

function saveProjectInfo(key, value)
    loco.initProjectInfo()
    loco.projectinfo[key] = value
    loco.writePlist("Info.plist", loco.projectinfo)
end

function readGlobalData(key, default)
    loco.initGlobalData()
    return loco.globaldata[key] or default
end

function saveGlobalData(key, value)
    loco.initGlobalData()
    loco.globaldata[key] = value
    loco.writePlist("Global.plist", loco.globaldata)
end

function listGlobalData()
    local keys = {}
    loco.initGlobalData()
    for k, v in pairs(loco.globaldata) do
        table.insert(keys, k)
    end
    return keys
end
