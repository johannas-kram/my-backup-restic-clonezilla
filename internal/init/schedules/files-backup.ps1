$taskname = "2-Hourly files backup powered by restic, synced to pcloud"
$action = New-ScheduledTaskAction -Execute "$Env:BACKUP_WORKING_DIR\internal\scheduled-2hourly0m-files-backup.ps1"

$times=@(2, 4, 6, 8, 10, 12)
$timeTypes=@("am", "pm")
$triggers=@()
for ($i=0; $i -lt $times.Length; $i++) {
    for ($j=0; $j -lt $timeTypes.Length; $j++) {
        $triggers += $(New-ScheduledTaskTrigger -Daily -At "$($times[$i])$($timeTypes[$j])")
    }
}

$principal = New-ScheduledTaskPrincipal -UserId "$Env:ComputerName\Administrator" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "$taskname" -Action $action -Trigger $triggers -Principal $principal -Settings $settings
