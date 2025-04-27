Clear-Host
$process = "DocLink Profile Application"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] Starting `n"


#Error Logging
$errorLog = @()

#Downloading the Config File
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Profile Download"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

$url = "https://doclinkbuckettt.s3.amazonaws.com/DocLink/profiles.dlps"
$output = "C:\GIT_Scripts\profiles.dlps"

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"


Try
    {
        Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
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



    Try
    {
        Unblock-File -Path $output -ErrorAction Stop
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

#Download Ends
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds`n"

#Copying the Profile Starts Now
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Profile Copy"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

Try
{
    Copy-Item -Path $output -Destination "$env:AppData\altec products, inc\doc-link\profiles.dlps" -Force -ErrorAction Stop
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



