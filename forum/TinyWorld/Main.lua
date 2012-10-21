-- Project: Tiny World
-- Author and (c): juaxix
-- Link: http://twolivesleft.com/Codea/Talk/discussion/996/tiny-world-space-source-code-ludum-dare-23/p1

-- Main
-- 20/4/2012 -- xixgames.com
-- Ludum Dare #23
-- Tiny World
-- in this magic tiny world people need others like you!

function setup()
    displayMode(FULLSCREEN)
    score      = 0
    level      = 1 -- start in level 1 , easy
    highscore  = readLocalData("highscore",0)
    tiny_world = World(4+(level*2)) -- start the tiny world with 6 persons
end

function draw()
    tiny_world:draw()
end

function touched(touch)
    tiny_world:touched(touch)
end