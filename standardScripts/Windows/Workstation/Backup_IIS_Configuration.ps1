$backupDirectory = "C:\IISBackup"

If (!(Test-Path $backupDirectory))
{
    New-Item -Type Directory -Path "C:\IISBackup" -Force
}


SignatureBlock

