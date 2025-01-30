Set-StrictMode -version latest;
$ErrorActionPreference = "Stop";

$TO_FIND=@("wish", "awk", "bash")

$backupPaths = @() # List of paths to search if the executable is not found in the normal path, these backup paths are searched recursively

$pathEntriesCleaned = $env:PATH.Split(';', [StringSplitOptions]::RemoveEmptyEntries + [StringSplitOptions]::TrimEntries)

# Check if git.exe is in normal path under a "cmd" folder, if so we want the parent dir to be added to backu ppaths
$gitInPath = $pathEntriesCleaned | Where-Object { Test-Path "$_\git.exe" }
if($gitInPath -and ((Split-Path $gitInPath -Leaf) -eq "cmd")) {
    $parentDir = Split-Path (Split-Path $gitInPath -Parent) -Parent
    if(Test-Path $parentDir) {
        $backupPaths += $parentDir
    }
}

# Add known paths
$pathsToCheck = @(
    "$env:ProgramFiles\Git",
    "$env:LOCALAPPDATA\GitHub",
    "$env:LOCALAPPDATA\GitHubDesktop",
    "c:\msys64"
)
foreach($pth in $pathsToCheck) {
    if(Test-Path $pth) {
        $backupPaths += $pth
    }
}
$pathsFileAll = "src/path.list"
if (Test-Path $pathsFileAll) {
	Remove-Item $pathsFileAll
}

# Find absolute paths for each item in TO_FIND
$WISH_PATH=""
foreach($exe in $TO_FIND) {
	$pathFileExec = "src/${exe}_path.list"
	if (Test-Path $pathFileExec) {
		Remove-Item $pathFileExec
	}
	$exePath = $pathEntriesCleaned | ForEach-Object {
		$candidate = Join-Path $_ "$exe.exe"
		if(Test-Path $candidate) { $candidate }
	} | Select-Object -First 1

	if(-not $exePath) {
		foreach($bPath in $backupPaths) {
			$found = if ($PSVersionTable.PSVersion.Major -ge 5) {
				Get-ChildItem -Path $bPath -Depth 4 -Recurse -Filter "$exe.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
			} else {
				Get-ChildItem -Path $bPath -Recurse -Filter "$exe.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
			}
			if($found) {
				$exePath = $found.FullName
				break
			}
		}
	}

	if($exePath) {
		Add-Content -Path $pathsFileAll -Value $exePath
		Set-Content -Path $pathFileExec -Value $exePath
	}
}
Function GetItemPath {
	param(
		[Parameter(Mandatory=$true)]
		[string] $item
	)
	$pathFileExec = "src/${item}_path.list"
	if (Test-Path $pathFileExec) {
		return (Get-Content -Path $pathFileExec)
	}
	return $null
}
$WISH_PATH=GetItemPath "wish"
$final_bat="logcatch.bat"
$echoPrepend="@echo off`n"
$workingDirectory = split-path -parent $MyInvocation.MyCommand.Definition
#$directoryAppend="cd $workingDirectory`n"
$directoryAppend="cd /d %~dp0`n"
if ($null -ne $WISH_PATH) {
	Set-Content -Path $final_bat -Value "${echoPrepend}${directoryAppend}start `"NA`" /B `"$WISH_PATH`" src/LogCatch.tcl --dir src %*"
	$WshShell = New-Object -COMObject WScript.Shell
	$shortcutPath = "$PSScriptRoot\LogCatch.lnk"
	$Shortcut = $WshShell.CreateShortcut($shortcutPath)
	$Shortcut.TargetPath = $WISH_PATH
	$Shortcut.Arguments = "src/LogCatch.tcl --dir src"
	$Shortcut.Save()
	Write-Host "Shortcut created at $shortcutPath or use $final_bat to start"
}else{
	$BASH_PATH=GetItemPath "bash"
	if ($null -ne $BASH_PATH) {
		Set-Content -Path $final_bat -Value "${echoPrepend}${directoryAppend}`"$BASH_PATH`" -l -c `"wish src/LogCatch.tcl --dir src %*`""
	}else {
		Write-Error "Could not find wish.exe or bash.exe in path or known locations. Please install Tcl/Tk or Git Bash falling back to the old setup script but it probably won't work."
		./setup_path_for_windows.bat
	}
	
}