# run as Admin
function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-IsAdmin) -eq $false)  
{
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    Stop-Process -Id $PID
}

restic forget --tag files --keep-within 20h --keep-within-daily 7d --keep-within-weekly 4w --keep-monthly 12m --keep-yearly 2y
restic forget --tag system --keep-within 4w
restic prune

# sync to pcloud
Write-Host ""
Write-Host ""
shadowrun.exe -env -exec="$Env:BACKUP_WORKING_DIR\internal\sync-pcloud.bat" "$Env:BACKUP_LOCAL_DEVICE" -- %shadow_device_1%
