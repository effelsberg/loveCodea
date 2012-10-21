PenPoint = class()

function PenPoint:init(x, y, s)
    -- just a little way to doodle
    self.x = x
    self.y = y
    self.status = s
end