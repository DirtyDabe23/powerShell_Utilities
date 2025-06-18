Clear-Host 
$process = Read-Host -Prompt "Enter a summary of the full script here, example: DocLink Upgrade"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

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
$errorLogFull = @()
$errorLog = @()



#Log Timing For the Full Process Start
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] [$process] Starting"

#Log Timing For Individual Functions and their standard function

    #Function Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = Read-Host -Prompt "Enter a name for subprocess here, example: Downloading Removal Tool"
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
            $errorDetails = $error[0] | Select *

            $currTime = Get-Date -format "HH:mm"
            $errorLog += [PSCustomObject]@{
                processFailed                   = $procProcess
                timeToFail                      = $currTime
                reasonFailed                    = $errorDetails 
                failedTargetStandardName        = $computerinfo.Name
                failedTargetDNSName             = $computerinfo.DNSHostName
                failedTargetUser                = $computerInfo.Username
                failedTargetWorkGroup           = $computerInfo.Workgroup
                failedTargetDomain              = $computerInfo.Domain
                failedTargetMemory              = $computerInfo.TotalphysicalMemory
                failedTargetChassis             = $computerInfo.ChassisSKUNumber
                failedTargetManufacturer        = $computerInfo.Manufacturer
                failedTargetModel               = $computerInfo.Model

            }
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
            Write-Output $errorLog
            $errorLogFull = $errorLog | select-object -last 1
            
        }

    #Function Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


#For Full Script End:
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
Write-Output "Errors: `n`n`n"
Write-Output $errorLogFull
$errorLogFull | Export-CSV -Path $errorExportPath
Stop-Transcript
Write-Output "The Full Error Log is available as a csv at $errorExportPath"
# SIG # Begin signature block#Script Signature# SIG # End signature block



