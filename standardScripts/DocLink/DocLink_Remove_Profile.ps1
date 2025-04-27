Clear-Host
$process = "DocLink Profile Application"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] Starting `n"


#Error Logging
$errorLog = @()



#Copying the Profile Starts Now
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Profile Removal"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

Try
{
    Remove-Item -Path "$env:AppData\altec products, inc\doc-link\profiles.dlps" -Force -ErrorAction Stop
}
Catch
{
    $errorLog += [PSCustomObject]@{
        failedTarget        = hostname
        processFailed       = $procProcess
        timeFailed          = Get-Date 
        ReasonFailed        = $error[0] #gets the most recent error
    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    Exit 1
}

#Function Ends
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds `n"

#Full Process Ends
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block



