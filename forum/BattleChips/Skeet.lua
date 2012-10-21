Skeet = class()

function Skeet:init(x, y, bounds)
    self.x = x
    self.y = y
    self.color = color(255, 250, 0, 255)
    self.active = 1
    if math.random(4) > 2 then 
        self.dx = -1
    else
        self.dx = 1
    end
    self.dy = 1
    self.turn = 0
    self.maxX = bounds:width()
    self.maxY = bounds:height() + 5
    self.bounds = Frame(self.x - 10, self.y - 10, 
    self.x + 10, self.y + 10)
end 

function Skeet:draw(bounds)
    pushMatrix()
    pushStyle()
    strokeWidth(1)
    noFill()
    translate(self.x, self.y)
    rotate(self.turn)
    scale(self.active)
    if self.active > 1 then self.active = self.active + 1 end
    stroke(0, 255, 244, 255 - self.active * 25)
    
    
    ellipse(0, 0, 20)
    line(- 10, 0, 10, 0)
    line(0, - 10, 0, 10)
    line(- 7, - 7, 7, 7)
    line(- 7, 7, 7, -7)
    popMatrix()
    popStyle()
    self.x = self.x + self.dx
    self.y = self.y + self.dy
    if self.x < 10 then self.dx = -self.dx end
    if self.y < 10 then self.dy = -self.dy end
    if self.x > self.maxX then self.dx = -self.dx end
    if self.y > self.maxY then self.dy = -self.dy end
    self.turn = self.turn + 5
    if self.turn > 359 then self.turn = 0 end
    self.bounds = Frame(self.x - 10, self.y - 10, 
    self.x + 10, self.y + 10)
end