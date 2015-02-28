# ABSTRACT

**loveCodea** is a pure Lua wrapper to run
[Codea](http://twolivesleft.com/Codea/)
scripts with LÖVE on the desktop. It is a vastly improved version of
[**LoveCodify**](https://github.com/SiENcE/lovecodify).
It's not a perfect emulation, but it's enough to run for example Codea's
Cargo-Bot "example", if you dare calling it like this.

# COMPATIBILITIES

### LÖVE

You need [**LÖVE 0.9.2**](http://www.love2d.org), earlier versions are not supported.

### Operating Systems

Generally, all operating systems that are supported by LÖVE should work.

- Linux
- MacOS X
- Windows

### Codea APIs

Supported:

- Most of the 2D API
- A bit of the physics API
- Parameters
- Persistence
- Single touches
- Keyboard (albeit invisible)
- Pre-defined sounds
- Simple http.request (no images)

Not supported (very incomplete list):

- Triangle meshes with textures
- 3D API
- Codea's buttons in the lower left corner

# PROJECT STRUCTURE

### Existing structure

- `loveCodea` contains all wrapper scripts.
- `tools` contains some helper scripts to ease the setup
  especially for complex Codea projects.
- `sounds` contains sound files for Codea's predefined sounds.
- `tests` contains some boring tests. Their main purpose is
  to test a specific functionality side-by-side on the iPad and the
  desktop.
- `demos` contains some of my own small projects.
- `forum` contains code found in the Codea forum

### What you should add yourself

From the Codea Runtime or the Codea app copy the `SpritePacks` folder into
the root folder of loveCodea and keep its name, the helper script can
access this folder using the -s or -all option.

Also copy the `Examples` folder from the Codea app. Examples are always a
good idea.

To extract files from the app locate it within iTunes, then use
"Show in Finder" to get to the location of the app in a Finder window.
Make a copy of the .ipa file and rename it to a zip file in order to unzip
it easily.

### The stage

The stage is a folder (usually with that name) that will be created to bring
the Codea project and loveCodea together.

# USAGE

### Developer's workflow

To avoid file system clutter I developed the following workflow and automated
it with a Tcl script. You're advised to use the script as well, but I will
explain the manual steps later.

Example for the Bezier demo:

    $ tclsh tools/stage.tcl demos/Bezier
    $ love stage

For Cargo-Bot:

    $ tclsh tools/stage.tcl Examples/Cargo-Bot.codea -p -all
    $ love stage

Notes: -p scans the Info.plist and -all copies all available
sprite packs into the stage (which is not necessary, just for simplicity).
If -p is omitted the script will scan all files for class usage and try to
get the hierarchy correct by itself.

Run the script with `--help` for all options.

### Doing it manually

- Create an empty folder `stage`
- Copy the `loveCodea folder into the stage
- Copy your project folder into the stage; remove the `.codea`
  extension if it has one
- Create a `main.lua` file in the stage to load all necessary files

This is an example `main.lua` file for the Bezier demo at the time of writing:

    -- Load loveCodea
    require("loveCodea/Base")
    require("loveCodea/Class")
    require("loveCodea/ClassWithProperties")
    require("loveCodea/Draw")
    require("loveCodea/Image")
    require("loveCodea/Matrix")
    require("loveCodea/Mesh")
    require("loveCodea/Noise")
    require("loveCodea/Parameter")
    require("loveCodea/Persistence")
    require("loveCodea/Physics")
    require("loveCodea/Sprite")
    require("loveCodea/Text")
    require("loveCodea/Vector")
    require("loveCodea/Z")
    require("loveCodea/tween")
    -- Load Bezier
    require("Bezier/main")

**Special Linux note:** The main file in the stage must be named "main.lua",
in lower case, not "Main.lua".

### Other possibilities

Use `tools/gen.tcl` to generate a single file `loveCodea.lua`. You can copy
this file into your project folder and add this at the top of `main.lua`:

    if require ~= nil then
        require("loveCodea")
        require(" ... extra Lua files ... ")
        require(" ... of your project ... ")
    end

The test for "require" allows you to use the file in Codea without
modifations, as "require" is not defined there.

Copy spritepacks and sounds as needed.

### Controls

- ctrl+8 Make screen smaller
- ctrl+9 Make screen larger
- ctrl+0 Reset screen size
- Arrow keys for gravity (try `Examples/Cloth Simulation`)

# Extras

### minifileserver and the iPad

The tool `minifileserver.tcl` acts as a very simple file server.
You can browse your folders with a web browser and get the contents of the
files on your desktop. A special feature for Codea is the file
`all_lua_files.lua` that is available when Lua files are found in the folder.
You'll get all Lua files in the folder packed into one file.

Start the server like this:

    $ tclsh tools/minifileserver.tcl

Or if you want to serve a very specific folder, set it as root:

    $ tclsh tools/minifileserver.tcl -r demos/Bezier

Now, instead of browsing the folders on the desktop with the iPad, you can
immediately load and execute files.
The following code is a slight modification on tnlogy's code from
[here](https://github.com/tnlogy/codea-samples/tree/master/Remote%20Code):

    -- Remote Code by tnlogy
    local url = "http://10.0.1.2:8000/all_lua_files.lua"
    function updateRemoteCode()
        print("downloading code")
        lastUpdate = false
        http.request(url, function (code)
            lastUpdate = ElapsedTime
            if currentCode and currentCode == code then return end
            print("updating code")
            currentCode = code;
            code = code:gsub("function setup", "function remoteSetup")
            code = code:gsub("function draw", "function remoteDraw")
            print(code)
            assert(loadstring(code))()
            remoteSetup()
        end)
    end

    -- Use this function to perform your initial setup
    function setup()
        updateRemoteCode()
    end

    function draw()
        if remoteDraw then remoteDraw() end
        if lastUpdate and ElapsedTime - lastUpdate > 2 then
            updateRemoteCode()
        end
    end

Adjust the IP address and let the minifileserver point to some project folder.
Copy the code above into a new Codea project and run it. It will load the
real code from the file server.

# OTHER INFORMATION

**Tcl:**
My scripting language of choice. On Linux and MacOS you'll have a
pre-installed tclsh (or can get one using the package manager).
On Windows it is enough to get a tclkitsh and place it somewhere in your
PATH or the loveCodea main directory, no need to install anything.
Visit [Google Code](http://code.google.com/p/tclkit/), the featured downloads
should guide you well.
[This](http://code.google.com/p/tclkit/downloads/detail?name=tclkitsh-8.5.9-win32.upx.exe)
is at the time of writing all you need.
The command to run Tcl is then of course `tclkitsh` and not `tclsh`.

# THANKS

Thanks to Florian "SiENcE" for the great initial LoveCodify.

Thanks to JockM, tnlogy and other members of the Codea forum for
contributions, ideas and bug reports.
