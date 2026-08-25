@echo off
cd /d %~dp0

echo Searching command wish and awk

set SEARCH_PATH="c:\Program Files\Git"

set PATH_LIST="path.list"

if EXIST %PATH_LIST% (
  del %PATH_LIST%
)

:: NOTE: batch has no "break" for a for-loop, and a :label inside a
:: parenthesized block makes cmd.exe fail to parse the whole block
:: ("Unexpected )"). "set /p" reads only the first line, which gives us
:: the first-match-wins behaviour we want without any loop at all.

set WISH_CMD="wish.exe"
set WISH_PATH=
dir /s /b %SEARCH_PATH% 2>nul | findstr "%WISH_CMD%$" > path_list.tmp
if exist path_list.tmp set /p WISH_PATH=<path_list.tmp
if defined WISH_PATH (
  echo "%WISH_PATH%"
  echo %WISH_PATH%>> %PATH_LIST%
  echo %WISH_PATH%> wish_path.list
  echo @echo off > logcatch.bat
  echo cd /d %%~dp0 >> logcatch.bat
  echo start "-" /B "%WISH_PATH%" "%%~dp0LogCatch.tcl" %%* >> logcatch.bat
  set WISH_FOUND=1
)
if exist path_list.tmp del path_list.tmp


set BASH_CMD="bash.exe"
set BASH_PATH=
dir /s /b %SEARCH_PATH%\bin 2>nul | findstr "%BASH_CMD%$" > path_list.tmp
if exist path_list.tmp set /p BASH_PATH=<path_list.tmp
if defined BASH_PATH (
  echo "%BASH_PATH%"
  echo %BASH_PATH%>> %PATH_LIST%
  echo %BASH_PATH%> bash_path.list
)
if defined BASH_PATH if not defined WISH_FOUND (
  echo @echo off > logcatch.bat
  echo cd /d %%~dp0 >> logcatch.bat
  echo start "-" /B "%BASH_PATH%" -l -c "wish '%%~dp0LogCatch.tcl' %%*" >> logcatch.bat
)
if exist path_list.tmp del path_list.tmp


set AWK_CMD="awk.exe"
set AWK_PATH=
dir /s /b %SEARCH_PATH% 2>nul | findstr "%AWK_CMD%$" > path_list.tmp
if exist path_list.tmp set /p AWK_PATH=<path_list.tmp
if defined AWK_PATH (
  echo "%AWK_PATH%"
  echo %AWK_PATH%>> %PATH_LIST%
  echo %AWK_PATH%> awk_path.list
)
if exist path_list.tmp del path_list.tmp


if not exist %PATH_LIST% (
  echo.
  echo ERROR: found none of wish.exe / bash.exe / awk.exe under %SEARCH_PATH%
  echo Install Git for Windows, or edit SEARCH_PATH at the top of this script.
  exit /b 1
)
if not defined AWK_PATH (
  echo.
  echo WARNING: awk.exe not found. LogCatch needs GNU Awk 5.0 or newer to filter logs.
)
if not defined WISH_FOUND if not defined BASH_PATH (
  echo.
  echo WARNING: neither wish.exe nor bash.exe found, logcatch.bat was not generated.
)

exit /b 0
