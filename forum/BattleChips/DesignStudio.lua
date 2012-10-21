DesignStudio = class()

function DesignStudio:init(l, b, r, t)
    -- boundary
    self.frame = Frame(l, b, r, t)
    
    -- textbox for name
    self.tb = TextBox(self.frame:midX() - 160, b + 30, 200, "")
    
    -- color selector & frame
    self.colorFrame = Frame(150, 600, 260, 624)
    self.showColorSlider = false
    self.colorVCS = VColorSlider(self.colorFrame.left, 
    self.colorFrame.top)
    
    -- side tabs
    self.dishBtn = OpenBtn("Dish", self.frame.left, 
    self.frame.top - 80)
    self.headBtn = OpenBtn("Head", self.frame.left, 
    self.frame.top - 115)
    self.bodyBtn = OpenBtn("Body", self.frame.left, 
    self.frame.top - 150)
    self.treadBtn = OpenBtn("Treads", self.frame.left, 
    self.frame.top - 185)
    self.dishBtn.selected = true
    
    -- catalog area
    self.catalogFrame = Frame(120, 500, 750, 955)
    
    -- selected item
    self.selectRect = {}
    self.selectRect[1] = Frame(120, 650, 320, 955 )
    self.selectRect[2] = Frame(320, 650, 520, 955 )
    self.selectRect[3] = Frame(520, 650, 720, 955 )
    self.page = 1
end

function DesignStudio:drawDishes()
    local x, y

    x = self.selectRect[1]:midX()
    y = self.selectRect[1]:midY() + 50
    stroke(colors[self.bot.dishColor])
    
    line(x - 5, y, x, y + 20)
    line(x + 5, y, x, y + 20)
    line(x - 30, y + 10, x - 20, y + 5)
    line(x - 20, y + 5, x, y)
    line(x + 30, y + 10, x + 20, y + 5)
    line(x + 20, y + 5, x, y)
    line(x, y + 20, x, y + 30)
    ellipse(x, y + 20, 5)
    fill(255, 255, 255, 255)
    
    text("Laserator X-49", x, y + 50)
    text("20m", x, y - 70)
    text("100kw", x, y - 90)
    text("10cycles", x, y - 110)
    
    noFill()
    x = self.selectRect[2]:midX()
    y = self.selectRect[2]:midY() + 50
    rect(x - 5, y, x + 5, y + 25)
    line(x - 20, y, x, y)
    line(x + 20, y, x, y)
    line(x - 30, y + 15, x, y)
    line(x + 30, y + 15, x, y)
    fill(255, 255, 255, 255)
    text("Thumperator Max", x, y + 50)
    text("7m", x, y - 70)
    text("250kw", x, y - 90)
    text("15cycles", x, y - 110)
    
    noFill()
    x = self.selectRect[3]:midX()
    y = self.selectRect[3]:midY() + 50
    line(x - 20, y, x + 20, y)
    line(x - 15, y + 5, x + 15, y + 5)
    line(x - 10, y + 10, x + 10, y + 10)
    line(x - 5, y + 15, x + 5, y + 15)
    line(x, y, x, y + 30)
    ellipse(x, y + 35, 10)
    fill(255, 255, 255, 255)
    text("Zapmaster 1000", x, y + 50)
    text("3m", x, y - 70)
    text("500kw", x, y - 90)
    text("15cycles", x, y - 110)
    fill(colors[self.bot.dishColor])
    self.colorFrame:draw()
    
    textMode(CORNER)
    fill(255, 255, 255, 255)
    text("Dish units include both radar and weaponry.", 300, 625)
    text("Some units have a long range, but cause ", 300, 600)
    text("light damage. Others deliver a harder blow ", 300, 575)
    text("but can only do so at short range.", 300, 550)
    
    stroke(201, 201, 201, 255)
    x = self.selectRect[self.bot.dish].left + 20
    y = self.selectRect[self.bot.dish].bottom + 85
    line(x, y, x, y + 175)
    line(x - 5, y, x + 5, y)
    line(x - 5, y + 175, x + 5, y + 175)
    line(x + 10, y - 20, x + 40, y - 20)
    line(x + 125, y - 20, x + 160, y - 20)
    line(x + 10, y - 25, x + 10, y - 15)
    line(x + 160, y - 25, x + 160, y - 15)
    fill(209, 209, 209, 255)
    text("Selected", x + 45, y - 30)
end

function DesignStudio:drawHeads()
    local x, y
    
    x = self.selectRect[1]:midX()
    y = self.selectRect[1]:midY() + 50
    stroke(colors[self.bot.headColor])
    ellipse(x, y, 30)
    rect(x - 15, y - 5, x - 13, y + 5)
    rect(x + 15, y - 5, x + 13, y + 5)
    line(x - 15, y, x - 20, y)
    line(x + 15, y, x + 20, y)
    fill(255, 255, 255, 255)
    text("Cool Bean", x, y + 50)
    text("10hds", x, y - 70)
    text("0.0 shield", x, y - 90)
    noFill()
    x = self.selectRect[2]:midX()
    y = self.selectRect[2]:midY() + 50
    ellipse(x, y, 30)
    ellipse(x, y, 25)
    line(x+5,y+5,x-5,y-5)
    line(x+5,y-5,x-5,y+5)
    fill(255, 255, 255, 255)
    text("Bubble Boyo", x, y + 50)
    text("3hds", x, y - 70)
    text("3.5 shield", x, y - 90)
    
    noFill()
    x = self.selectRect[3]:midX()
    y = self.selectRect[3]:midY() + 50
    ellipse(x, y, 30)
    ellipse(x, y + 10, 25, 10)
    ellipse(x, y + 15, 15, 5)
    line(x - 15, y - 5, x - 25, y - 15)
    line(x + 15, y - 5, x + 25, y - 15)
    fill(255, 255, 255, 255)
    text("Headvantage", x, y + 50)
    text("1hds", x, y - 70)
    text("5.5 shield", x, y - 90)
    
    textMode(CORNER)
    fill(255, 255, 255, 255)
    text("Head units both generate shields and help to ", 300, 625)
    text("automatically repair bots when damaged. Those ", 300, 600)
    text("units that provide the best shields are slow", 300, 575)
    text("at repairs, while the best repair units have", 300, 550)
    text("weak shields.", 300, 525)
    fill(colors[self.bot.headColor])
    self.colorFrame:draw()
    
    stroke(201, 201, 201, 255)
    x = self.selectRect[self.bot.head].left + 20
    y = self.selectRect[self.bot.head].bottom + 85
    line(x, y, x, y + 175)
    line(x - 5, y, x + 5, y)
    line(x - 5, y + 175, x + 5, y + 175)
    line(x + 10, y - 20, x + 40, y - 20)
    line(x + 125, y - 20, x + 160, y - 20)
    line(x + 10, y - 25, x + 10, y - 15)
    line(x + 160, y - 25, x + 160, y - 15)
    fill(209, 209, 209, 255)
    text("Selected", x + 45, y - 30)
end

function DesignStudio:drawTreads()
    local i, x, y
    
    x = self.selectRect[1]:midX()
    y = self.selectRect[1]:midY() + 50
    stroke(colors[self.bot.treadColor])
    ellipse(x + 20,y -20, 20)
    ellipse(x + 20, y -20, 20, 5)
    ellipse(x-20, y-20, 20)
    ellipse(x-20, y-20, 20, 5)
    ellipse(x-20, y+20, 20)
    ellipse(x-20, y+20, 20, 5)
    ellipse(x+20, y+20, 20)
    ellipse(x+20, y+20, 20, 5)
    line(x-20, y-11, x, y)
    line(x-17, y-14, x, y)
    line(x+20, y-11, x, y)
    line(x+17, y-14, x, y)
    line(x-20, y+11, x, y)
    line(x-17, y+14, x, y)
    line(x+20, y+11, x, y)
    line(x+17, y+14, x, y)
    fill(255, 255, 255, 255)
    text("Spinomatic", x, y + 50)
    text("90dpc", x, y - 70)
    text("10kph", x, y - 90)
    noFill()
    
    x = self.selectRect[2]:midX()
    y = self.selectRect[2]:midY() + 50
    rect(x - 15, y - 2, x + 15, y + 2)
    ellipse(x, y - 4, 15)
    line(x - 15, y - 10, x + 15, y - 10)
    rect(x - 30, y - 30, x - 15, y + 30)
    rect(x + 15, y - 30, x + 30, y + 30)
    
    for i = 0,7 do
        line(x + 15, y - 30 + i * 8, x + 30, y - 30 + i * 8)
        line(x - 30, y - 30 + i * 8, x - 15, y - 30 + i * 8)
    end
    
    fill(255, 255, 255, 255)
    text("Tanktrak T11", x, y + 50)
    text("45dpc", x, y - 70)
    text("25kph", x, y - 90)
    
    noFill()
    x = self.selectRect[3]:midX()
    y = self.selectRect[3]:midY() + 50
    rect(x - 30, y + 10, x - 20, y + 30)
    rect(x + 20, y + 10, x + 30, y + 30)
    rect(x - 30, y - 30, x - 20, y - 10)
    rect(x + 20, y - 30, x + 30, y - 10)
    ellipse(x - 25, y + 20, 15, 25)
    ellipse(x - 25, y - 20, 15, 25)
    ellipse(x + 25, y + 20, 15, 25)
    ellipse(x + 25, y - 20, 15, 25)
    rect(x - 20, y - 22, x + 20, y - 16)
    rect(x - 20, y + 22, x + 20, y + 16)
    
    fill(255, 255, 255, 255)
    text("Hard Wheelz", x, y + 50)
    text("15dpc", x, y - 70)
    text("50kph", x, y - 90)
    
    textMode(CORNER)
    fill(255, 255, 255, 255)
    text("Treads provide the means for bots to move ", 300, 625)
    text("around the arena. Some units are capable of ", 300, 600)
    text("turning rapidly, but are slow getting from ", 300, 575)
    text("A to B. Other systems sacrifice agility for", 300, 550)
    text("raw speed.", 300, 525)
    fill(colors[self.bot.treadColor])
    self.colorFrame:draw()
    
    stroke(201, 201, 201, 255)
    x = self.selectRect[self.bot.tread].left + 20
    y = self.selectRect[self.bot.tread].bottom + 85
    line(x, y, x, y + 175)
    line(x - 5, y, x + 5, y)
    line(x - 5, y + 175, x + 5, y + 175)
    line(x + 10, y - 20, x + 40, y - 20)
    line(x + 125, y - 20, x + 160, y - 20)
    line(x + 10, y - 25, x + 10, y - 15)
    line(x + 160, y - 25, x + 160, y - 15)
    fill(209, 209, 209, 255)
    text("Selected", x + 45, y - 30)
end


function DesignStudio:drawBodies()
    local x, y
    
    x = self.selectRect[1]:midX()
    y = self.selectRect[1]:midY() + 50
    stroke(colors[self.bot.bodyColor])
    ellipse(x - 20, y, 15, 15)
    ellipse(x + 20, y, 15, 15)
    fill(25, 27, 46, 255)
    ellipse(x, y, 40, 20)
    fill(255, 255, 255, 255)
    text("LightWay C", x, y + 50)
    text("10mm", x, y - 70)
    text("47kg", x, y - 90)
    
    fill(25, 27, 46, 255)
    x = self.selectRect[2]:midX()
    y = self.selectRect[2]:midY() + 50
    rect(x - 25, y - 10, x + 25, y + 10)
    ellipse(x - 25, y, 20)
    ellipse(x + 25, y, 20)
    rect(x - 15, y - 15, x + 15, y - 10)
    
    
    fill(255, 255, 255, 255)
    text("Steel Trunk", x, y + 50)
    text("20mm", x, y - 70)
    text("90kg", x, y - 90)
    
    fill(25, 27, 46, 255)
    x = self.selectRect[3]:midX()
    y = self.selectRect[3]:midY() + 50
    ellipse(x - 20, y, 30, 30)
    ellipse(x + 20, y, 30, 30)
    rect(x - 20, y - 15, x + 20, y + 15)
    ellipse(x, y, 40, 30)
    
    fill(255, 255, 255, 255)
    text("ToughBugger II", x, y + 50)
    text("50mm", x, y - 70)
    text("250kg", x, y - 90)
    
    textMode(CORNER)
    fill(255, 255, 255, 255)
    text("Body units protect the bot from damage and  ", 300, 625)
    text("allow it to absorb more blows before failing. ", 300, 600)
    text("However, as armor increases in weight, it ", 300, 575)
    text("reduces both the speed of movement and of", 300, 550)
    text("turning.", 300, 525)
    fill(colors[self.bot.bodyColor])
    self.colorFrame:draw()
    
    stroke(201, 201, 201, 255)
    x = self.selectRect[self.bot.body].left + 20
    y = self.selectRect[self.bot.body].bottom + 85
    line(x, y, x, y + 175)
    line(x - 5, y, x + 5, y)
    line(x - 5, y + 175, x + 5, y + 175)
    line(x + 10, y - 20, x + 40, y - 20)
    line(x + 125, y - 20, x + 160, y - 20)
    line(x + 10, y - 25, x + 10, y - 15)
    line(x + 160, y - 25, x + 160, y - 15)
    fill(201, 201, 201, 255)
    text("Selected", x + 45, y - 30)
end

function DesignStudio:setBot(bot)
    self.bot = bot
    self.tb.text = self.bot.name
end

function DesignStudio:draw()
    pushMatrix()
    fontSize(18)
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(2)
    stroke(0, 38, 255, 255)
    strokeWidth(2)
    fill(185, 185, 185, 113)
    self.tb:draw()
    fill(255, 255, 255, 255)
    text("Color", self.colorFrame.left, self.colorFrame.top)
    fontSize(24)
    text("Design Studio", self.frame.left + 120, self.frame.top - 35)
    
    fill(colors[self.bot.dishColor])
    self.colorFrame:draw()
    
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(2)
    self.catalogFrame:draw()
    rect(self.catalogFrame.left, self.catalogFrame.top,
    self.catalogFrame.right, self.catalogFrame.top + 50)
    rect(self.catalogFrame.left, self.catalogFrame.bottom - 90,
    self.catalogFrame.right, self.catalogFrame.bottom)
    
    if self.dishShowSlider then self.dishVCS:draw() end
    if self.headShowSlider then self.headVCS:draw() end
    if self.bodyShowSlider then self.bodyVCS:draw() end
    if self.treadShowSlider then self.treadVCS:draw() end
    
    translate(self.frame:midX()+ 90 , self.frame:height() - 170)
    
    self.bot.x = 0
    self.bot.y = 0
    self.bot:draw(1)
    
    popMatrix()
    self.headBtn:draw()
    self.dishBtn:draw()
    self.bodyBtn:draw()
    self.treadBtn:draw()
    fontSize(16)
    textMode(CENTER)
    strokeWidth(1.1)
    if self.page == 1 then
        self:drawDishes()
    end
    if self.page == 2 then
        self:drawHeads()
    end
    if self.page == 3 then
        self:drawBodies()
    end
    if self.page == 4 then
        self:drawTreads()
    end
    if self.showColorSlider then
        self.colorVCS:draw()
    end
end

function DesignStudio:clearSelected()
    self.dishBtn.selected = false
    self.headBtn.selected = false
    self.bodyBtn.selected = false
    self.treadBtn.selected = false
end
    
function DesignStudio:touched(touch)
    local i
    self.bot.name = self.tb.text
    if self.colorFrame:touched(touch) then
        self.showColorSlider = true
    end
    if self.showColorSlider then
        if self.colorVCS:touched(touch) then
            if self.page == 1 then 
                self.bot.dishColor = self.colorVCS.selected
            end
            if self.page == 2 then 
                self.bot.headColor = self.colorVCS.selected
            end
            if self.page == 3 then 
                self.bot.bodyColor = self.colorVCS.selected
            end
            if self.page == 4 then 
                self.bot.treadColor = self.colorVCS.selected
            end
        end
    end
    if self.dishBtn:touched(touch) then
        self.page = 1
        self:clearSelected()
        self.dishBtn.selected = true
    end
    if self.headBtn:touched(touch) then
        self.page = 2
        self:clearSelected()
        self.headBtn.selected = true
    end
    if self.bodyBtn:touched(touch) then
        self.page = 3
        self:clearSelected()
        self.bodyBtn.selected = true
    end
    if self.treadBtn:touched(touch) then
        self.page = 4
        self:clearSelected()
        self.treadBtn.selected = true
    end
    for i = 1,3 do
        if self.selectRect[i]:touched(touch) then
            sound(SOUND_SHOOT, 46433)
            if self.page == 1 then self.bot.dish = i end
            if self.page == 2 then self.bot.head = i end
            if self.page == 3 then self.bot.body = i end
            if self.page == 4 then self.bot.tread = i end
        end
    end
end
