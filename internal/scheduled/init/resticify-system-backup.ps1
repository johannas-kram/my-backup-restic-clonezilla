$taskname = "Create snapshot of system-backup-image, powered by restic, sync to pcloud"
$action = New-ScheduledTaskAction -Execute "$Env:BACKUP_WORKING_DIR\internal\scheduled\atlogon-resticify-system-backup.bat"

$trigger = New-ScheduledTaskTrigger -AtLogOn

# NOPE! Use current user instead
$principal = New-ScheduledTaskPrincipal -UserId "$Env:ComputerName\$Env:UserName" -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "$taskname" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
