@echo off

if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
powershell.exe "%BACKUP_WORKING_DIR%\internal\cleanup.ps1"
echo.
echo.
echo.
echo "Done. Window closes in 60 seconds. Press any key to close it now, or close it manually."
timeout /T 60 >nul
exit
