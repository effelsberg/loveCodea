#!/usr/bin/env tclsh

# minifileserver
# Especially for use with loveCodea.
# 2012 Stephan Effelsberg
# License: Public Domain

set PROGRAM_NAME [file tail [info script]]

proc Usage {{exitcode 1}} {
    puts "Usage: $::PROGRAM_NAME \[options\]

A mini file server with special purpose Codea features.
You can point a web browser to it.
The special feature part is a meta file
    all_lua_files.lua
that is created on the fly in directories that contain lua files.
WARNING: This is not a secure server.

  -p <port>   Start server on port (default: 8000)
  -r <root>   Root directory (default: caller's directory)
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
    port        8000
    root        "."
    verbose     false
}

proc parseDashOption {opt arg} {
    global O
    set arg_used 0
    switch -- $opt {
        "-p"    { set O(port) $arg ; set arg_used 1 }
        "-r"    { set O(root) $arg ; set arg_used 1 }
        "-v"    { set O(verbose) true }
        default {
            puts "Unknown option $opt"
            Usage
        }
    }
    return $arg_used
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
            Usage
        }
    }
}
parseOptions

# # ## ### ##### ######## ############# #####################
#
# Server
#
# # ## ### ##### ######## ############# #####################

proc verbose {msg} {
    global O
    if {$O(verbose)} {
        puts $msg
    }
}

proc bgerror {err} {
    puts "bgerror: $err"
}

proc serve {chan otherhost otherport} {
    fileevent $chan readable [list respond $chan]
}

proc respond {chan} {
    global O
    set root $O(root)
    set cmd [gets $chan]
    set path [string trimleft [lindex $cmd 1] /]
    set path [regsub -all "%20" $path " "]
    set fullpath [file join $root $path]

    catch {
        if {[file tail $fullpath] eq "all_lua_files.lua"} {
            verbose "Serving lua collection in $fullpath"
            respond_luacollection $chan [file dir $fullpath]
        } elseif {[file isdir $fullpath]} {
            verbose "Serving directory listing $fullpath"
            respond_directory $chan $O(root) $path
        } elseif {[file isfile $fullpath]} {
            verbose "Serving file $fullpath"
            respond_file $chan $fullpath
        } else {
            verbose "File not found $fullpath"
            respond_notfound $chan $fullpath
        }
    } err
    close $chan
    if {$err ne ""} {
        error $err
    }
}

# Sends a list of files in the path.
# If path contains lua files, a special file all_lua_files.lua will be added
# but not created.
proc respond_directory {chan root path} {
    global O
    set files [glob -dir [file join $root $path] -nocomplain -- "*"]
    set files [lsort $files]
    puts $chan "HTTP/1.0 200 OK"
    puts $chan ""
    puts $chan "<html><body>"
    puts $chan "<h2>Directory listing for $path</h2><ul>"
    set has_luafiles false
    foreach f $files {
        set ft [file tail $f]
        if {[file isdir $f]} {
            puts $chan "<li><a href=\"$ft/\">$ft/</a>"
        } else {
            puts $chan "<li><a href=\"$ft\">$ft</a>"
            if {[file extension $f] eq ".lua"} {
                set has_luafiles true
            }
        }
    }
    if {$has_luafiles} {
        puts $chan "<li><a href=\"all_lua_files.lua\"><b>All Lua Files</b></a>"
    }
    puts $chan "</ul></body></html>"
}

# Sends the contents of a file. File may be binary.
proc respond_file {chan path} {
    set f [open $path "r"]
    fconfigure $f -translation binary
    fconfigure $chan -translation binary
    puts $chan "HTTP/1.0 200 OK"
    puts $chan ""
    puts -nonewline $chan [read $f]
    close $f
}

# Concatenates all lua files in path and sends them as one file.
proc respond_luacollection {chan path} {
    set files [lsort [glob -nocomplain -- "$path/*.lua"]]
    set cat "-- File collection:\n"
    foreach f $files {
        append cat "--   $f\n"
    }
    foreach f $files {
        verbose "  adding file $f"
        append cat "\n--# [file root [file tail $f]]\n"
        set ff [open $f "r"]
        append cat [read $ff]
        close $ff
    }
    puts $chan "HTTP/1.0 200 OK"
    puts $chan ""
    puts $chan $cat
}

# Sends a file not found response.
proc respond_notfound {chan path} {
    puts $chan "HTTP/1.0 404 Not Found"
    puts $chan ""
    puts $chan "<html><body>"
    puts $chan "File not found: $path"
    puts $chan "<body></html>"
}

# # ## ### ##### ######## ############# #####################
#
# Main
#
# # ## ### ##### ######## ############# #####################

proc my_ipaddress {} {
    set srv [socket -server none -myaddr [info hostname] 0]
    set myip [lindex [fconfigure $srv -sockname] 0]
    close $srv
    return $myip
}

socket -server serve $O(port)
puts "Serving on [my_ipaddress]:$O(port)"
vwait forever
