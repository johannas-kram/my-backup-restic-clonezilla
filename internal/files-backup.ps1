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

restic backup --tag files --exclude="node_modules" --use-fs-snapshot "$Env:FILES_BACKUP_SOURCE_DIR"

# sync to pcloud
Write-Host ""
Write-Host ""
shadowrun -env -exec="$Env:BACKUP_WORKING_DIR\internal\sync-pcloud.ps1" "$Env:BACKUP_LOCAL_DEVICE" -- %shadow_device_1%
