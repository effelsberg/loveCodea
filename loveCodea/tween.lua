-----------------------------------------------------------------------------------------------------------------------
-- tween.lua - v1.0.1 (2012-02)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- tweening functions for lua
-- inspired by jquery's animate function
-----------------------------------------------------------------------------------------------------------------------
tween = {}

-- private stuff

local tweens = setmetatable({}, {__mode = "k"})

local function isCallable(f)
  local tf = type(f)
  if tf == 'function' then return true end
  if tf == 'table' then
    local mt = getmetatable(f)
    return (type(mt) == 'table' and type(mt.__call) == 'function')
  end
  return false
end

local function copyTables(destination, keysTable, valuesTable)
  valuesTable = valuesTable or keysTable
  for k,v in pairs(keysTable) do
    if type(v) == 'table' then
      destination[k] = copyTables({}, v, valuesTable[k])
    else
      destination[k] = valuesTable[k]
    end
  end
  return destination
end

local function checkSubjectAndTargetRecursively(subject, target, path)
  path = path or {}
  local targetType, newPath
  for k,targetValue in pairs(target) do
    targetType, newPath = type(targetValue), copyTables({}, path)
    table.insert(newPath, tostring(k))
    if targetType == 'number' then
      assert(type(subject[k]) == 'number', "Parameter '" .. table.concat(newPath,'/') .. "' is missing from subject or isn't a number")
    elseif targetType == 'userdata' then
      assert(type(subject[k]) == 'userdata', "Parameter '" .. table.concat(newPath,'/') .. "' is missing from subject or isn't a userdata")
    elseif targetType == 'table' then
      checkSubjectAndTargetRecursively(subject[k], targetValue, newPath)
    else
      assert(targetType == 'number', "Parameter '" .. table.concat(newPath,'/') .. "' must be a number or table of numbers")
    end
  end
end

local function getEasingFunction(easing)
  easing = easing or "linear"

  if type(easing) == 'table' then
    easing = easing['easing'] or "linear"
  end

  if type(easing) == 'string' then
    local name = easing
    easing = tween.easing[name]
    assert(type(easing) == 'function', "The easing function name '" .. name .. "' is invalid")
  end
  return easing
end

local function getloopFunction(loop)
  loop = loop or "once"
  
  if type(loop) == 'table' then
    loop = loop['loop'] or "once"
    
    if type(loop) == 'string' then
      local name = loop
      loop = tween.loop[name]
      assert(type(loop) == 'function', "The loop function name '" .. name .. "' is invalid")
    end
  else
    loop = tween.loop.once
  end

  return loop
end

local function checkStartParams(time, subject, target, options, callback)
  local easing = getEasingFunction(options)
  local loop = getloopFunction(options)

  assert(type(time) == 'number' and time > 0, "time must be a positive number. Was " .. tostring(time))
  local tsubject = type(subject)
  assert(tsubject == 'table' or tsubject == 'userdata', "subject must be a table or userdata. Was " .. tostring(subject))
  assert(type(target)== 'table', "target must be a table. Was " .. tostring(target))
  assert(isCallable(easing), "easing must be a function or functable. Was " .. tostring(easing))
  assert(isCallable(loop), "loop must be a function or functable. Was " .. tostring(loop))
  assert(callback==nil or isCallable(callback), "callback must be nil, a function or functable. Was " .. tostring(time))
  checkSubjectAndTargetRecursively(subject, target)

end

local function newTween(time, subject, target, options, callback, args)
  local self = {
    time = time,
    subject = subject,
    target = target,
    easing = getEasingFunction(options),
    loop = getloopFunction(options),
    callback = callback,
    args = args,
    initial = copyTables({}, target, subject),
    running = 0
  }
  tweens[self] = self
  return self
end

local function easeWithTween(self, subject, target, initial)
  local t,b,c,d

  for k,v in pairs(target) do
    if type(v)=='table' then
      easeWithTween(self, subject[k], v, initial[k])
    else
      t,b,c,d = self.running, initial[k], v - initial[k], self.time
      
      if self.loop then
        t = self.loop(t,d)
      end

      subject[k] = self.easing(t,b,c,d)
    end
  end
end

local function updateTween(self, dt)
  self.running = self.running + dt
  easeWithTween(self, self.subject, self.target, self.initial)
end

local function hasExpiredTween(self)
  if self.loop == tween.loop.once then
    return self.running >= self.time
  else
    return false
  end
end

local function finishTween(self)
  --copyTables(self.subject, self.target)
  self.running = self.time
  easeWithTween(self, self.subject, self.target, self.initial)
  if self.callback then self.callback(unpack(self.args)) end

  tween.stop(self)

  if self.next then
    self.next.initial = copyTables(self.next.initial, self.target, self.subject)
    tweens[self.next] = self.next
  end

end

local function resetTween(self)
  self.running = 0
  easeWithTween(self, self.subject, self.target, self.initial)
  --copyTables(self.subject, self.initial)
end

-- paths

local function pathFactory(subject, values)
    local len = #values
    
    assert(len >= 1, "Path length must be one or greater")
    
    local keys = {}
    for k,v in pairs(values[1]) do
        table.insert(keys,k)
    end
    
    local pathFunc = function(t,k)
        
        t = (1 + (t*(len-1)))
        
        local i2 = math.floor(t)
        local i1 = math.max(i2 - 1, 1)
        local i3 = math.min(i2 + 1, len)
        local i4 = math.min(i3 + 2, len)
        
        t = t - i2
        
        local p1 = values[i1][k]
        local p2 = values[i2][k]
        local p3 = values[i3][k]
        local p4 = values[i4][k]
        
        local t2 = t*t
        local t3 = t*t*t
        
        return 0.5 * ( (2*p2) + 
                       (-p1+p3)*t + 
                       (2*p1 - 5*p2 + 4*p3 - p4)*t2 + 
                       (-p1 + 3*p2 - 3*p3 + p4)*t3)
    end
    
    local proxy = {}
    local mt = 
    {
        __index = function(table,k)
            if k == 't' then
                return 0
            end
            return rawget(table,k)
        end,
        
        __newindex = function(table,k,v)
            if k == 't' then
                for i,key in ipairs(keys) do
                    subject[key] = pathFunc(v,key)
                end
            else
                rawset(table,k,v)
            end
        end 
    }
    setmetatable(proxy,mt)
    return proxy
end



-- easing

-- Adapted from https://github.com/EmmanuelOga/easing. See LICENSE.txt for credits.
-- For all easing functions:
-- t = time == how much time has to pass for the tweening to complete
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = duration == running time. How much time has passed *right now*

local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

-- linear
local function linear(t, b, c, d) return c * t / d + b end

-- quad
local function inQuad(t, b, c, d) return c * pow(t / d, 2) + b end
local function outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end
local function inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end
local function outInQuad(t, b, c, d)
  if t < d / 2 then return outQuad(t * 2, b, c / 2, d) end
  return inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
local function inCubic (t, b, c, d) return c * pow(t / d, 3) + b end
local function outCubic(t, b, c, d) return c * (pow(t / d - 1, 3) + 1) + b end
local function inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end
local function outInCubic(t, b, c, d)
  if t < d / 2 then return outCubic(t * 2, b, c / 2, d) end
  return inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
local function inQuart(t, b, c, d) return c * pow(t / d, 4) + b end
local function outQuart(t, b, c, d) return -c * (pow(t / d - 1, 4) - 1) + b end
local function inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 4) + b end
  return -c / 2 * (pow(t - 2, 4) - 2) + b
end
local function outInQuart(t, b, c, d)
  if t < d / 2 then return outQuart(t * 2, b, c / 2, d) end
  return inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
local function inQuint(t, b, c, d) return c * pow(t / d, 5) + b end
local function outQuint(t, b, c, d) return c * (pow(t / d - 1, 5) + 1) + b end
local function inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 5) + b end
  return c / 2 * (pow(t - 2, 5) + 2) + b
end
local function outInQuint(t, b, c, d)
  if t < d / 2 then return outQuint(t * 2, b, c / 2, d) end
  return inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
local function inSine(t, b, c, d) return -c * cos(t / d * (pi / 2)) + c + b end
local function outSine(t, b, c, d) return c * sin(t / d * (pi / 2)) + b end
local function inOutSine(t, b, c, d) return -c / 2 * (cos(pi * t / d) - 1) + b end
local function outInSine(t, b, c, d)
  if t < d / 2 then return outSine(t * 2, b, c / 2, d) end
  return inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
local function inExpo(t, b, c, d)
  if t == 0 then return b end
  return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
end
local function outExpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
end
local function inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
end
local function outInExpo(t, b, c, d)
  if t < d / 2 then return outExpo(t * 2, b, c / 2, d) end
  return inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
local function inCirc(t, b, c, d) return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b) end
local function outCirc(t, b, c, d)  return(c * sqrt(1 - pow(t / d - 1, 2)) + b) end
local function inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
  t = t - 2
  return c / 2 * (sqrt(1 - t * t) + 1) + b
end
local function outInCirc(t, b, c, d)
  if t < d / 2 then return outCirc(t * 2, b, c / 2, d) end
  return inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end
local function inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end
local function outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end
local function inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end
local function outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return outElastic(t * 2, b, c / 2, d, a, p) end
  return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
local function inBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end
local function outBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end
local function inOutBack(t, b, c, d, s)
  s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end
local function outInBack(t, b, c, d, s)
  if t < d / 2 then return outBack(t * 2, b, c / 2, d, s) end
  return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
local function inBounce(t, b, c, d) return c - outBounce(d - t, 0, c, d) + b end
local function inOutBounce(t, b, c, d)
  if t < d / 2 then return inBounce(t * 2, 0, c, d) * 0.5 + b end
  return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end
local function outInBounce(t, b, c, d)
  if t < d / 2 then return outBounce(t * 2, b, c / 2, d) end
  return inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

tween.easing = {
  linear = linear,
  quadIn    = inQuad,    quadOut    = outQuad,    quadInOut    = inOutQuad,    quadOutIn    = outInQuad,
  cubicIn   = inCubic,   cubicOut   = outCubic,   cubicInOut   = inOutCubic,   cubicOutIn   = outInCubic,
  quartIn   = inQuart,   quartOut   = outQuart,   quartInOut   = inOutQuart,   quartOutIn   = outInQuart,
  quintIn   = inQuint,   quintOut   = outQuint,   quintInOut   = inOutQuint,   quintOutIn   = outInQuint,
  sineIn    = inSine,    sineOut    = outSine,    sineInOut    = inOutSine,    sineOutIn    = outInSine,
  expoIn    = inExpo,    expoOut    = outExpo,    expoInOut    = inOutExpo,    expoOutIn    = outInExpo,
  circIn    = inCirc,    circOut    = outCirc,    circInOut    = inOutCirc,    circOutIn    = outInCirc,
  elasticIn = inElastic, elasticOut = outElastic, elasticInOut = inOutElastic, elasticOutIn = outInElastic,
  backIn    = inBack,    backOut    = outBack,    backInOut    = inOutBack,    backOutIn    = outInBack,
  bounceIn  = inBounce,  bounceOut  = outBounce,  bounceInOut  = inOutBounce,  bounceOutIn  = outInBounce,
}

-- ping pong

local function round(num)
  if num >= 0 then return math.floor(num+.5)
  else return math.ceil(num-.5) end
end

local function triangleWave(x)
  return 1 - 2 * math.abs(round(0.5 * x) - 0.5*x)
end

local function frac(x)
  local a,b = math.modf(x)
  return b
end

local function sawtooth(x)
  return frac(0.5 * x)
end

local function forever(t,d)
  return sawtooth(t/(d/2)) * d
end

local function pingpong(t,d)
    return (1-triangleWave(t/d)) * d
end

local function once(t,d)
    return math.min(t,d)
end

tween.loop = 
{
    once = once,
    forever = forever,
    pingpong = pingpong
}

-- public functions

function tween.start(time, subject, target, options, callback, ...)
  checkStartParams(time, subject, target, options, callback)
  return newTween(time, subject, target, options, callback, {...})
end

function tween.sequence(...)

    assert(arg.n > 0, "a sequence must consist of at least one tween")

    local head = arg[1]
    local tail = arg[arg.n]

    for i,id in ipairs(arg) do
        local tw = tweens[id]
        
        tw.head = head
        tw.tail = tail

        if i < arg.n then
            tw.next = arg[i+1]
        end

        -- remove all except the first tween
        if i > 1 and tw then
            tweens[id] = nil
        end
    end

    return arg[1]
end

function tween.path(time, subject, target, options, callback, ...)

  -- need to check that target is an array and contains valid keys
  return newTween(time, pathFactory(subject, target) , {t=1}, options, callback, {...})
end

setmetatable(tween, { __call = function(t, ...) return tween.start(...) end })

function tween.reset(id)
  local tw = tweens[id]
  if tw then
    resetTween(tw)
    tween.stop(tw)
  end
end

function tween.resetAll(id)
  for _,tw in pairs(tweens) do 
    resetTween(tw)
    --copyTables(tw.subject, tw.initial)
  end
  tween.stopAll()
end

function tween.stop(id)

  -- this tween object is the head of a sequence, stop all connected tweens
  if id.head and id.head == id then
    local next = id.next
    while next ~= nil do
      tweens[next]=nil
      next = next.next
    end
  end

  if id~=nil then tweens[id]=nil end
end

function tween.stopAll()
  tweens = setmetatable({}, {__mode = "k"})
end

function tween.hasExpired(id)
  local tw = tweens[id]
  if tw then
    return hasExpiredTween(id)
  end
  return true
end

function tween.update(dt)
  assert(type(dt) == 'number' and dt > 0, "dt must be a positive number")
  local expired = {}
  for _,t in pairs(tweens) do
    updateTween(t, dt)
    if hasExpiredTween(t) then table.insert(expired, t) end
  end
  for i=1, #expired do finishTween(expired[i]) end
end

