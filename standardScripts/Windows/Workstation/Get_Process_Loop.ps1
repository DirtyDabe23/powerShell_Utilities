    $procName = "Windows10UpgraderApp"
    $procRunning = $true
    while ($procRunning -eq $true)
    {
        Try{
            Get-Process -name $procName -ErrorAction Stop
            Start-Sleep -seconds 10
        } 
        Catch 
        {
            Write-Output "Process not detected"
            $procRunning = $false
        }

    }
# SIG # Begin signature block#Script Signature# SIG # End signature block




