    colors = {}
    colors[1] = color(255, 25, 0, 255)
    colors[2] = color(223, 143, 145, 255)
    colors[3] = color(255, 127, 0, 255)
    colors[4] = color(223, 183, 152, 255) 
    colors[5] = color(255, 235, 0, 255)
    colors[6] = color(223, 219, 168, 255)
    colors[7] = color(96, 255, 0, 255)
    colors[8] = color(0, 255, 10, 255)
    colors[9] = color(130, 225, 121, 255)
    colors[10] = color(0, 255, 220, 255)
    colors[11] = color(152, 223, 216, 255)
    colors[12] = color(0, 74, 255, 255)
    colors[13] = color(129, 121, 225, 255)
    colors[14] = color(223, 157, 220, 255)
    colors[15] = color(188, 0, 255, 255)
    colors[16] = color(255, 255, 255, 255)
    
    tourney = Tourney()
    
    backClr = color(25, 27, 46, 255)

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function blurImage(img)
    local x, y, count, r, g, b, a, ir, ig, ib, ia
    timg = img:copy()
    for x = 1, img.width do
        for y = 1, img.height do
            r = 0
            g = 0
            b = 0
            a = 0
            if x > 1 then
                ir, ig, ib, ia = img:get(x - 1, y)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if x > 1 and y > 1 then
                ir, ig, ib, ia = img:get(x - 1, y - 1)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if y > 1 then
                ir, ig, ib, ia = img:get(x, y - 1)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if x < img.width and y > 1 then
                ir, ig, ib, ia = img:get(x + 1, y - 1)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if x < img.width then
                ir, ig, ib, ia = img:get(x + 1, y)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if x < img.width and y < img.height then
                ir, ig, ib, ia = img:get(x + 1, y + 1)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if y < img.height then
                ir, ig, ib, ia = img:get(x, y + 1)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            if x > 1 and y < img.height then
                ir, ig, ib, ia = img:get(x - 1, y + 1)
                r = r + ir
                g = g + ig
                b = b + ib
                a = a + ia
            end
            ir,ig,ib,ia = img:get(x,y)
            r = (r + ir) / 9
            g = (g + ig) / 9
            b = (b + ib) / 9
            a = (a + ia) / 9
            c = color(r,g,b,a)
            --print(r,g,b,a)
            timg:set(x,y,c)
        end
    end
    print(r,g,b,a)
    displayMode(STANDARD)
    return timg
end


function getDefault()
    local s
    s = "20,Lump,0,0,14,14,15,4,30,1,F,1,2,nil,1,3,L,1,4,nil,1,5,nil,1,6,nil,1,7,nil,1,8,nil,1,9,nil,1,10,nil,1,11,nil,1,12,nil,1,13,nil,1,14,nil,1,15,nil,1,16,nil,1,17,nil,1,18,nil,1,19,nil,1,20,nil,1,21,nil,1,22,nil,1,23,nil,1,24,nil,1,25,nil,1,26,nil,1,27,nil,1,28,nil,1,29,nil,1,30,nil,1,Turner,0,0,15,8,15,7,30,1,F,1,2,H,4,3,G,1,4,L,1,5,G,1,6,nil,1,7,nil,1,8,nil,1,9,nil,1,10,nil,1,11,nil,1,12,nil,1,13,nil,1,14,nil,1,15,nil,1,16,nil,1,17,nil,1,18,nil,1,19,nil,1,20,nil,1,21,nil,1,22,nil,1,23,nil,1,24,nil,1,25,nil,1,26,nil,1,27,nil,1,28,nil,1,29,nil,1,30,nil,1,Spinner,0,0,2,7,1,4,30,1,L,1,2,W,4,3,G,1,4,nil,1,5,nil,1,6,nil,1,7,nil,1,8,nil,1,9,nil,1,10,nil,1,11,nil,1,12,nil,1,13,nil,1,14,nil,1,15,nil,1,16,nil,1,17,nil,1,18,nil,1,19,nil,1,20,nil,1,21,nil,1,22,nil,1,23,nil,1,24,nil,1,25,nil,1,26,nil,1,27,nil,1,28,nil,1,29,nil,1,30,nil,1,Smart Spinner,0,0,1,7,1,13,30,1,L,1,2,A,4,3,G,1,4,W,1,5,G,2,6,nil,1,7,nil,1,8,nil,1,9,nil,1,10,nil,1,11,nil,1,12,nil,1,13,nil,1,14,nil,1,15,nil,1,16,nil,1,17,nil,1,18,nil,1,19,nil,1,20,nil,1,21,nil,1,22,nil,1,23,nil,1,24,nil,1,25,nil,1,26,nil,1,27,nil,1,28,nil,1,29,nil,1,30,nil,1,Killbot 1000,0,0,15,3,15,3,30,1,F,1,2,H,4,3,G,1,4,R,1,5,R,1,6,A,13,7,L,1,8,F,1,9,H,11,10,G,5,11,R,1,12,G,5,13,W,1,14,G,6,15,nil,1,16,nil,1,17,nil,1,18,nil,1,19,nil,1,20,nil,1,21,nil,1,22,nil,1,23,nil,1,24,nil,1,25,nil,1,26,nil,1,27,nil,1,28,nil,1,29,nil,1,30,nil,1,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0,Generobot,0,0,14,14,15,4,0"
    return s
end