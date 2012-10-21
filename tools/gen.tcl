#!/usr/bin/env tclsh

set PROGRAM_NAME [file tail [info script]]

proc Usage {{exitcode 1}} {
    puts "Usage: $::PROGRAM_NAME <folder> \[options\]

Concatenates all loveCodea files into one loveCodea.lua file.

    -v           Verbose"
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
    verbose     false
}

proc parseOptions {} {
    global argc
    global argv
    global O
    for {set argidx 0} {$argidx < $argc} {incr argidx} {
        set opt [lindex $argv $argidx]
        if {[string index $opt 0] eq "-"} {
            switch -- $opt {
                "-v"       { set O(verbose) true }
                default {
                    puts "Unknown option $opt"
                    Usage
                }
            }
        } else {
            Usage
        }
    }
}
parseOptions

# # ## ### ##### ######## ############# #####################
#
# Main
#
# # ## ### ##### ######## ############# #####################

set srcfolder "loveCodea"
set modules [lsort [glob -dir $srcfolder -tails *.lua]]
puts "Creating file loveCodea.lua"
set out [open loveCodea.lua w]
puts $out "-- Created: [clock format [clock sec] -format %Y-%m-%d]"
set totallinecount 0
foreach module $modules {
    puts $out ""
    puts $out "--"
    puts $out "-- Inlined module: $module"
    puts $out "--"
    puts $out ""
    set m [open $srcfolder/$module r]
    set contents [read $m]
    puts -nonewline $out $contents
    close $m
    set linecount [llength [split $contents "\n"]]
    if {$O(verbose)} {
        puts [format "%-40s | %4d lines" $module $linecount]
    }
    incr totallinecount $linecount
}
close $out

if {$O(verbose)} {
    puts [string repeat "-" 53]
    puts [format "%-40s | %4d lines" "Total source line count:" $totallinecount]
}

puts "Done"
