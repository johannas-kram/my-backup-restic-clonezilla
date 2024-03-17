# pre-checks
$home_directory=$home.Substring(9)
if ("$home_directory" -ne "$Env:UserName") {
    Write-Host "Error: Your username and your home directory name aren't equal." -ForegroundColor Red
    Write-Host "Home directory path: $home (home directory: $home_directory)"
    Write-Host "Username: $Env:UserName"
    Write-Host "Modify username or home directory, to be equal, then execute this script again."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    exit
}

$here="$PSScriptRoot"
$here="$here".Substring(0, "$here".Length-1)
Set-Location "$here"

function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-IsAdmin) -eq $false) {
    # install restic
    Write-Host "Hello, wecome to my-backup-restic-clonezilla setup script."
    Write-Host "First step is to install restic, using scoop."
    Write-Host -NoNewLine 'Press any key to proceed...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    try {
        scoop update
    } catch {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    scoop install restic
    Write-Host ""
    Write-Host "ok"
    Write-Host ""
    Write-Host ""

    # run as Admin
    Write-Host "All remaining steps will be done with elevated privileges (run as administrator)."
    Write-Host "You may asked to allow execution as administrator and then a new powershell window will be opened."
    Write-Host -NoNewLine 'Press any key to proceed...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    Stop-Process -Id $PID
}

# ask for parameters
Write-Host "Welcome back, now, please give some informations (type answer and press enter)."
Write-Host ""
$resticPwd = ""
$resticPwdRepeat = "-"
$localDevice = Read-Host -Prompt "Drive letter for your local backup harddrive"
if ($localDevice.Length -gt 1) {
    $localDevice = $localDevice.Substring(0, 1)
}
while ($resticPwd -ne $resticPwdRepeat) {
    $resticPwd = Read-Host -Prompt "restic repository password"
    $resticPwdRepeat = Read-Host -Prompt "restic repository password again"
}
$pcloudClientId = Read-Host -Prompt "pcloud api client id"
$pcloudClientSecret = Read-Host -Prompt "pcloud api client secret"
$filesDir = Read-Host -Prompt "Soure-Dir for files backup"
Write-Host ""
Write-Host ""
Write-Host "Thankyou. Now everything will be initialized. This can take a while."
Write-Host "What will be done:"
Write-Host " - Set environment variables"
Write-Host " - Save password in a textfile and provided to restic"
Write-Host " - Setup rclone"
Write-Host " - Create schedules (automatic files backup, for example)"
Write-Host " - Initialize local restic backup repository, if not already done"
Write-Host " - Sync local backup repository into your pcloud"
Write-Host ""
Write-Host -NoNewLine 'Press any key to proceed...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

# set environment variables
$Env:PATH="$Env:Path;$here\internal\bin\rclone;$here\internal\bin\shadowrun"
$Env:BACKUP_LOCAL_DEVICE="${localDevice}:"
$Env:BACKUP_WORKING_DIR="$here"
$Env:FILES_BACKUP_SOURCE_DIR="$filesDir"
$Env:RESTIC_REPOSITORY="${localDevice}:\backupRepo"
$Env:RESTIC_PASSWORD_FILE="$here\internal\password-file.txt"
[System.Environment]::SetEnvironmentVariable("PATH", "$Env:PATH", "Machine")
[System.Environment]::SetEnvironmentVariable("BACKUP_LOCAL_DEVICE", "$Env:BACKUP_LOCAL_DEVICE", "Machine")
[System.Environment]::SetEnvironmentVariable("BACKUP_WORKING_DIR", "$Env:BACKUP_WORKING_DIR", "Machine")
[System.Environment]::SetEnvironmentVariable("FILES_BACKUP_SOURCE_DIR", "$Env:FILES_BACKUP_SOURCE_DIR", "Machine")
[System.Environment]::SetEnvironmentVariable("RESTIC_REPOSITORY", "$Env:RESTIC_REPOSITORY", "Machine")
[System.Environment]::SetEnvironmentVariable("RESTIC_PASSWORD_FILE", "$Env:RESTIC_PASSWORD_FILE", "Machine")

# create password file
"$resticPwd" | Out-file -FilePath .\internal\password-file.txt

# setup rclone
rclone *>$null
$configPath="$HOME\AppData\Roaming\rclone\rclone.conf"
$token="token = {`"access_token`":`"`",`"token_type`":`"bearer`",`"expiry`":`"0001-01-01T00:00:00Z`"}"
$pcloudConfigBlock="`n`n[pcloud]`ntype = pcloud`nclient_id = $pcloudClientId`nclient_secret = $pcloudClientSecret`nhostname = eapi.pcloud.com`n$token`n"
Add-Content -Path "$configPath" -Value "$pcloudConfigBlock"
Write-Host ""
Write-Host ""
Write-Host "In the following step, we will refresh the pcloud token. Say yes twice (due to defaults you simply should have to press enter twice)"
Write-Host "A browser will be opened and you will have to authorize your app to cennect to pcloud."
Write-Host "On success you can close the browser window/tab, when you see: 'All done. Please go back to rclone'"
Write-Host -NoNewLine 'Press any key to proceed (and then press enter twice)...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host ""
Write-Host ""
rclone config reconnect pcloud:

# setup schedules
.\internal\scheduled\init\files-backup.ps1
.\internal\scheduled\init\cleanup.ps1
.\internal\scheduled\init\resticify-system-backup.ps1

# init restic repo if not already done
if (![System.IO.File]::Exists("$Env:RESTIC_REPOSITORY\config")) {
    mkdir $Env:RESTIC_REPOSITORY *>$null
    restic init
}

mkdir "$Env:BACKUP_LOCAL_DEVICE\system-backup-img" *>$null

# sync to pcloud
Write-Host ""
Write-Host ""
shadowrun -env -exec="$Env:BACKUP_WORKING_DIR\internal\sync-pcloud.ps1" "$Env:BACKUP_LOCAL_DEVICE" -- %shadow_device_1%

# Report success
Write-Host ""
Write-Host "Successfully initialized, installed and prepared, initialized restic repo locally (if not done before), synced to pcloud" -ForegroundColor Green
Write-Host "You can close this window now"
