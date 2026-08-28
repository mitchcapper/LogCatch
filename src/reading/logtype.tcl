set LogTypes "none brief process tag time thread threadtime long time_eclipse studio keyword"
set LogType "none"
set LogLevels "G V D I W E A F"
set LogLevelsLong "Generic Verbose Debug Info Warning Error Assert Fatal"
set LogLevelsLongLower [string tolower $LogLevelsLong]
set LogLevel(selected) "Generic"
# leading lines to ignore when detecting the log type (IDE/debugger preamble etc)
set DetectSkipLines 0


# DetectSkipLines is user editable (Preferences), so never trust it blindly.
# scan forces plain decimal: expr would read a typed "010" as octal 8.
proc detectSkipLines {} {
    global DetectSkipLines
    if {![string is integer -strict "$DetectSkipLines"]
        || [scan "$DetectSkipLines" "%d" n] != 1 || $n < 0} {
        return 0
    }
    return $n
}

# "" and "detect" both mean "detect the type from the log itself"
proc isForcedLogType {} {
    global ForcedLogType
    return [expr {"$ForcedLogType" != "" && "$ForcedLogType" != "detect"}]
}

# check first lineMax lines
proc checkLogType {filename} {
    global LogType LogLevels ForcedLogType LogLevelsLong LogLevelsLongLower DetectSkipLines
    set LogType "none"
    if {[isForcedLogType]} {
        set LogType $ForcedLogType
        return
    }
    set skip [detectSkipLines]
    set skipNote ""
    if {$skip > 0} {
        set skipNote " (skipping the first $skip line(s))"
    }
    puts "checking logtype ... \"$filename\"$skipNote"
    # every match below breaks out of the loop, so on a hit these still hold the
    # deciding line
    set rawLine ""
    set lineNo 0      ;# physical line number of $rawLine
    set lcnt 0        ;# non-empty lines examined
    set rp [open "$filename" r]
    if {"$rp" != ""} {
        set ncnt 0        ;# none
        set bcnt 0        ;# brief
        set tagcnt 0      ;# tag
        set pcnt 0        ;# process
        set longcnt 0     ;# long 
        set timecnt 0     ;# time
        set timeecnt 0    ;# time eclipse cnt
        set threadcnt 0   ;# thread
        set threadtimecnt 0 ;# threadtime
        set studiocnt 0   ;# studio
        set minimax 2
        set linemax 20
        while {[gets $rp line] >= 0 && $lcnt <= $linemax} {
            incr lineNo
            if {$lineNo <= $skip} { continue }
            # puts $lcnt/{$line}
            set rawLine $line
            set line [string map {\" \\" \{ \\{ \} \\}} "$line"]
            if {"$line" != ""} {
                set second [string index $line 1]
                if {"$second" == " "} {
                    set first [string index $line 0]
                    if {"$first" == "\["} {
                        # long
                        incr longcnt
                        if {$longcnt == $minimax} {
                            set LogType long
                            break
                        }
                    }
                } elseif {"$second" == "("} {
                    # process/thread
                    set closer [string first ")" "$line"]
                    set colonspace [string first ": " "$line"]
                    if {$colonspace > -1 && $colonspace < $closer} {
                        # thread
                        incr threadcnt
                        if {$threadcnt == $minimax} {
                            set LogType thread
                            break
                        }
                    } else {
                        # process
                        incr pcnt
                        if {$pcnt == $minimax} {
                            set LogType process
                            break
                        }
                    }
                } elseif {"$second" == "/"} {
                    # brief/tag
                    set colonspace [string first ": " "$line"]
                    if {"$colonspace" >= 0} {
                        if {"[string index $line [expr $colonspace -1]]" == ")"} {
                            # brief
                            incr bcnt
                            if {$bcnt == $minimax} {
                                set LogType brief
                                break
                            }
                        } else {
                            # tag
                            incr tagcnt
                            if {$tagcnt == $minimax} {
                                set LogType tag
                                break
                            }
                        }
                    }

                } else {
                    #these first two might fail if the line is actually all lower case 
                    set testWord [string tolower [lindex $line 1]]
                    if {[lsearch $LogLevelsLongLower $testWord] >= 0} {
                        set LogType "2ndWord"
                        break
                    }
                    set testWord [string tolower [lindex $line 2]]
                    if {[lsearch $LogLevelsLongLower $testWord] >= 0} {
                        set LogType "3rdWord"
                        break
                    }

                    set colon_space [string range $line 18 19]
                    set slash20 [string index $line 20]
                    set slash21 [string index $line 21]
                    set if_level [lindex "$line" 4]
                    puts "LogLevels: $LogLevels , if_level: $if_level"
                    if {"$slash20" == "/"} {
                        # time
                        incr timecnt
                        if {$timecnt == $minimax} {
                            set LogType "time"
                            break
                        }
                    } elseif {"$colon_space" == ": " && [lsearch $LogLevels "$slash20"] >= 0} {
                        # time_eclipse
                        incr timeecnt
                        if {$timeecnt == $minimax} {
                            set LogType time_eclipse
                            break
                        }
                    } elseif {[string length "$if_level"] == 1 && [lsearch $LogLevels "$if_level"] >= 0} {
                        # threadtime
                        # puts "LogLevels: \"$LogLevels\" if_level: \"$if_level\""
                        incr threadtimecnt
                        if {$threadtimecnt == $minimax} {
                            set LogType threadtime
                            break
                        }
                    } elseif {"[string index [lindex $line 3] 1]" == "/"} {
                        # studio
                        incr studiocnt
                        if {$studiocnt == $minimax} {
                            set LogType studio
                            break
                        }
                    }
                }
                incr lcnt
            }
        }
        close $rp
    }
    if {"$LogType" == "none"} {
        puts "logtype maybe $LogType (no match in $lcnt non-empty lines after the skip of $skip)"
    } else {
        puts "logtype maybe $LogType (matched on line $lineNo: \"$rawLine\")"
    }
}

proc reloadProc {} {
    global LogType runDir
    set readingDir "$runDir/reading"
    if {"$LogType" == "none"} {
        source $readingDir/readLog_none.tcl
    } elseif {"$LogType" == "time"} {
        source $readingDir/readLog_time.tcl
    } elseif {"$LogType" == "time_eclipse"} {
        source $readingDir/readLog_time_eclipse.tcl
    } elseif {"$LogType" == "studio"} {
        source $readingDir/readLog_studio.tcl
    } elseif {"$LogType" == "long"} {
        source $readingDir/readLog_long.tcl
    } elseif {"$LogType" == "threadtime"} {
        source $readingDir/readLog_threadtime.tcl
    } elseif {"$LogType" == "brief"} {
        source $readingDir/readLog_brief.tcl
    } elseif {"$LogType" == "2ndWord"} {
        source $readingDir/readLog_2ndWord.tcl
    } elseif {"$LogType" == "3rdWord"} {  # python logs etc
        source $readingDir/readLog_3rdWord.tcl        
    } elseif {"$LogType" == "keyword"} {
        source $readingDir/readLog_keyword.tcl
    } elseif {"$LogType" == "process"} {
        source $readingDir/readLog_process.tcl
    } elseif {"$LogType" == "tag"} {
        source $readingDir/readLog_tag.tcl
    } else {
        # no reader for this type (e.g. thread): fall back rather than leaving
        # whatever getLogLevel the previous log type installed
        source $readingDir/readLog_none.tcl
    }
    puts "reload proc readLog for logtype: $LogType"
}
