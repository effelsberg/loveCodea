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
-- Network
--
-- Implements public Codea API:
--   http.request()
--
-- -- ---- ------ ---------- ---------------- --------------------------

loco.sockhttp = require("socket.http")

http = {}

-- Unlike in Codea's implementation, successFunction is called immediately.
function http.request(url, successFunction)
    local body, status, headers = loco.sockhttp.request(url)
    successFunction(body, status, headers)
end
