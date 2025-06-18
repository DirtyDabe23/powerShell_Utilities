Clear-Host 
$process = Read-Host -Prompt "Enter a summary of the full script here, example: DocLink Upgrade"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process
#Clears the Error Log
$error.clear()
#This WMI Query gets a ton of rich information about the endpoint
$computerInfo = Get-computerInfo -Property *  | select-object -Property *

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
    $procProcess = "Applying Holds"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"


    #Standard Try Catch Block
        Try
        {
            $processPath = Read-Host -Prompt "Enter the Process Path Here, or edit on line 40 of the Template Script"
            $processArguments = Read-Host -Prompt "Enter the command line arguments for your script here."
            Start-Process -FilePath $processPath -ArgumentList $processArguments -Wait -ErrorAction Stop
        }
        Catch
        {
            try
            {
            #this is where to enter the 'oh shit' backup plan
            $processPath = Read-Host -Prompt "Enter the Process Path Here, or edit on line 40 of the Template Script"
            $processArguments = Read-Host -Prompt "Enter the command line arguments for your script here."
            Start-Process -FilePath $processPath -ArgumentList $processArguments -Wait -ErrorAction Stop
            }
            catch
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
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"
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
# SIG # Begin signature block#Script Signature# SIG # End signature block



