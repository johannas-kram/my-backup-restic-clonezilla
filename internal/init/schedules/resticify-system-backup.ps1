$taskname = "Create snapshot of system-backup-image, powered by restic, sync to pcloud"
$action = New-ScheduledTaskAction -Execute "$Env:BACKUP_WORKING_DIR\internal\on-startup-resticify-system-backup.ps1"

$trigger = New-ScheduledTaskTrigger -AtLogOn

$principal = New-ScheduledTaskPrincipal -UserId "$Env:ComputerName\Administrator" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "$taskname" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
