CodeBench = class()

function CodeBench:init(x, y)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.frame = Frame(x, y, x + 500, y + 850)
    self.header = Frame(self.frame.left + 4, self.frame.top - 30,
    self.frame.right - 4, self.frame.top - 4)
    self.mini = {}
    for i = 1, 3 do
        self.mini[i] = Frame(35 + (i - 1) * 180, 35,
        170 + (i - 1) * 180, 105)
    end
    self.sockets = {}
    socket = 0
    for x = 1,2 do 
        for y = 15,1,-1 do
            socket = socket + 1
            self.sockets[socket] = 
            Socket(nil, x * 250 - 180, y * 45 + 71)
            self.sockets[socket + 30] = 
            Socket(nil, x * 250 - 180, y * 45 + 71)
            self.sockets[socket + 60] = 
            Socket(nil, x * 250 - 180, y * 45 + 71)
        end
    end
    self.selectedSocket = 0
    self.action = 0
    self.tokens = {}
    self.pulse = 0
    self.board = 1
end

function CodeBench:loadRobot(r)
    local i, p
    for i = 1,90 do
        self.sockets[i].code = nil
    end
    for i, p in ipairs(r.program) do
        self.sockets[i].code = p.code
        self.sockets[i].value = p.value
    end
end

function CodeBench:draw()
    local x, y
    pushStyle()
    fontSize(16)
    tint(27, 27, 27, 255)
    sprite(boardImg, self.frame.left, self.frame.bottom, 
        self.frame.right, self.frame.top)
        
    stroke(249, 249, 249, 255)
    noFill()
    strokeWidth(2)
    for i = 1,3 do
        sprite(boardImg, self.mini[i].left, self.mini[i].bottom, 
        self.mini[i].right, self.mini[i].top)
        self.mini[i]:draw()
    end
    
    self.frame:draw()
    fill(87, 87, 87, 221)
    noStroke()
    tint(172, 195, 221, 255)
    sprite(chipImg, self.header.left, self.header.bottom, 
        self.header.right, self.header.top)
        
    --self.header:draw()
    pushMatrix()
    translate(self.x, self.y)
    -- trace lines
    fill(255, 210, 0, 219)
    stroke(127, 127, 127, 255)
    strokeWidth(5)
    line(40, 96, 230, 96)
    line(230, 96, 230, 760)
    line(230, 760, 320, 760)
    line(290, 96, 290, 70)
    line(290, 70, 20, 70)
    line(20, 70, 20, 760)
    line(20, 760, 40, 760)
    
    
    strokeWidth(1)
    stroke(185, 185, 185, 255)
    fill(189, 189, 189, 255)
    line(0, self.frame:height() + 15, self.frame:width()/2 - 10,
     self.frame:height() + 15)
    line(self.frame:width()/2 + 70, self.frame:height() + 15, 
    self.frame:width(), self.frame:height() + 15)
    line(0, self.frame:height() + 10, 0, self.frame:height() + 20)
    line(self.frame:width(), self.frame:height() + 10, 
    self.frame:width(), self.frame:height() + 20)
    text("3.54 cm", self.frame:width()/2, self.frame:height() + 5)
    line(-15, 0, -15, self.frame:height() / 2 - 10)
    line(-15, self.frame:height(), -15, self.frame:height() / 2 + 70)
    line(-20, self.frame:height(), -10, self.frame:height())
    line(-20, 0, -10, 0)
    
    rotate(90)
    text("7.80 cm", self.frame:height() / 2 , 5)
    rotate(-90)
    fontSize(12)
    if self.board == 1 then
        text("Use only GR-32 chips", 10, 10)
        text("RMS9000", 400 , 10)
        text("24V 17.5A   REV.B", 200 , 10)
        text("X1", 200 , 200)
    elseif self.board == 2 then
        text("Must be used with RMS9000 Mainboard", 10, 10)
        text("RDB9000-A", 400 , 10)
        fill(25, 27, 46, 255)
        strokeWidth(3)
        rect(470,50,500,90)
        noStroke()
        rect(490,53,505,87)
    elseif self.board == 3 then
        text("Must be used with RMS9000 Mainboard", 10, 10)
        text("RDB9000-B", 400 , 10)
        fill(25, 27, 46, 255)
        strokeWidth(3)
        ellipse(485,40,10)
        ellipse(485,100,10)
        rect(470,50,500,90)
        noStroke()
        rect(490,53,505,87)
        
    end
    socket = 1 + (self.board - 1) * 30
    for x = 1,2 do 
        for y = 15,1,-1 do
            noStroke()
            fill(175, 170, 189, 255)
            rect(x * 250 - 210, y * 45 + 70, 
                 x * 250 - 30, y * 45 + 102)
                
            strokeWidth(2)
            stroke(82, 82, 82, 255)
            fill(30, 28, 26, 255)
            self.sockets[socket]:draw()
            
            noStroke()
            
            stroke(127, 127, 127, 255)
            strokeWidth(5)
            fill(89, 89, 31, 255)
            ellipse(x * 250 - 210, y * 45 + 86, 20)
            line(x * 250 - 210, y * 45 + 82, 
            x * 250 - 210, y * 45 + 50)
            if self.sockets[socket].code 
            ~= nil then
                stroke(250, 21, 13, 255)
                fill(75, 75, self.pulse, 255)
                ellipse(x * 250 - 210, y * 45 + 86, 10)
            end
            fill(0, 0, 0, 255)
            text(socket - (self.board - 1) * 30,
             x * 250 - 200, y * 45 + 78)
            socket = socket + 1
        end
    end
    fill(255, 255, 255, 255)
    
    fontSize(16)
    if self.board == 1 then
        text("MAIN BOARD", 10, self.frame:height() - 25)
    elseif self.board == 2 then
        text("DAUGHTERBOARD A", 10, self.frame:height() - 25)
    elseif self.board == 3 then
        text("DAUGHTERBOARD B", 10, self.frame:height() - 25)
    end
    popMatrix()
    strokeWidth(1)
    stroke(193, 193, 193, 255)
    line(self.mini[self.board].left - 20, self.mini[self.board].bottom,
    self.mini[self.board].left - 10, self.mini[self.board].bottom)
    line(self.mini[self.board].left - 15, self.mini[self.board].bottom,
    self.mini[self.board].left - 15, self.mini[self.board].top)
    line(self.mini[self.board].left - 20, self.mini[self.board].top,
    self.mini[self.board].left - 10, self.mini[self.board].top)
    
    line(self.mini[self.board].left, self.mini[self.board].top + 20,
    self.mini[self.board].left + 25, self.mini[self.board].top + 20)
    line(self.mini[self.board].right, self.mini[self.board].top + 20,
    self.mini[self.board].right - 25, self.mini[self.board].top + 20)
    line(self.mini[self.board].left, self.mini[self.board].top + 25,
    self.mini[self.board].left, self.mini[self.board].top + 15)
    line(self.mini[self.board].right, self.mini[self.board].top + 25,
    self.mini[self.board].right, self.mini[self.board].top + 15)
    fill(171, 171, 171, 255)
    text("Selected", self.mini[self.board].left + 30, 
    self.mini[self.board].top + 12)
    popStyle()
    text("Main", self.mini[1].left + 10, self.mini[1]:height())
    text("A", self.mini[2].left + 10, self.mini[2]:height())
    text("B", self.mini[3].left + 10, self.mini[3]:height())
    self.pulse = self.pulse + 5
    if self.pulse > 255 then self.pulse = 1 end
end

function CodeBench:touched(touch)
    local i, t, first, last
    t =Ttouch(touch)
    t:translate(self.x, self.y - 10)
    self.action = 0
    first = 1 + (self.board - 1) * 30
    last = first + 29
    for i = first, last do
        if self.sockets[i]:touched(t) then
            self.selectedSocket = i
            if self.sockets[i].code ~= nil then
                if t.x < self.sockets[i].frame:midX() or
                self.sockets[i].code.hasValue == false then
                    self.action = 1
                end
            end
            return true
        end
    end
    return false
end
