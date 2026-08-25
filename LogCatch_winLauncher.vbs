Set ws = CreateObject("Wscript.Shell")

Set objFso = CreateObject("Scripting.FileSystemObject")

' Resolve everything against the script's own folder: ws.Run inherits whatever
' working directory the shortcut happened to be launched with, so relative
' paths are not reliable here.
Dim baseDir, SETUP_BATCH, RUN_BATCH
baseDir = objFso.GetParentFolderName(WScript.ScriptFullName)
SETUP_BATCH = objFso.BuildPath(baseDir, "src\setup_path_for_windows.bat")
RUN_BATCH = objFso.BuildPath(baseDir, "src\logcatch.bat")

' vbHide is a VBA constant, not a VBScript one - spell the value out.
Const WINDOW_HIDDEN = 0

If objFso.FileExists(SETUP_BATCH) Then

    Dim updateRunBatch
    updateRunBatch = False
    If objFso.FileExists(RUN_BATCH) Then
        Set runFile = objFso.GetFile(RUN_BATCH)
        Set setupFile = objFso.GetFile(SETUP_BATCH)
        if runFile.DateLastModified < setupFile.DateLastModified Then
            updateRunBatch = True
        End If
    Else
        updateRunBatch = True
    End If

    if updateRunBatch Then
        ' Wait for setup to finish instead of guessing at a sleep duration.
        ws.Run "cmd /c """ & SETUP_BATCH & """", WINDOW_HIDDEN, True
    End If

End If

If objFso.FileExists(RUN_BATCH) Then
    ws.Run "cmd /c """ & RUN_BATCH & """", WINDOW_HIDDEN, False
Else
    MsgBox "LogCatch could not be started: " & RUN_BATCH & " was not generated." & vbCrLf & vbCrLf & _
           "Run src\setup_path_for_windows.bat manually to see why.", 16, "LogCatch"
End If
