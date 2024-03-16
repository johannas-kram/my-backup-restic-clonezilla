$shadowCopy=$args[0]

restic check

if ($?) {
    rclone sync $shadowCopy\repo\ pcloud:
} else {
    Write-Host ""
    Write-Host "restic check has detected errors in your backup repository!" -ForegroundColor Red
    Write-Host "Skipped sync to pcloud."
}
