@echo off

set shadowCopy=%1

echo.
echo.
echo checking
restic check
if %errorlevel% neq 0 echo error & exit


echo syncing
echo.
echo.
rclone sync %shadowCopy%\repo\ pcloud:backupRepo

echo.
echo.
echo cleanups
del volume.txt
del result.txt

echo.
echo.
