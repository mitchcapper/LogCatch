@echo off
setlocal EnableDelayedExpansion

set "SETUP_BATCH=src\setup_path_for_windows.bat"
set "RUN_BATCH=src\logcatch.bat"

if exist "%SETUP_BATCH%" (
    if exist "%RUN_BATCH%" (
        for /f "usebackq delims=" %%I in (`powershell -Command "(Get-Item '%CD%\%SETUP_BATCH%').LastWriteTime.ToString('yyyyMMddHHmmss')"`) do set setup_date=%%I
        for /f "usebackq delims=" %%I in (`powershell -Command "(Get-Item '%CD%\%RUN_BATCH%').LastWriteTime.ToString('yyyyMMddHHmmss')"`) do set run_date=%%I
        
		echo  !setup_date! GEQ !run_date!
		echo setup_date: !setup_date!
		echo   run_date: !run_date!
        if !setup_date! GEQ !run_date! (
			echo RUNNING SETUP SCRIPT "%SETUP_BATCH%"
            CALL "%SETUP_BATCH%"
            timeout /t 3 /nobreak >nul
        ) else (
			echo setup_date is not greater than run_date
		)
    ) else (
        CALL "%SETUP_BATCH%"

    )
)

if exist "%RUN_BATCH%" (
    START /b CMD /C CALL "%RUN_BATCH%"
)

endlocal