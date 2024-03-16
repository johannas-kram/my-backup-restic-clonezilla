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

$FolderPath="$Env:BACKUP_LOCAL_DEVICE\system-backup-img"
if ((Get-ChildItem -Path $FolderPath -Force | Measure-Object).Count -eq 1) {
	$lastModifiedDateTime = (Get-Item $FolderPath).LastWriteTime -split " "
	$lastModifiedDate=$lastModifiedDateTime[0] -split "/"
	$lastModifiedTime=$lastModifiedDateTime[1]
	$lastModifiedYear=$lastModifiedDate[2]
	$lastModifiedMonth=$lastModifiedDate[0]
	$lastModifiedDay=$lastModifiedDate[1]
	restic backup --tag system --time "$lastModifiedYear-$lastModifiedMonth-$lastModifiedDay $lastModifiedTime" $FolderPath
	Remove-Item -Recurse -Force some_dir $FolderPath
	mkdir $FolderPath
}

# sync to pcloud
Write-Host ""
Write-Host ""
shadowrun.exe -env -exec="$Env:BACKUP_WORKING_DIR\internal\sync-pcloud.bat" "$Env:BACKUP_LOCAL_DEVICE" -- %shadow_device_1%
