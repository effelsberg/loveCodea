Ttouch = class()

-- Translatable Touch 
-- ver. 1.0
-- maps fields of a touch but is easily modified.
-- ====================.

function Ttouch:init(touch)
    self.x = touch.x
    self.y = touch.y
    self.state = touch.state
    self.prevX = touch.prevX
    self.prevY = touch.prevY
    self.deltaX = touch.deltaX
    self.deltaY = touch.deltaY
    self.id = touch.id
    self.tapCount = touch.tapCount
    self.timer = 0
end

function Ttouch:translate(x, y)
    self.x = self.x - x
    self.y = self.y - y
end
