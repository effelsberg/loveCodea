Track = class()

function Track:init(x, y, dir)
    self.x = x
    self.y = y
    self.dir = dir
    self.active = 1
    self.turn = 0
    self.bounds = Frame(self.x - 5, self.y - 5, 
    self.x + 5, self.y + 5)
end

function Track:draw()
    local i
    i = self.active - 1
    if self.active > 1 then self.active = self.active + 1 end
    pushStyle()
    strokeWidth(1)
    stroke(255, 198, 0, 176)
    noFill()
    pushMatrix()
    translate(self.x, self.y)
    rotate(self.dir)
    rotate( i * 20)
    scale(1 + i * 0.1)
    rect(-15, -10, -5, 5)
    rect(-18, 8, -14, 12)
    rect(-12, 8, -8, 12)
    rect(-6, 8, -2, 12)
    rotate(-i * 40)
    rect(5, 0, 15, 15)
    rect(2, 18, 6, 22)
    rect(8, 18, 12, 22)
    rect(14, 18, 18, 22)
    
    popMatrix()
    popStyle()
end
