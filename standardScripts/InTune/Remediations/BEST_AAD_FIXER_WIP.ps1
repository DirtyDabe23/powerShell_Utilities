Clear-Host 
$process = "AAD Enrollment"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

#Clears the Error Log
$error.clear()


#This WMI Query gets a ton of rich information about the endpoint
$computerInfo = Get-WMIObject -class Win32_ComputerSystem | select-object -Property *

#File Creation Objects
$shareLoc = "$env:Temp"
$logFileName = "$($process).txt"
$errorLogCSV = "$($process).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$logFileName
$errorExportPath = $shareLoc+$dateTime+"."+$errorLogCSV
Start-Transcript -Path $exportPath

#Error Logging
$errorLog = @()
$errorDetails = $null


#Log Timing For the Full Process Start
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | Starting"





######################################################### FUNCTIONS START HERE#######################################################
    #Log Timing For Individual Functions and their standard function
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Clearing Old Enrollments"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
    Try
    {
        #get scheduled tasks 
        $regGuids = @()
        $Paths = Get-ScheduledTask -TaskPath \Microsoft\Windows\EnterpriseMgmt* | select TaskPath
        ForEach ($path in $paths)
        {
            $regGUIDS += $Path.TaskPath.Split("EnterpriseMgmt\")[1].trim("\")
        }

        #get the registration guids
        $regGuids = $regGuids | Select -unique

        $removalPath = $paths.taskPAth | select -Unique


        #Remove the scheduled tasks, once the container is empty it self removes.
        ForEach ($path in $removalPath)
        {
            Get-ScheduledTask -taskpath $path | Unregister-ScheduledTask -confirm:$false
        }


        #Remove the Registry Keys
        ForEach ($guid in $regGuids)
        {
            $items = @()
            $items = "HKLM:\SOFTWARE\Microsoft\Enrollments\$guid",`
            "HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$guid",`
            "HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$guid" ,`
            "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$guid",`
            "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$guid",`
            "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$guid",`
            "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$guid",`
            "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$guid"


            ForEach ($item in $items)
            {
                If (test-path $item)
                {
                Get-ITem -Path $item | Remove-Item -Force -Recurse
                }
            }
        }
        #A few extra registry keys to remove in case they exist, specifically related to the device itself.
        If (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID"){Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID" | Remove-Item -Force -Verbose}
        If (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger"){Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger" | Remove-Item -Force -Verbose}
        #This needs run in the users context, otherwise it will not remove their profile but the administrative accounts!
        If(Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"){Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"  | REmove-ITem -Force -Recurse}




        #Remove the InTune Certificate
        Get-ChildItem "Cert:\LocalMachine\CA" | Where {($_.subject -like 'CN=Microsoft Intune MDM Device CA')} | Remove-Item -Force -Verbose
        dsregcmd /leave
    }
    
    Catch
    {
        $errorDetails = $error[0] | Select *
        $currTime = Get-Date -format "HH:mm"
        $errorLog += [PSCustomObject]@{
            processFailed                           = $procProcess
            timeToFail                              = $currTime
            reasonFailed                            = $errorDetails 
            failedTargetStandardName                = $computerinfo.CsName
            failedTargetDNSName                     = $computerinfo.CsDNSHostName
            failedTargetUser                        = $computerInfo.CsUserName
            failedTargetWorkGroup                   = $computerInfo.CsWorkgroup
            failedTargetDomain                      = $computerInfo.CsDomain
            failedTargetOSOrganization              = $computerInfo.OsOrganization
            failedTargetChassis                     = $computerInfo.CsChassisSKUNumber
            failedTargetManufacturer                = $computerInfo.CsManufacturer
            failedTargetModel                       = $computerInfo.CsModel
            failedTargetTotalPhysicalMemory         = $computerInfo.CsTotalPhysicalMemory
            failedTargetPhysicallyInstalledMemory   = $computerInfo.PhysicallyInstalledMemory
            failedTargetOsFreePhysicalMemory        = $computerInfo.OsFreePhysicalMemory
            failedTargetOsFreeVirtualMemory         = $computerInfo.OsFreeVirtualMemory
            failedTargetOsInUseVirtualMemory        = $computerInfo.OsInUseVirtualMemory
            failedTargetProcessorName               = $computerInfo.CSProcessors.Name
            failedTargetProcessorSpeedMhz           = $computerInfo.CSProcessors.MaxClockSpeed
            failedTargetProcessorNumOfCores         = $computerInfo.CSProcessors.NumberofCores
            failedTargetProcessorNumOfThreads       = $computerInfo.CSProcessors.NumberOfLogicalProcessors
            failedTargetProcessorStatus             = $computerInfo.CSPRocessors.Status
            failedTargetPowerSupplyState            = $computerInfo.CSPowerSupplyState
            failedTargetThermalState                = $computerInfo.CSThermalState
            failedTargetBootState                   = $computerInfo.CsBootupState
            failedTargetOSVersion                   = $computerInfo.OSVersion
            failedTargetOSStatus                    = $computerInfo.OsStatus
            failedTargetUptime                      = $computerInfo.OsUptime
            failedTargetNumUsers                    = $computerInfo.OsNumberOfUsers
            failedTargetTimezone                    = $computerInfo.TimeZone
            failedTargetLogonServer                 = $computerInfo.LogonServer
        }

        Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
        Write-Output $errorLog
    }

#Function Ends
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


######################################################### FUNCTIONS END HERE ########################################################

######################################################### NON TERMINATING ERROR CHECK ###############################################
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Error Review"
Write-Output "[$($currTime)] | [$process] | [$procProcess] | Starting"
if ($null -eq $errorDetails)
{
    if ($error.count -gt 0)
    {
        ForEach ($event in $error)
        {
            $errorDetails = $event| Select *
            $errorLog += [PSCustomObject]@{
                processFailed                           = $procProcess
                timeToFail                              = $currTime
                reasonFailed                            = $errorDetails 
                failedTargetStandardName                = $computerinfo.CsName
                failedTargetDNSName                     = $computerinfo.CsDNSHostName
                failedTargetUser                        = $computerInfo.CsUserName
                failedTargetWorkGroup                   = $computerInfo.CsWorkgroup
                failedTargetDomain                      = $computerInfo.CsDomain
                failedTargetOSOrganization              = $computerInfo.OsOrganization
                failedTargetChassis                     = $computerInfo.CsChassisSKUNumber
                failedTargetManufacturer                = $computerInfo.CsManufacturer
                failedTargetModel                       = $computerInfo.CsModel
                failedTargetTotalPhysicalMemory         = $computerInfo.CsTotalPhysicalMemory
                failedTargetPhysicallyInstalledMemory   = $computerInfo.PhysicallyInstalledMemory
                failedTargetOsFreePhysicalMemory        = $computerInfo.OsFreePhysicalMemory
                failedTargetOsFreeVirtualMemory         = $computerInfo.OsFreeVirtualMemory
                failedTargetOsInUseVirtualMemory        = $computerInfo.OsInUseVirtualMemory
                failedTargetProcessorName               = $computerInfo.CSProcessors.Name
                failedTargetProcessorSpeedMhz           = $computerInfo.CSProcessors.MaxClockSpeed
                failedTargetProcessorNumOfCores         = $computerInfo.CSProcessors.NumberofCores
                failedTargetProcessorNumOfThreads       = $computerInfo.CSProcessors.NumberOfLogicalProcessors
                failedTargetProcessorStatus             = $computerInfo.CSPRocessors.Status
                failedTargetPowerSupplyState            = $computerInfo.CSPowerSupplyState
                failedTargetThermalState                = $computerInfo.CSThermalState
                failedTargetBootState                   = $computerInfo.CsBootupState
                failedTargetOSVersion                   = $computerInfo.OSVersion
                failedTargetOSStatus                    = $computerInfo.OsStatus
                failedTargetUptime                      = $computerInfo.OsUptime
                failedTargetNumUsers                    = $computerInfo.OsNumberOfUsers
                failedTargetTimezone                    = $computerInfo.TimeZone
                failedTargetLogonServer                 = $computerInfo.LogonServer
            
            }
        }
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Non-Terminating Error Details Below:`n"
        Write-Output $errorLog
        $errorLog | Export-CSV -Path $errorExportPath
    }
    else
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] There were No Errors!`n"
    }
}
#If there are non-terminating errors, but they were caught
Else{
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Error Details Below:`n"
    Write-Output $errorLog
    $errorLog | Export-CSV -Path $errorExportPath

}
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


######################################################### FINAL END HERE ########################################################
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
Stop-Transcript
Write-Output "The Full Error Log is available as a csv at $errorExportPath"
Write-Output "Make sure to run the command below as in THE STANDARD USER'S POWERSHELL CONTEXT"
Write-Output 'If(Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"){Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"  | Remove-Item -Force -Recurse}'

# SIG # Begin signature block#Script Signature# SIG # End signature block



