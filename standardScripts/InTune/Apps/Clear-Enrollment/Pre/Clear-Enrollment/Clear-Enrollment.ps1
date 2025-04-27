function Clear-Enrollment{
    [CmdletBinding()]
    param(
        [String] $ComputerName,
        [switch] $InTune,
        [switch] $OfficeApps,
        [switch] $Reboot,
        [switch] $Message
    )

    $process = "AAD Enrollment"
    #Sets the PowerShell Window Title
    $host.ui.RawUI.WindowTitle = $process

    #Clears the Error Log
    $error.clear()


    #This WMI Query gets a ton of rich information about the endpoint
    $computerInfo = Get-ComputerInfo | select-object -Property *

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





    if($InTune){
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
            $Paths = Get-ScheduledTask -TaskPath \Microsoft\Windows\EnterpriseMgmt* | Select-Object TaskPath
            ForEach ($path in $paths)
            {
                $regGUIDS += $Path.TaskPath.Split("EnterpriseMgmt\")[1].trim("\")
            }
            Get-ScheduledTask -TaskPath "\Microsoft\InTune*" | Unregister-ScheduledTask -Confirm:$false

            #get the registration guids
            $regGuids = $regGuids | Select-Object -unique

            $removalPath = $paths.taskPAth | Select-Object -Unique


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
            if (Get-Item  -Path "$env:LocalAppData\Microsoft\Office\Licenses" -errorAction Ignore){Get-Item  -Path "$env:LocalAppData\Microsoft\Office\Licenses" | Remove-Item -Force -Recurse}
            If (Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Licensing" -erroraction Ignore){Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Licensing" | Remove-Item -Force -Recurse}
            If (Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -erroraction Ignore){Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" | Remove-Item -Force -Recurse}
            If (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID" -ErrorAction Ignore){Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID" | Remove-Item -Force -Verbose}
            If (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger" -ErrorAction Ignore){Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger" | Remove-Item -Force -Verbose}
            If (Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\MDM\" -ErrorAction Ignore){Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\MDM" | remove-Item -Force -Recurse}
            #This needs run in the users context, otherwise it will not remove their profile but the administrative accounts!
            If (Get-Process OneDrive -ErrorAction Ignore){Stop-Process -Name "OneDrive" -Force}
            If(Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1" -errorAction Ignore){Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"  | Remove-Item -Force -Recurse}
            


            #Remove the InTune Certificate
            If(Get-ChildItem "Cert:\LocalMachine\CA" | Where-Object {($_.subject -like 'CN=Microsoft Intune MDM Device CA')} -ErrorAction Ignore)
            {
                Get-ChildItem "Cert:\LocalMachine\CA" | Where-Object {($_.subject -like 'CN=Microsoft Intune MDM Device CA')} -ErrorAction Ignore | Remove-Item -Force -Verbose
            }


            If(Get-ChildItem "Cert:\LocalMachine\AAD Token Issuer\" -ErrorAction Ignore)
            {
                $oldTokenIssuers = Get-ChildItem "Cert:\LocalMachine\AAD Token Issuer\" -ErrorAction Ignore
                ForEach ($oldTokenIssuer in $oldTokenIssuers)
                {
                    Remove-Item -Path $oldTokenIssuer.psPath -Force -Recurse
                }
            }

            #This is the part of the script that leaves the tenant.
            Start-Process -FilePath "$env:SystemRoot\System32\dsregcmd.exe"  -argumentlist "/leave" -Wait -NoNewWindow -UseNewEnvironment

            #These are the functions that removes old user enrollment packages and old user accounts.
            $oldUserEnrollmentPackages = Get-Item -Path "$env:LocalAppData\Packages\Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Removing Old User AAD Packages"

            while ($oldUserEnrollmentPackages)
            {
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Waiting for AAD Package Availability"
                ForEach ($oldUserEnrollmentPackage in $oldUserEnrollmentPackages)
                {
                    try{
                    Remove-Item -path $oldUserEnrollmentPackage -Force -Recurse -ErrorAction Stop
                    }
                    catch{
                        Start-Sleep -Seconds 5
                        Remove-Item -path $oldUserEnrollmentPackage -Force -Recurse -ErrorAction SilentlyContinue
                    }

                }
                $oldUserEnrollmentPackages = Get-Item -Path "$env:LocalAppData\Packages\Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore
            }
            
            #this removes WAM accounts as stated at this link: https://learn.microsoft.com/en-us/office/troubleshoot/activation/reset-office-365-proplus-activation-state#sectiona
            if(-not [Windows.Foundation.Metadata.ApiInformation,Windows,ContentType=WindowsRuntime]::IsMethodPresent("Windows.Security.Authentication.Web.Core.WebAuthenticationCoreManager", "FindAllAccountsAsync"))
            {
                throw "This script is not supported on this Windows version. Please, use CleanupWPJ.cmd."
            }

            Add-Type -AssemblyName System.Runtime.WindowsRuntime

            Function AwaitAction($WinRtAction) {
            $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
            $netTask = $asTask.Invoke($null, @($WinRtAction))
            $netTask.Wait(-1) | Out-Null
            }

            Function Await($WinRtTask, $ResultType) {
            $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
            $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
            $netTask = $asTask.Invoke($null, @($WinRtTask))
            $netTask.Wait(-1) | Out-Null
            $netTask.Result
            }

            $provider = Await ([Windows.Security.Authentication.Web.Core.WebAuthenticationCoreManager,Windows,ContentType=WindowsRuntime]::FindAccountProviderAsync("https://login.microsoft.com", "organizations")) ([Windows.Security.Credentials.WebAccountProvider,Windows,ContentType=WindowsRuntime])

            $accounts = Await ([Windows.Security.Authentication.Web.Core.WebAuthenticationCoreManager,Windows,ContentType=WindowsRuntime]::FindAllAccountsAsync($provider, "d3590ed6-52b3-4102-aeff-aad2292ab01c")) ([Windows.Security.Authentication.Web.Core.FindAllAccountsResult,Windows,ContentType=WindowsRuntime])

            $accounts.Accounts | ForEach-Object { AwaitAction ($_.SignOutAsync('d3590ed6-52b3-4102-aeff-aad2292ab01c')) }

            $FinalEnrollmentPackages = Get-ITem -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\*"
            ForEach ($finalEnrollmentPackage in $FinalEnrollmentPackages)
            {
                $checkPackage = Get-ITem -Path $finalEnrollmentPackage.PSPath | Get-ItemProperty
                if ($checkPackage.UPN)
                {
                    Remove-Item -Path $finalEnrollmentPAckage.PSPath -recurse -Force
                }
            }
    }
        
        Catch
        {
            $errorDetails = $error[0] | Select-Object *
            $currTime = Get-Date -format "HH:mm"
            $errorLog += [PSCustomObject]@{
                processFailed                           = $procProcess
                timeToFail                              = $currTime
                reasonFailed                            = $errorDetails 
                failedTargetStandardName                = $computerinfo.CsName
                failedTargetSerialNumber                = $computerInfo.BiosSerialNumber
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

    }
    if (($InTune) -or ($OfficeApps)){
    #Function Starts, to create a scheduled task that runs once in the user context
    #Log Timing For Individual Functions and their standard function
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "User Enrollment Data Cleanup - Task Build"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
    Try{
        if([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'){
    #We create a Scheduled Task that is set to run after 1 minute here, to run in the local user context and clear out things that are under their profile
        $script = {
        $procStartTime = Get-Date 
        $currTime = Get-Date -format "HH:mm"
        $procProcess = "User Enrollment Data Cleanup - Run as User"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"
        $shareLoc = "$env:Temp"
        $dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
        $userTaskExportPath = $shareLoc+$dateTime+"."+$logFileName
        Start-Transcript -Path $userTaskExportPath
        $logFileName = "$($procProcess).txt"
        $chromeBookmarks = "$env:LocalAppData\Google\Chrome\User Data\Default\Bookmarks"
        $edgeBookmarks =  "$env:LocalAppData\Microsoft\Edge\User Data\Default\Bookmarks"
        if(!(Test-Path "C:\_Backup_AppData")){New-Item -Type Directory -Path "C:\_Backup_AppData\"}
        If (Test-Path $edgeBookmarks){Get-Item $edgeBookMarks | Copy-Item -Destination "C:\_Backup_AppData\$($($env:UserName).replace('.','-'))_edgeBookmarks" -Verbose -Force}
        if(Test-Path $chromeBookmarks){Get-Item $chromeBookmarks | Copy-Item -Destination "C:\_Backup_AppData\$($($env:UserName).replace('.','-'))_chromeBookMarks" -Verbose -Force}
        
        If (Get-Process -Name "OneDrive"){Stop-Process -Name "OneDrive" -Force}
        If (Get-Process -name  "Outlook"){Stop-Process -Name "Outlook" -Force}
        If (Get-Process -name "msteams"){Stop-Process -Name "MSTeams" -Force}
        
            
            #These are the functions that removes old user enrollment packages and old user accounts.
            $oldUserEnrollmentPackages = Get-Item -Path "$env:LocalAppData\Packages\Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Removing Old User AAD Packages"

            while ($oldUserEnrollmentPackages)
            {
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Waiting for AAD Package Availability"
                ForEach ($oldUserEnrollmentPackage in $oldUserEnrollmentPackages)
                {
                    try{
                    Remove-Item -path $oldUserEnrollmentPackage -Force -Recurse -ErrorAction Stop
                    }
                    catch{
                        Start-Sleep -Seconds 5
                        Remove-Item -path $oldUserEnrollmentPackage -Force -Recurse -ErrorAction SilentlyContinue
                    }

                }
                $oldUserEnrollmentPackages = Get-Item -Path "$env:LocalAppData\Packages\Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore
            }
        If(Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"){Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"  | Remove-Item -Force -Recurse}
        If (Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Licensing" -erroraction Ignore){Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Licensing" | Remove-Item -Force -Recurse}
        If (Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -erroraction Ignore){Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" | Remove-Item -Force -Recurse}
        if (Get-Item  -Path "$env:LocalAppData\Microsoft\Office\Licenses" -errorAction Ignore){Get-Item  -Path "$env:LocalAppData\Microsoft\Office\Licenses" | Remove-Item -Force -Recurse}
        #Function Ends
        $procEndTime = Get-Date
        $procNetTime = $procEndTime - $procStartTime
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
        }
        New-Item -path "C:\Temp\" -Name "Backup_User_Data.ps1" -value $script -Force

        # Define the action (what the task will do)
        $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Minimized  -File C:\Temp\Backup_User_Data.ps1 -executionPolicy Bypass"
        # Define the trigger (when the task will run)
        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(10)

        # Define the task settings (run only when the user is logged on)
        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

        # Define the principal (current logged-on user context)
        $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

        $schedTaskName = "Backup_User_Data_Remove_User_Registrations"
        If (Get-Scheduledtask -TaskName $schedTaskName -ErrorAction SilentlyContinue){
            Unregister-ScheduledTask -TaskName $schedTaskName -Confirm:$False
        }
        
        # Register the task in the Task Scheduler
        Register-ScheduledTask -TaskName $schedTaskName  -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force
        While (!(Get-ScheduledTask -TaskName $schedTaskName -ErrorAction Ignore)){
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Waiting 1 minute for Scheduled Task to be Created and Available"
        }
        Start-ScheduledTask -TaskName $schedTaskName -Verbose | Out-Host

        $taskRunning = $false 
        while (!($taskRunning))
        {
            $currTime = Get-Date -format "HH:mm"
            $schedTaskInfo = Get-ScheduledTaskInfo -TaskName $schedTaskName | Select-Object -Property NextRunTime
            $now = Get-Date
            While($schedTaskInfo.NextRunTime -gt $now){
            $now = Get-Date -format "HH:mm"
            $schedTaskInfo = Get-ScheduledTaskInfo -TaskName $schedTaskName | Select-Object -Property NextRunTime
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Waiting for Scheduled Task to Run"
            }
            $taskRunning = $true
        }
        $taskFinished = $false
            while(!($taskFinished)){
            $scheduledTaskResult = Get-ScheduledTask -TaskName "Backup_User_Data_Remove_User_Registrations"
            If ($scheduledTaskResult.state -eq "Running"){
                Write-Output "[$($currTime)] | [$process] | [$procProcess] Waiting for Completion"
                Start-Sleep -Seconds 5
            }
            Else{
                Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed"
                $taskFinished = $true
            }
        }
        }
        else{$procStartTime = Get-Date 
            $currTime = Get-Date -format "HH:mm"
            $procProcess = "User Enrollment Data Cleanup - Run as User"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"
            $shareLoc = "$env:Temp"
            $dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
            $userTaskExportPath = $shareLoc+$dateTime+"."+$logFileName
            Start-Transcript -Path $userTaskExportPath
            $logFileName = "$($procProcess).txt"
            $chromeBookmarks = "$env:LocalAppData\Google\Chrome\User Data\Default\Bookmarks"
            $edgeBookmarks =  "$env:LocalAppData\Microsoft\Edge\User Data\Default\Bookmarks"
            if(!(Test-Path "C:\_Backup_AppData")){New-Item -Type Directory -Path "C:\_Backup_AppData\"}
            If (Test-Path $edgeBookmarks){Get-Item $edgeBookMarks | Copy-Item -Destination "C:\_Backup_AppData\$($($env:UserName).replace('.','-'))_edgeBookmarks" -Verbose -Force}
            if(Test-Path $chromeBookmarks){Get-Item $chromeBookmarks | Copy-Item -Destination "C:\_Backup_AppData\$($($env:UserName).replace('.','-'))_chromeBookMarks" -Verbose -Force}
            
            If (Get-Process -Name "OneDrive"){Stop-Process -Name "OneDrive" -Force}
            If (Get-Process -name  "Outlook"){Stop-Process -Name "Outlook" -Force}
            If (Get-Process -name "msteams"){Stop-Process -Name "MSTeams" -Force}
            
                
                #These are the functions that removes old user enrollment packages and old user accounts.
                $oldUserEnrollmentPackages = Get-Item -Path "$env:LocalAppData\Packages\Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore
                $currTime = Get-Date -format "HH:mm"
                Write-Output "[$($currTime)] | [$process] | [$procProcess] Removing Old User AAD Packages"
    
                while ($oldUserEnrollmentPackages)
                {
                $currTime = Get-Date -format "HH:mm"
                Write-Output "[$($currTime)] | [$process] | [$procProcess] Waiting for AAD Package Availability"
                    ForEach ($oldUserEnrollmentPackage in $oldUserEnrollmentPackages)
                    {
                        try{
                        Remove-Item -path $oldUserEnrollmentPackage -Force -Recurse -ErrorAction Stop
                        }
                        catch{
                            Start-Sleep -Seconds 5
                            Remove-Item -path $oldUserEnrollmentPackage -Force -Recurse -ErrorAction SilentlyContinue
                        }
    
                    }
                    $oldUserEnrollmentPackages = Get-Item -Path "$env:LocalAppData\Packages\Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore
                }
            If(Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"){Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"  | Remove-Item -Force -Recurse}
            If (Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Licensing" -erroraction Ignore){Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Licensing" | Remove-Item -Force -Recurse}
            If (Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -erroraction Ignore){Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" | Remove-Item -Force -Recurse}
            if (Get-Item  -Path "$env:LocalAppData\Microsoft\Office\Licenses" -errorAction Ignore){Get-Item  -Path "$env:LocalAppData\Microsoft\Office\Licenses" | Remove-Item -Force -Recurse}
            #Function Ends
            $procEndTime = Get-Date
            $procNetTime = $procEndTime - $procStartTime
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
    }
    }
    
    
    Catch
    {
        $errorDetails = $error[0] | Select-Object *
        $currTime = Get-Date -format "HH:mm"
        $errorLog += [PSCustomObject]@{
            processFailed                           = $procProcess
            timeToFail                              = $currTime
            reasonFailed                            = $errorDetails 
            failedTargetStandardName                = $computerinfo.CsName
            failedTargetSerialNumber                = $computerInfo.BiosSerialNumber
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
    }
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
                $errorDetails = $event| Select-Object *
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
    $errorExportPath = $shareLoc+$dateTime+"."+$errorLogCSV
    $errorLog | Export-CSV $errorExportPath
    Write-Output "`n`n`nThe Full Error Log is available as a csv at $errorExportPath`n"
    if ($Reboot){
        Write-Output "Restarting at: $(Get-Date)"
        Restart-Computer -Force
    }
    If ($Message){
        New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE -erroraction silentlycontinue | out-null
        $ProtocolHandler = get-item 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -erroraction 'silentlycontinue'
        if (!$ProtocolHandler) {
            New-Item 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -Force
            Set-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -Name '(DEFAULT)' -Value 'url:ToastReboot' -Force
            Set-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -Name 'URL Protocol' -Value '' -Force
            New-ItemProperty -Path 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -PropertyType Dword -Name 'EditFlags' -Value 2162688
            New-Item 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\Command' -Force
            Set-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\Command' -Name '(DEFAULT)' -Value 'pwsh.exe -Command "& {Restart-Computer -Force}" -windowstyle "Hidden"' -Force
        }
        
        
        $gitLogo = New-BTImage -Source 'C:\GIT_Scripts\GIT_Logos\GITLogo.png' -HeroImage
        $header = New-BTText -Content  "Message from GIT"
        $messageContent = New-BTText -Content "GIT has installed updates on your computer at $(get-date). Please click to reboot now."
        $rebootButton = New-BTButton -Content "Reboot now" -Arguments "ToastReboot:" -ActivationType Protocol
        $action = New-BTAction -Buttons $rebootButton
        $Binding = New-BTBinding -Children $header, $messageContent -HeroImage $gitLogo
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $action
        Submit-BTNotification -Content $Content
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






