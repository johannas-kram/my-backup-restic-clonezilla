Start-Process "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe" "$Env:BACKUP_WORKING_DIR\internal\cleanup.ps1" -WindowStyle Minimized

Write-Host ""
Write-Host ""
Write-Host "Press enter to close this window or close it manually"
Read-Host ""
