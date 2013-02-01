--[[
Quick usage:

Copy this file (if it is the monolithic loveCodea.lua file) into the project folder.
Add this to the top of the main.lua file:
  if require ~= nil then
    require("loveCodea")
    require(" ... extra Lua files ... ")
    require(" ... of your project ... ")
  end
Notes for projects that use class inheritance (e.g Cargo-Bot):
The base classes must be included before the derived classes.

If the project needs sprites:
Copy the needed .spritepack folders into the project folder.
Run your project.

Hint for small screens:
Use ctrl+8 and ctrl+9 to decrease or increase the screen size.
Use ctrl+0 to revert to normal.
]]--

--[[
LoveCodea is an update of LoveCodify.
See https://github.com/SiENcE/lovecodify
2012 Stephan Effelsberg

Main topics of the update:
- Make the wrapper running with Love2D 0.8.0.
  Do not use it with versions < 0.8.0, they made incompatible changes.
- Make Asteroyds run. Like the original LoveCodify, work on LoveCodea wasn't
  started to get a full featured wrapper (I'd be glad if we get there, however)
  but with a specific target in mind.
  loveCodea now runs many of the examples and several other programs.
]]--

-- Original loveCodify header
--[[
LoveCodify is a Wrapper Class to run Codify/Codea Scripts with Love2D
Copyright (c) 2010 Florian^SiENcE^schattenkind.net

Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

You can use the http://love2d.org/ runtime to code Codify Apps on MacOSX/Linux/Windows.
Beware, it's unfinished, but samples are running.

Just include the this in your Codify project:
dofile ("loveCodify.lua")
]]--
