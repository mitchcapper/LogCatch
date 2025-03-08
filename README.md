LogCatch
===
Log viewer for Linux/Mac/Windows.
First designed for android adb logcat viewer but works with other log formats.
Designed to allow easy filtering and/or highlighting or multiple patterns at once.
This is written in tcl/tk.

Features:
- Context colored log lines. Logtype detection enhances filtering including: time, threadtime, brief, process, eclipse, keyword based, python logs (and other log formats that have severity as the 2nd or 3rd 'word' in the log line), and studio logs
- Filtering by keywords. This is done by awk regular expression like awk '/key|word/ {print}'
- Key word/Term Searching/navigating and highlighting (up to 9 highlight/searches at once)
- Saving all or part of log files after filtering
- Can read files from disk
- Clear all log messages prior to a specific term in the log file
- Entire session is saved (search/highlights/filtering) for easy resuming
- Auto scrolling / tailing log files (and option to temporarily suspend reading new lines on the connection)

Android Specific Features:
- Use adb logcat to read live logs from a connected android device (or emulator)
- Native tag/process filtering supported (and shows process list)
- LogLevel filtering on a per tag setting (ie only critical SensorManager log lines but verbose lines for any other tag)
- Automatically clear device log on connect

<!-- MarkdownTOC -->

- [Screenshot](#screenshot)
- [Requirements](#requirements)
	- [Linux](#linux)
	- [Mac](#mac)
	- [Windows](#windows)
- [Install](#install)
	- [Linux](#linux-1)
	- [Mac](#mac-1)
	- [Windows](#windows-1)
- [Usage](#usage)
	- [Starting](#starting)
	- [Linux/Mac user](#linuxmac-user)
	- [Windows user](#windows-user)
	- [Viewing log file or live Device Log](#viewing-log-file-or-live-device-log)
	- [Searching / Highlights](#searching--highlights)
	- [Tailing / Suspending Reads](#tailing--suspending-reads)
	- [Filtering](#filtering)
		- [Android Native Tag/Level filtering](#android-native-taglevel-filtering)
	- [Saving search terms/filtering](#saving-search-termsfiltering)
	- [Command Line Args](#command-line-args)
- [Log Types](#log-types)
- [Colors](#colors)
- [Author](#author)

<!-- /MarkdownTOC -->


## Screenshot
![ScreenShot](https://raw.github.com/pikey8706/LogCatch/master/screenshot_on_mac.png)

## Requirements
You need the binaries: wish (tk), gawk (in path as awk), and optionally adb (for android live logging),  also the command line tool tail for incremental loading.

### Linux
gawk for filtering, tk package for GUI, and android-sdk for adb.

### Mac
android-sdk for adb, gawk, and tk(from Homebrew).
From macOS Monterery, tk vesion 8.6.12(or over) from Homebrew can run this app.

### Windows
wish & gawk (in path as awk.exe) and for direct android connections the android-sdk for adb.

Easiest way to get all these is install [Git for Windows](https://git-for-windows.github.io/) or msys-git. This contains git, bash, awk, wish all in one.  

## Install
### Linux
Arch:
`pacman -S --needed gawk tk android-tools`

Debian/Ubuntu:
`apt-get install gawk tk android-tools`

### Mac
`prepare android-sdk`

`brew install gawk tcl-tk`

### Windows
Active TCL or any wish install should work but you need awk.exe as well.  The easiest solution is install [Git for Windows](https://git-for-windows.github.io/).

## Usage
### Starting
To launch app

### Linux/Mac user
- `git clone https://github.com/pikey8706/LogCatch.git`
- open LogCatch folder.
- Just W-click [runOnShell].
```
#on terminal.
$ ./runOnShell
#or
$ wish src/LogCatch.tcl --dir src
```

### Windows user
Assuming you have done installed git.
- git clone https://github.com/pikey8706/LogCatch.git
or
- Download zip file: https://github.com/pikey8706/LogCatch/archive/master.zip
- unzip LogCatch-master.zip
- open LogCatch-master folder.

- If you have powershell (which most Windows installs do by default) highly recommend running `LogCatch_winSetup.ps1` it will not just find the paths for everything but it will also create a LogCatch.lnk shortcut and LogCatch.bat file that can be used to start it (you can pass additional args to the LogCatch.bat file).
- If you don't have powershell or that doesn't work you can fall back to the older [LogCatch_winLauncher.vbs]. This automatically resolve path for wish/bash/awk in msys-git windows environment (Please create shortcut launcher by yourself).
- Note while it will try everywhere in PATH and some additional normal Windows git directories if it can't find wish/awk.exe it won't work properly. You do not need to add these to your path, just temporarily set your path to include those directories for running the winSetup or winLauncher script (as it will then save the absolute path and not need to use your normal paths).


### Viewing log file or live Device Log
To view log files click "Files" and browse to the log file you would like.  If you right click on the files button you can choose between "one time" and "incremental" loading.  Incremental loading runs tail itself on the file and if truncated the new file output will be put out still.  Clicking on the bullet next to the file will cause the file to reload as well.

To see log from connected devices after app launched:
- you should select android-sdk-directory or adb including directory from popup window.
- click "Devices" button to see device list connected to usb. after click Devices,
 devices name will list in "Source:".
- click Device name then log will be shown in window.

### Searching / Highlights
The primary interface shows 9 colored squares directly above the log file itself.  You can put a search term into any of these boxes and hit enter, and every instance of that term will be highlighted (the total matches are shown on the right side of the box).  You can search/seek the term by hitting then up and down arrow keys while within the respective highlight box.  Please note highlights/searches are case sensitive.

### Tailing / Suspending Reads
You can automatically scroll to the bottom of the log by having the "TrackTail" checked at the bottom right of the screen.
You can temporarily suspend logging new log lines to the log window by checking "SuspendRead" at the bottom right, note lines that come in while suspended are discarded.

### Filtering
Aside from the general minimal log level (verbose, trace, etc) configured in the upper left you can easily filter based on specific terms.  Changing any filter (when hitting enter) will clear the log view and reload the log file, or for a log stream it will only effect new log lines.

For Include/Exclude filter boxes they take an [AWK style pattern](https://web.mit.edu/gnu/doc/html/gawk_8.html).  This is a regex style form but in basics you can do multiple terms separated with a vertical pipe `|` ie: `CriticalException|Overheat|Battery` will match any log line with any of those 3 terms.

#### Android Native Tag/Level filtering
When connected to a device directly over ADB:

You can use standard ADB logcat filter strings in the "Native Tag Filter" box.  You can easily up the minimum log level for certain tags by selecting the part of one or more lines in the log window and in the right click context menu selecting "Require higher loglevel for selected lines". It doesn't matter what part of each line is selected it will automatically parse the log Tag from the line and raise the loglevel for that tag to one higher than the line itself is.

You can filter by a specific process and (or) by a specific android tag (tags are normally the service, etc that generates the message).  You may want to do OR not and filtering for situations where you want specific system messages that are not logged under the process you are about itself.

### Saving search terms/filtering
The existing session has all search/filters saved automatically to `~/.logcatch` these are reloaded on startup as well.

### Command Line Args
These are case sensitive, for Windows they can be specified after the logcatch.bat.

- --dir [dir] - Overrides the directory for LogCatch and its other scripts
- --clearOn [str] - If string is found in the log file everything before that string is cleared out.  Useful to essentially "start" logging when a specific event/action happens.
- --logType [LogType] - force the log type to this type (rather than detecting it)
- --file [file] - Start reading [file] as the log file
- --console - Shows the debug console window by default
- --clearOnTruncate - Clear the buffer if the file is truncated/overwritten
- --tail - Enable tail tracking by default

For android adb connections only:
- --proc [procRegex] - Takes a regex if a process matches the regex the logs are filtered to only output from that process
- --device [deviceRegex] - Takes a regex and if an android device with that name is found it is automatically attached to it

## Log Types
LogCatch determines the type of log from the first lineMax(100 by default) lines of the log file.  The log type is currently only used for extracting the LogLevel for the line all other functionality works no matter the file type.  The loglevel allows for initial colorization of the line and filtering based on level.  When logcat is used it specifically is set by us to output in threadtime format and we switch to using that.  You can right click on the log type (bottom right) to force a specific type.  The 'keyword' type highlights based on keywords in the line (fatal,error,warning, etc).

## Colors
By default every log level gets a different color and there are 9 different colors used for the search highlight boxes.   You can edit these colors by editing text_color_tags.list in the config directory, do not edit the first word on each line as that is the name we lookup the color by.   You can see all the possible color names tcl supports in the [TclColors.md](config/TclColors.md) file.

## Author
Hirohito Sasaki
email: pikey8706@gmail.com
