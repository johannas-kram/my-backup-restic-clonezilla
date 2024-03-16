$taskname = "Daily clean up restic repository and sync changes to pcloud"
$action = New-ScheduledTaskAction -Execute "$Env:BACKUP_WORKING_DIR\internal\scheduled-daily20h30m-cleanup.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At "8:30 pm"

$principal = New-ScheduledTaskPrincipal -UserId "$Env:ComputerName\Administrator" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "$taskname" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
