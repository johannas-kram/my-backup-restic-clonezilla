$here=Get-Location

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

# Greetings
Write-Host "Hello, I am the setup script. I will ask you some questions."
Write-Host ""

# ask for parameters
$resticPwd = ""
$resticPwdRepeat = "-"
$localDevice = Read-Host -Prompt "Drive letter for your local backup harddrive"
while ($resticPwd -ne $resticPwdRepeat) {
    $resticPwd = Read-Host -Prompt "restic repository password"
    $resticPwdRepeat = Read-Host -Prompt "restic repository password again"
}
$pcloudClientId = Read-Host -Prompt "pcloud api client id"
$pcloudClientSecret = Read-Host -Prompt "pcloud api client secret"
$filesDir = Read-Host -Prompt "Soure-Dir for files backup"
Write-Host ""

# install restic
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
try {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} catch {
    scoop update
}
scoop install restic
Write-Host ""
Write-Host ""

# set environment variables
[System.Environment]::SetEnvironmentVariable("PATH", "$Env:PATH;$here\internal\bin\rclone", "Machine")
[System.Environment]::SetEnvironmentVariable("PATH", "$Env:PATH;$here\internal\bin\shadowrun", "Machine")
[System.Environment]::SetEnvironmentVariable("BACKUP_LOCAL_DEVICE", "${localDevice}:", "Machine")
[System.Environment]::SetEnvironmentVariable("BACKUP_WORKING_DIR", "$here", "Machine")
[System.Environment]::SetEnvironmentVariable("FILES_BACKUP_SOURCE_DIR", "$filesDir", "Machine")
[System.Environment]::SetEnvironmentVariable("RESTIC_REPOSITORY", "${localDevice}:\repo", "Machine")
[System.Environment]::SetEnvironmentVariable("RESTIC_PASSWORD_FILE", "$here\internal\password-file.txt", "Machine")

# create password file
"$resticPwd" | Out-file -FilePath "$here\internal\password-file.txt"

# setup rclone
$configPath="$HOME\AppData\Roaming\rclone\rclone.conf"
$token="token = {`"access_token`":`"`",`"token_type`":`"bearer`",`"expiry`":`"0001-01-01T00:00:00Z`"}"
$pcloudConfigBlock="`n`n[pcloud]`ntype = pcloud`nclient_id = $pcloudClientId`nclient_secret = $pcloudClientSecret`nhostname = eapi.pcloud.com`n$token`n"
Add-Content -Path "$configPath" -Value "$pcloudConfigBlock"
Write-Host "In the following step, we will refresh the pcloud token. Say yes twice (due to defaults you simply should have to press enter twice)"
rclone config reconnect pcloud:

# setup schedules

# init restic repo if not already done
if (![System.IO.File]::Exists("${localDevice}:\repo\config")) {
    restic init
}

# sync to pcloud
Write-Host ""
Write-Host ""
shadowrun -env -exec="$here\internal\sync-pcloud.ps1" ${localDevice}: -- %shadow_device_1%

Write-Host ""
Write-Host "Successfully initialized, installed and prepared, initialized restic repo locally (if not done before), synced to pcloud" -ForegroundColor Green
