Clear-Host
$process = "DocLink Update"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] Starting"


#Error Logging
$errorLog = @()

#Downloads Start
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Update Download"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

$url = "http://evapaz-sql1/dlremote/applauncher/setup.exe"
#$Path is the containing folder for the process.
$Path = "C:\GIT_Scripts"

$progs = Get-CimInstance -Class Win32_Product


#$output = Location and Name where File should Be Saved
$output = "C:\GIT_Scripts\$(Get-Date -format yyyy-MM-dd)_doclink.exe"

if (!(Test-Path $Path))
{
    Try
    {
        New-Item -itemType Directory -Path C:\ -Name GIT_Scripts -ErrorAction Stop
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
}
else
{
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Folder Already Exists"
}



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
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

#Removal Starts if Applicable
If($progs -like "*Altec*")
{
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Uninstall"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"
    Try
    {
        Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'" | Invoke-CimMethod -Name Uninstall
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
    
    #Removal Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"    
}

#Installer Start
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Installation"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"
Try
{
    Start-Process -FilePath $output -argumentList '/s /v"/qn"' -wait -ErrorAction Stop
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
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


#Copying over the Config File
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Profile Copy"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

Try
{
    Test-Path "$env:AppData\altec products, inc\doc-link\profiles.dlps" -ErrorAction Stop
    Test-Path "\\uniqueParentCompanyusers\departments\public\tech-items\misc\profiles.dlps" -ErrorAction Stop
    Copy-Item -Path "\\uniqueParentCompanyusers\departments\public\tech-items\misc\profiles.dlps" -Destination "$env:AppData\altefc products, inc\doc-link\profiles.dlps" -Force -ErrorAction Stop
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




#Full Process Ends
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block




