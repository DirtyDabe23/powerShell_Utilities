$backupDirectory = "C:\IISBackup"

If (!(Test-Path $backupDirectory))
{
    New-Item -Type Directory -Path "C:\IISBackup" -Force
}


# SIG # Begin signature block#Script Signature# SIG # End signature block




