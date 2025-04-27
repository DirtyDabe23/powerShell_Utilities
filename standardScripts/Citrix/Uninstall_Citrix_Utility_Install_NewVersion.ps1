$process = "Citrix Update"
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] starting"



$citrixPath= "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Software\Citrix\Citrix243197.exe"
$uninstaller = "\\uniqueParentCompanyusers\departments\public\tech-items\software\citrix\ReceiverCleanupUtility.exe"
$errorLog = @()


#If the path is accessible for the uninstaller proceed.
If(Test-Path $uninstaller)
{
    #Unlock the uninstaller utility
    Try
    {
        $procStartTime = Get-Date 
        $currTime = Get-Date -format "HH:mm"
        $procProcess = "Citrix Uninstall Utility: Unblock"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] starting"

        #allow the file to run.
        Unblock-File -Path $uninstaller -ErrorAction Stop
        
        
        $procEndTime = Get-Date
        $procNetTime = $procEndTime - $procStartTime
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
    }
    
    #if unlocking the file fails
    catch
    {
        $failTimer = Get-Date
        $errorLog += [PSCustomObject]@{
            failedTarget        = $user.Users
            processFailed       = $procProcess
            timeToFail          = $failTimer
            ReasonFailed        = $error[0]
        }
        Write-Output $errorLog | Format-List
        exit
         
    }
    
    #Execute the Uninstaller Utility
    try 
    {
        $procStartTime = Get-Date 
        $currTime = Get-Date -format "HH:mm"
        $procProcess = "Citrix Uninstall Utility: Execute"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] starting"
        
        #Run the uninstaller
        Start-Process -FilePath $uninstaller -argumentlist "/silent" -nonewwindow -wait  -ErrorAction Stop

        $procEndTime = Get-Date
        $procNetTime = $procEndTime - $procStartTime
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
    }
    
    #if running the uninstaller fails
    catch 
    {
        $errorLog += [PSCustomObject]@{
            failedTarget        = $user.Users
            processFailed       = $procProcess
            timeToFail          = $failTimerStart
            ReasonFailed        = $error[0] #gets the most recent error
        }
        Write-Output $errorLog | Format-List
        exit  
    }
    
}
Else
{
    Write-Output "Unable to access uninstaller"
    Exit
}

#If the path is accessible for the installer proceed
If (Test-Path $citrixPath)
{
    #Unblock the installer for Citrix
    try 
    {
        $procStartTime = Get-Date 
        $currTime = Get-Date -format "HH:mm"
        $procProcess = "Citrix Installer: Unblock"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] starting"
        Unblock-File -path $citrixPath

        $procEndTime = Get-Date
        $procNetTime = $procEndTime - $procStartTime
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
    }
    
    #If unblocking the installer fails
    catch 
    {
        $errorLog += [PSCustomObject]@{
            failedTarget        = $user.Users
            processFailed       = $procProcess
            timeToFail          = $failTimerStart
            ReasonFailed        = $error[0] #gets the most recent error
        }
        Write-Output $errorLog | Format-List
        exit     
    }

    #Attempt to run the installer
    try 
    {
        $procStartTime = Get-Date 
        $currTime = Get-Date -format "HH:mm"
        $procProcess = "Citrix Installer: Execute"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] starting"
        Start-Process -FilePath $citrixPath -argumentList '/silent /noreboot /autoUpdateCheck=Auto'  -wait  
        $procEndTime = Get-Date
        $procNetTime = $procEndTime - $procStartTime
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"  
    }

    #If running the uninstaller fails
    catch 
    {
        $errorLog += [PSCustomObject]@{
            failedTarget        = $user.Users
            processFailed       = $procProcess
            timeToFail          = $failTimerStart
            ReasonFailed        = $error[0] #gets the most recent error
        }
        Write-Output $errorLog | Format-List
        exit
    }
}
else 
{
    Write-Output "Unable to access installer"
    Exit  
}


$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block




