#!/usr/bin/env tclsh

set PROGRAM_NAME [file tail [info script]]

proc Usage {{exitcode 1}} {
    puts "Usage: $::PROGRAM_NAME <project folder> \[options\]

Prepares a stage folder that contains the project, the loveCodea wrapper
and supplemental data.
WARNING: Completely overwrites the stage directory.

  -p          Read file information from Info.plist instead of globbing
              all .lua files in folder
  -s <pack>   Copy spritepack or sound folder into stage (repeatable).
              Copies in fact any kind of file or folder into the project,
              but its intent is based on spritepacks and sounds.
  -all        Copy all known spritepacks and sounds into stage
  -stage <f>  Use other name for stage folder (default: stage)
  -loco  <f>  Get loveCodea from a different folder (default: loveCodea)
  -run        Call love to run the stage
  -runbg      Call love to run the stage (background process)
  -v          Verbose"
    exit $exitcode
}

if {"--help" in $argv} {
    Usage 0
}

# # ## ### ##### ######## ############# #####################
#
# Option parsing
#
# # ## ### ##### ######## ############# #####################

array set O {
    stage       stage
    loco        loveCodea
    folders     {}
    projorigin  ""
    use_plist   false
    spritepacks {}
    all         false
    run         false
    runbg       false
    verbose     false
}

proc parseDashOption {opt arg} {
    global O
    set arg_used 0
    switch -- $opt {
        "-p"     { set O(use_plist) true }
        "-s"     { lappend O(spritepacks) $arg ; set arg_used 1 }
        "-all"   { set O(all) true }
        "-run"   { set O(run) true }
        "-runbg" { set O(runbg) true }
        "-stage" { set O(stage) $arg ; set arg_used 1 }
        "-loco"  { set O(loco) $arg ; set arg_used 1 }
        "-v"     { set O(verbose) true }
        default  {
            puts "Unknown option $opt"
            Usage
        }
    }
    return $arg_used
}

proc parseFreeOption {opt} {
    global O
    lappend O(folders) $opt
}

proc parseOptions {} {
    global argc
    global argv
    global O
    for {set argidx 0} {$argidx < $argc} {incr argidx} {
        set opt [lindex $argv $argidx]
        if {[string index $opt 0] eq "-"} {
            set arg [lindex $argv $argidx+1]
            incr argidx [parseDashOption $opt $arg]
            if {$argidx >= $argc} Usage
        } else {
            parseFreeOption $opt
        }
    }
}
parseOptions

if {[llength $O(folders)] != 1} {
    puts "Need exactly one project folder"
    Usage
}
set O(projorigin) [lindex $O(folders) 0]

# # ## ### ##### ######## ############# #####################
#
# Helpers for the class hierarchy
#
# # ## ### ##### ######## ############# #####################

# Scans all files for class information and sorts file names so that base
# classes are included before derived ones.
proc sortFilenamesByClassHierarchy {folder filenames} {
    set hierarchy {}

    foreach filename $filenames {
        extractClasses $folder $filename hierarchy
    }
    set need_sorting true
    while {$need_sorting} {
        set unsorted_filenames $filenames
        foreach derived [dict keys $hierarchy] {
            set base [dict get $hierarchy $derived base]
            if {$base ne ""} {
                set filename_of_derived [dict get $hierarchy $derived file]
                set filename_of_base [dict get $hierarchy $base file]
                set filenames [moveItemInFrontOfItem $filename_of_base $filename_of_derived $filenames]
            }
        }
        set need_sorting [expr {$unsorted_filenames != $filenames}]
    }

    return $filenames
}

# Extracts class information from a file and inserts it into the hierarchy dict.
proc extractClasses {folder filename hierarchyName} {
    upvar $hierarchyName hierarchy

    set f [open [file join $folder $filename] "r"]
    set lines [read $f]
    close $f
    set lines [split $lines "\n"]
    foreach line $lines {
        if {[regexp {([^\s]*)\s*=\s*class\((.*)\)} $line m derived base]} {
            dict set hierarchy $derived base $base
            dict set hierarchy $derived file $filename
        }
    }
}

# Returns a list where |front_item| is in front of |next_item|.
proc moveItemInFrontOfItem {front_item next_item list} {
    set idx_of_front [lsearch $list $front_item]
    set idx_of_next [lsearch $list $next_item]
    if {$idx_of_front > $idx_of_next} {
        set list [lreplace $list $idx_of_front $idx_of_front]
        set list [linsert $list $idx_of_next $front_item]
    }
    return $list
}

# # ## ### ##### ######## ############# #####################
# # ## ### ##### ######## ############# #####################

# Removes trails of the old way of wrapping a project, specifically:
# Removes loveCodea.lua in the projectfolder.
# Removes "if require ... end" in main.lua.
proc removeOldLocoReferences {stage projectfolder} {
    set locopath [file join $stage $projectfolder loveCodea.lua]
    if {[file exists $locopath]} {
        puts "Removing old $locopath"
        file delete $locopath
    }

    set mainpath1 [file join $stage $projectfolder main.lua]
    set mainpath2 [file join $stage $projectfolder Main.lua]
    if {[file exists $mainpath1]} {
        set mainpath $mainpath1
    } else {
        set mainpath $mainpath2
    }
    set f [open $mainpath r]
    set maincontents [read $f]
    close $f
    if {[string first "if require" $maincontents] == 0} {
        puts "Main file contains old loveCodea loader ... removing"
        set end [string first "end" $maincontents]
        if {$end < 0} {
            puts "  No end found ... skipping"
        } else {
            puts "  Writing back $mainpath"
            set maincontents [string range $maincontents $end+3 end]
            set f [open $mainpath w]
            puts -nonewline $f $maincontents
            close $f
        }
    }
}

# Scans all project files for deprecated features and patches them.
# Writes file back in case of modification.
# Known deprecated features are varargs and the "\^" escape pattern.
proc hotpatchDeprecatedFeatures {stage projectfolder} {
    set filenames [glob -dir [file join $stage $projectfolder] -types {f} *]
    foreach filename $filenames {
        # Read the file
        set f [open $filename r]
        set contents [read $f]
        close $f
        # Add "local arg = {...}" to function defs that end with "...)"
        set mod1 [regsub -all -line {function .*\.\.\.\s*\)\s*} $contents "& local arg = {...}" contents]
        # Rename "arg.n" to "#arg"
        set mod2 [regsub -all {arg\.n} $contents "#arg" contents]
        # Replace escape sequence "\^" with "%^"
        set mod3 [regsub -all {\\\^} $contents "%^" contents]
        if {$mod1 || $mod2} {
            puts "[file tail $filename]: [expr {$mod1 + $mod2}]x hotpatch for arg applied"
        }
        if {$mod3} {
            puts "[file tail $filename]: ${mod3}x hotpatch for escape sequence applied"
        }
        # Write back if there was any modification
        if {$mod1 || $mod2 || $mod3} {
            set f [open $filename w]
            puts -nonewline $f $contents
            close $f
        }
    }
}

# Moves spritepacks from the project folder into the stage where loveCodea
# can find them. Useful for non-default spritepacks (Documents:...).
proc moveProjectSpritepacksToStage {stage projectfolder} {
    set spritepacks [glob -dir [file join $stage $projectfolder] -nocomplain *.spritepack]
    foreach s $spritepacks {
        puts "Moving project spritepack [file tail $s] to stage"
        file rename $s [file join $stage [file tail $s]]
    }
}

# Generates main.lua in the stage.
# Scans loveCodea and project folder to generate the necessary requires.
proc generateMain {stage projectfolder} {
    global O
    set lines {}

    set folder [file join $stage loveCodea]
    set filenames [glob -dir $folder -tails *.lua]
    lappend lines "-- Load loveCodea"
    foreach f $filenames {
        lappend lines "require(\"loveCodea/[file rootname $f]\")"
    }

    set folder [file join $stage $projectfolder]
    set filenames {}
    if {$O(use_plist)} {
        set filenames [collectFilenamesFromPlist $folder "Info.plist"]
    }
    if {$filenames == {}} {
        set filenames [glob -dir $folder -tails *.lua]
        set filenames [sortFilenamesByClassHierarchy $folder $filenames]
    }
    lappend lines "-- Load $projectfolder"
    foreach f $filenames {
        lappend lines "require(\"$projectfolder/[file rootname $f]\")"
    }

    set mainfile [file join $stage main.lua]
    set f [open $mainfile w]
    foreach line $lines {
        puts $f $line
    }
    close $f
}

# Generates a conf.lua file in the stage.
proc generateConf {stage projectfolder} {
    set projectname $projectfolder
    set f [open [file join $stage conf.lua] w]
    puts $f "function love.conf(t)"
    puts $f "    t.title         = \"$projectname\""
    puts $f "    t.identity      = \"$projectname\""
    puts $f "    t.version       = \"0.9.2\""
    puts $f "    t.window.width  = 1024"
    puts $f "    t.window.height = 768"
    puts $f "end"
    close $f
}

# Scans the entries in the "Buffer Order" sections of a plist file.
# Returns a list with the file names (including .lua extension to make it
# compatible to glob).
# Returns an empty list in case of an error.
proc collectFilenamesFromPlist {folder plist_filename} {
    set fullfn [file join $folder $plist_filename]
    if {![file isfile $fullfn]} {
        puts "Cannot find file Info.plist in $folder"
        return {}
    }
    set f [open $fullfn r]
    set contents [read $f]
    close $f

    set luafiles {}
    if {[regexp "Buffer Order.*?<array>(.*?)</array>" $contents m bufferstring]} {
        set m [regexp -inline -all "<string>(.*?)</string>" $bufferstring]
        foreach {match buffername} $m {
            lappend luafiles $buffername.lua
        }
    } else {
        puts "No entry \"Buffer Order\" found in $plist_filename"
        return {}
    }

    return $luafiles
}

# # ## ### ##### ######## ############# #####################
#
# Main
#
# # ## ### ##### ######## ############# #####################

# stageproject is essentially the projectname.
# Must not contain dots due to Lua "require".
set stageproject [file rootname [file tail $O(projorigin)]]

if {[file isdirectory $O(stage)]} {
    puts "Deleting $O(stage)"
    file delete -force $O(stage)
}
puts "Creating $O(stage)"
file mkdir $O(stage)

puts "Copying $O(projorigin) into $O(stage)/$stageproject"
file copy $O(projorigin) $O(stage)/$stageproject
removeOldLocoReferences $O(stage) $stageproject
hotpatchDeprecatedFeatures $O(stage) $stageproject
moveProjectSpritepacksToStage $O(stage) $stageproject

puts "Copying loveCodea into $O(stage)"
file copy $O(loco) $O(stage)/loveCodea

puts "Generating main.lua"
generateMain $O(stage) $stageproject

puts "Generating conf.lua"
generateConf $O(stage) $stageproject

if {$O(all)} {
    set folders [glob -nocomplain -dir SpritePacks *]
    foreach f $folders {
        file copy $f $O(stage)
    }
    if {[file isdirectory sounds]} {
        file copy sounds $O(stage)
    }
} else {
    foreach pack $O(spritepacks) {
        puts "Copying $pack into $O(stage)"
        file copy $pack $O(stage)
    }
}

if {$O(runbg)} {
    exec love $O(stage) &
} elseif {$O(run)} {
    exec love $O(stage)
}

puts "Done"
