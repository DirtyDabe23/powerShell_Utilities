function Add-Alias{
    <#
    .SYNOPSIS
    Adds or modifies an email alias for a specified user in Active Directory or via Microsoft Graph.
    .DESCRIPTION
    This function allows you to add or modify an email alias for a specified user in Active Directory or via Microsoft Graph.
    .Component
    ActiveDirectory, MicrosoftGraph
    .PARAMETER inputAlias
    The email alias to add or modify. Use "smtp:" for secondary aliases and "SMTP:" for primary aliases.
    .PARAMETER graphOrLocal
    Specify 'Graph' to modify the alias using Microsoft Graph or 'Local' to modify it in local Active Directory.
    .PARAMETER LocalADCred
    A PSCredential object for an account with permissions to modify users in local Active Directory.
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the user whose alias you want to modify.
    .EXAMPLE
    Add-Alias -inputAlias "smtp:e.User@exampleEmail.com" -graphOrLocal "Local" -LocalADCred $cred -UserPrincipalName "email.user@exampleEmail.com"
    .EXAMPLE
    Add-Alias -inputAlias "SMTP:Example.user@exampleEmail.com" -graphOrLocal "Graph" -UserPrincipalName "email.user@exampleEmail.com" 
    .NOTES
    Ensure you have the necessary permissions to modify user aliases in Active Directory or via Microsoft Graph.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-aduser
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/set-mgruser
    .Outputs
    Returns a PSCustomObject containing the alias and its type (Primary or Secondary).
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Alias to add. `nExample: smtp:exampleEmail@domain.com will set a secondary alias for that email address`n`
    Example: SMTP:exampleEmail@domain.com will the primary email address to said example email`nEnter",Mandatory = $true)]
    [string]$inputAlias,
    [Parameter(Position = 1, HelpMessage = "Enter 'Graph' to modify on Graph, 'Local' to Modify on Local",Mandatory = $true)]
    [string]$graphOrLocal,
    [Parameter(Position=2,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to create users",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$LocalADCred,
    [Parameter(Position=3,HelpMessage ="Enter the UserPrincipalName of the User to modify",Mandatory = $true)]
    [string]$UserPrincipalName
    )
    $currentAliases = Get-ADUSEr -Filter "UserPrincipalname -eq '$userPrincipalName'" -properties proxyAddresses | Select-Object -ExpandProperty proxyAddresses
    $returnAlias = @()
    $aliasType = $null
    switch ($inputAlias -clike "smtp:*") {
        ($true){$aliasType = "Secondary"}
        Default {$aliasType = "Primary"}
    }
    
    If ($inputAlias -in $currentAliases){
        Write-Output "`n`n$inputAlias is already applied"
        if ($inputAlias -cin $currentAliases){
            Write-Output "$aliasType Alias Already $inputAlias"
        }
        Else{
            Write-Output "$aliasType Alias needs set to $aliasType"
            switch ($graphOrLocal) {
                "Graph"{
                    $null
                }
                "Local"{
                    try{
                        Set-AdUser $usertoModify -remove @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                        Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                    }
                    catch{
                        try{
                            Set-AdUser $usertoModify -remove @{"proxyAddresses"="$($inputAlias)"} -Credential $LocalADCred -ErrorAction Stop
                            Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -Credential $LocalADCred -ErrorAction Stop
                        }
                        catch{
                            Throw $error[0]
                        }
                    }
                    }
                }
            }

            Write-Output "$aliasType Alias now $inputAlias"
        }
    Else{
        Write-Output "Alias $inputAlias Type $aliasType does not exist, adding"
        switch ($graphOrLocal){
            'Graph'{ 
                $null
            }
            'Local'{
                try{
                Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                }
                catch{
                    try{
                    Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -Credential $LocalADCred -ErrorAction Stop
                    }
                    catch{
                        Throw $error[0]
                    }

                }
            }
            }
        }
        $returnAlias += [PSCustomObject]@{
            alias       =   $inputAlias
            aliasType   =   $aliasType
        }
        return $returnAlias
}
function Clear-Enrollment{
    <#
    .SYNOPSIS
    Clears all MDM Enrollment Data from a Windows 10/11 Device, including Intune and Office 365 Data
    .DESCRIPTION
    Clears all MDM Enrollment Data from a Windows 10/11 Device, including Intune and Office 365 Data
    .COMPONENT
    Endpoint , Intune, Office365
    .PARAMETER ComputerName
    The name of the computer to clear the enrollment data from. If not specified, the local computer is used.
    .PARAMETER InTune
    Clears Intune Enrollment Data from the device.
    .PARAMETER OfficeApps
    Clears Office 365 Application Data from the device.
    .EXAMPLE
    Clear-Enrollment -InTune
    Clears Intune Enrollment Data from the local computer.
    .EXAMPLE
    Clear-Enrollment -OfficeApps
    Clears Office 365 Application Data from the local computer.
    .NOTES
    As this is an supported process in the event of failure you will need to wipe and reload the device, or remove the user's profile and re-profile.
    .LINK
    https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-windows
    .Outputs
    Transcript Log in the Temp Directory of the user running the script.    
    #>
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
            ForEach ($errorEvent in $error)
            {
                $errorDetails = $errorEvent| Select-Object *
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
function Format-Name {
    <#
    .SYNOPSIS
        Formats a given name to have the first letter capitalized and the rest in lowercase.
    .DESCRIPTION
        This function takes a string input representing a name and formats it such that the first letter of
        each part of the name is capitalized, and the remaining letters are in lowercase. It handles names with spaces,
        hyphenated names, and single-part names.    
    .COMPONENT
        Formatting Functions
    .PARAMETER inputName
    The name to be formatted.
    .EXAMPLE
        Format-Name -inputName "john doe"
        Output: "John Doe"
    .NOTES 
        This function is useful for standardizing name formats in user data.
    .OUTPUTS
        A formatted string with proper capitalization.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, HelpMessage = "Enter the Input Name to Format", Mandatory = $true)]
        [string]$inputName
    )
    # Trim leading and trailing spaces
    $inputName = $inputName.Trim()
    $inputNameFormatted = $null

    # Handle names with spaces
    if ($inputName -match " ") {
        $splitInputName = $inputName.Split(" ") | Where-Object { $_ -ne "" } # Remove empty strings caused by extra spaces
        $runningStringPre = $null
        foreach ($splitName in $splitInputName) {
            # Format each part of the name
            if ($splitName.Length -gt 1) {
                $formattedString = $splitName.Substring(0, 1).ToUpper() + $splitName.Substring(1).ToLower()
            } else {
                $formattedString = $splitName.ToUpper() # Handle single-character cases
            }

            # Combine formatted strings
            if ($null -ne $runningStringPre) {
                $runningStringPre = $runningStringPre + " " + $formattedString
            } else {
                $runningStringPre = $formattedString
            }
        }
        $runningStringPost = $runningStringPre
        return $runningStringPost
    }
    # Handle hyphenated names
    if ($inputName -match "-") {
        $splitInputName = $inputName.Split("-")
        if ($splitInputName.Count -eq 2) {
            $formattedString = $splitInputName[0].Substring(0, 1).ToUpper() + $splitInputName[0].Substring(1).ToLower() + "-" +
                               $splitInputName[1].Substring(0, 1).ToUpper() + $splitInputName[1].Substring(1).ToLower()
            return $formattedString
        } else {
            Write-Error "Hyphenated name format is invalid."
        }
    }
    # Handle single-part names
    if ($inputName.Length -gt 1) {
        $inputNameFormatted = $inputName.Substring(0, 1).ToUpper() + $inputName.Substring(1).ToLower()
    } else {
        $inputNameFormatted = $inputName.ToUpper() # Handle single-character names
    }
    return $inputNameFormatted
}
function Get-AssignedJiraIssues {
    <#
    .SYNOPSIS
        Retrieves the issues assigned to the current user in Jira.
    .DESCRIPTION
        This function connects to Jira and retrieves the issues assigned to the current user.
        It uses the Jira REST API to fetch the data and returns it in a structured format.
    .COMPONENT
        Jira
    .PARAMETER JiraOrg
        The organization name for the Jira instance. Defaults to 'parentCompany'.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-AssignedJiraIssues -jiraOrg 'parentCompany' -jiraUser 'david.drosdick@Domain.extension1' -jiraKey $jiraKey -jiraAssignee "David.Drosdick@Domain.extension1"
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
        The output will be a list of tickets assigned to the user
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    JSON formatted data from the Jira API containing the issues assigned to the user.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$jiraOrg = 'parentCompany',
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2,Mandatory = $false,HelpMessage = "The assignee for the Jira issues. Defaults to the current user's username and domain.")]
        [string]$jiraAssignee = ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [parameter(Position = 3, Mandatory = $true, HelpMessage = "The Jira Project to Retrieve.")]
        [string]$jiraProject,
        [Parameter(Mandatory = $false, HelpMessage = "Output type: Filtered or Full. Defaults to Filtered")]
        [PSDefaultValue(Help="Filtered", Value='Filtered')]
        [ValidateSet('Filtered','Full', IgnoreCase = $true)]
        [string]$outputType = 'Filtered'
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $jql = "$jiraAssignee"
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $userURI = "https://$jiraOrg.atlassian.net/rest/api/3/user/search?query=$encodedJQL"
    try {
        $userResponse = Invoke-RestMethod -Uri $userURI -Method Get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    if ($userResponse -and $userResponse.Count -gt 0) {
        $userId = $userResponse[0].accountId
    } else {
        throw "No user found with the specified username: $jiraAssignee"
    }
    $jql = "assignee = ","$userID",' AND PROJECT IN ',"($jiraProject)",' AND Resolution = Empty ORDER BY created asc' -join ''
    #This encodes the JQL query to be used in the API call.
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $uri = 'https://',$jiraOrg,'.atlassian.net/rest/api/3/search/jql?jql=',$encodedJQL -join ''
    try{
        $jiraResponse = Invoke-RestMethod -uri $uri -method get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    $ticketsAssigned = @()
    if ($jiraResponse.issues) {
        $jiraTickets = $jiraResponse.Issues.ID
        ForEach ($jiraTicket in $jiraTickets){
            $ticketsAssigned += Get-JiraTicket -jiraUser $jiraUser -jiraKey $jiraKey -jiraTicket $jiraTicket -outputType $outputType
        }
            return $ticketsAssigned
        }
    else {
        return "No issues found for the specified assignee."
    }
}
function Get-CompliantDepartments {
    <#
    .SYNOPSIS
        Retrieves and formats the list of compliant departments from a custom field in Jira.
    .DESCRIPTION
        This function connects to Jira, retrieves the values of the custom field "Office Location and Department
    .COMPONENT
        Jira, EntraID
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-CompliantDepartments -jiraUser $jiraUser -jiraKey $jiraKey
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to
        access the Jira instance.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A formatted list of compliant departments with their associated locations.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The Jira user to authenticate with.")]
        [string]$jiraUser,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "The Jira API key to use for authentication.")]
        [string]$jiraKey
    )
    $unformattedList = Get-CustomFieldValues -customFieldName "Office Location and Department" -jiraUser $jiraUser -jiraKey $jiraKey
    $formattedList = @()
    $locationIDs = $unformattedlist.optionID | Select-Object -Unique     
    ForEAch ($locationID in $locationIDs){
        $locationName = ($unformattedlist | Where-Object {($_.ID -eq $locationID)}).Value
        $Departments = ($unformattedlist | Where-Object {($_.optionID -eq $locationID)}).Value
        ForEAch ($department in $departments){
            $formattedList += [PSCustomObject]@{
                LocationName    = $locationName
                Department      = $department
            }
        }
    }
    return $formattedList
}
function Get-CustomField{
    <#
    .SYNOPSIS
        Retrieves information about a specific custom field in Jira.
    .DESCRIPTION
        This function connects to Jira and retrieves information about a specified custom field by its name.
    .COMPONENT
        Jira
    .PARAMETER customFieldName
        The name of the custom field to retrieve information about.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-CustomField -customFieldName "Office Location and Department" -jiraUser $jiraUser -jiraKey $jiraKey
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A custom field object from Jira containing details about the specified custom field.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Customfield Name to Pull from Jira",Mandatory = $true)]
    [string]$customFieldName,
    [Parameter(Position = 1,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
    [Parameter(Position = 2, HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey
    )


#This creates the Jira header for authorization into the API and to return the data in JSON format.
$jiraText = "$jiraUser",":","$jiraKey" -join ""
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $jiraHeader
$foundField = $fields | Where-Object {($_.Name -like "$customfieldName")}
if($foundField){
    return $foundField
}
else{
    Write-Output "Field Not Found"
}
}
function Get-CustomFieldValues{
    <#
    .Synopsis
        Retrieves the values of a specific custom field in Jira.
    .DESCRIPTION
    This function connects to Jira and retrieves the values of a specified custom field by its name.
    .COMPONENT
        Jira
    .PARAMETER customFieldName
        The name of the custom field to retrieve values from.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-CustomFieldValues -customFieldName "Office Location and Department" -jiraUser $jiraUser -jiraKey $jiraKey
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to
        access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A list of values associated with the specified custom field in Jira.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Customfield Name to Pull from Jira", Mandatory=$true)]
    [string]$customFieldName,
    [Parameter(Position = 1,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.Tolower() -join ""),
    [Parameter(Position = 2, HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey
    )
    
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }

        $Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $jiraHeader
        $foundField = $fields | Where-Object {($_.Name -eq $customFieldName)}


    If ($null -ne $foundField)
    {
        $reviewingField = $fields | Where-Object {($_.Name -eq $customFieldName)}

        $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $jiraHeader


        $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $jiraHeader

        $reviewedFieldValues = @()

        If ($reviewingFieldValues.Total -ge 100)
        {
            $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

            for ($count = 0; $count -lt $reviewingFieldValues.Total; $count += 100) 
            {
                $uri = $uriTemplate -f $count
                $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $jiraHeader
                ForEach ($fieldValue in $fieldValues.values)
                {
                    $reviewedFieldValues += [PSCustomObject]@{
                        FieldName   = $customFieldName
                        ID          = $fieldValue.ID
                        Value       = $fieldValue.Value
                        OptionID    = $fieldValue.optionID
                        Disabled    = $fieldValue.Disabled
                    }
                }
            }

        }
        else 
        {
            $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option"
            $fieldValues = Invoke-RestMethod -Method Get -Uri $uriTemplate -Headers $jiraHeader
            ForEach ($fieldValue in $fieldValues.values)
                {
                    $reviewedFieldValues+= [PSCustomObject]@{
                        FieldName   = $customFieldName
                        ID          = $fieldValue.ID
                        Value       = $fieldValue.Value
                        OptionID    = $fieldValue.optionID
                        Disabled    = $fieldValue.Disabled
                    }
                }
        }
    return $reviewedFieldValues    
    }
    else
    {
        Write-Output "Field Name not found"
    }
}
function Get-CimProgram {
    <#
    .SYNOPSIS
    Uninstalls a specified CIM program.
    .DESCRIPTION
    This function uninstalls a CIM program by its name using the Win32_Product class.
    .COMPONENT
    Endpoint
    .PARAMETER CimProgramName
    The name of the CIM program to uninstall.
    .EXAMPLE
    Uninstall-CimProgram -CimProgramName "Example CIM Program"
    Uninstalls the specified CIM program.
    .NOTES
    You must have administrative privileges to run this function and said account must be able to authenticate to the target machine.
    .OUTPUTS
    None. This function performs an uninstallation and does not return any output.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,HelpMessage = "The name of the CIM program to retrieve, defaults to all programs.",Position = 0)]
        [string]$CimProgramName = "*"
    )
    $cimPrograms = @()
    if($CimProgramName -eq "*") {
        $cimPrograms = Get-CimInstance -ClassName Win32_Product
    } else {
        $CimProgramName = "*$CimProgramName*"
        Get-CimInstance -ClassName Win32_Product -Filter "Name LIKE '$CimProgramName'" | ForEach-Object {
            $cimPrograms += $_
        }
    }
    if ($cimPrograms.Count -eq 0) {
        Write-Host "No CIM programs found matching the specified name." -ForegroundColor Yellow
        throw "Failed to find any CIM programs matching the specified name."
    }
    else{
        return $cimPrograms
    }
}
function Get-Device42Devices {
    <#
        .SYNOPSIS
            Get Device42 devices from the API.
        .DESCRIPTION
            This function retrieves devices from the Device42 API and returns them as a PowerShell object.
        .COMPONENT
            Device42
        .PARAMETER Device42URL
            The URL of the Device42 API.
        .PARAMETER APIToken
            The API token for authentication with the Device42 API.
        .PARAMETER Device42Username
            The username for authentication with the Device42 API.
        .EXAMPLE
            Get-Device42Devices -Device42URL "itam.company.com" -APIToken "your_api_token" -Device42Username "admin-user@company.com"
        .NOTES
            This function requires the Device42 API token and username for authentication.
        .OUTPUTS
            A PowerShell object containing the devices retrieved from the Device42 API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Device42 URL`nExample: itam.company.com")]
        [string]$device42url,
        [Parameter(Mandatory = $true)]
        [string]$APIToken,
        [Parameter(Mandatory = $true, HelpMessage = "The User Name to use for authentication`nExample: D42_API")]
        [string]$device42Username
    )
    $useFilter = "?include_cols="
    $properties = "name , customer , total_cpus ,core_per_cpu ,threads_per_core ,cpu_speed , ram ,ram_size_type ,os_name , os_version"
    $encodedProperties = [uri]::EscapeDataString($properties)
    $constructedFilter = $useFilter , $encodedProperties -join ""



    $apiuri ="https://$($device42url)/api/2.0/devices/",$constructedFilter -join ""
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$($device42Username):$($APIToken)")))
    $device42Header = @{
        "Authorization" = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    }
    $device42Devices = (invoke-restmethod -uri $apiuri -Method Get -Headers $device42Header -ErrorAction Stop).devices
    if ($null -eq $device42Devices) {
        Write-Error "No devices found in Device42."
        return
    }
    return $device42Devices
}
function Get-Device42Win10Readiness{
    <#
    .SYNOPSIS
        This script audits Device42 devices for compatibility with Windows 11 and Intune membership.
    .DESCRIPTION
        The script retrieves devices from Device42, checks their compatibility with Windows 11 based on RAM and CPU specifications,
        and verifies their Intune membership status. It returns a sorted list of devices with their compatibility status and reasons for incompatibility.
    .COMPONENT
        Device42, Intune
    .PARAMETER d42ApiToken
    The API token for Device42.
    .PARAMETER d42Username
    The username for Device42.
    .EXAMPLE
        Get-Device42Win10Readiness -d42ApiToken "your_device42_api_token" -d42Username "your_device42_username"
    .OUTPUTS
        A sorted list of devices with their compatibility status, Intune membership status, primary user information, and reasons for incompatibility if applicable.
    .NOTES 
    1. Retrieves devices from Device42 that are running Windows 10 and do not have
        the specified OS version.
    2. Checks each device's RAM and CPU specifications to determine Windows 11 compatibility.
    3. Verifies if each device is managed by Intune.
    4. Returns a sorted list of devices with their compatibility status, Intune membership status
        primary user information, and reasons for incompatibility if applicable.
    5. Sorts the output by compatibility status, Intune membership status, office location, and device name.
    6. Outputs the final list of devices.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Mandatory = $true,HelpMessage = "Device42 API Token",Position = 1)]
    [string]$d42ApiToken
    )
    $allDevices = Get-Device42Devices -Device42url 'itam.Domain.extension1' -APIToken $d42ApiToken -Device42Username 'GIT_API'
    $d42Devices = $allDevices | where-object {($_.os_name -like "Microsoft Windows 10*") -and ($_.os_version -notlike "*26100*")}
    $inTuneDevices = Get-InTuneWindowsManagedDevices
    $d42DevicesNewNames = @()
    ForEach ($d42Device in $d42Devices)
    {
        $searchName             = $null 
        $compatbility           = $null
        $incompatbilityReason   = $null 
        if ($d42Device.Name -like "*.*"){
            $searchName = $d42device.name.split(".")[0]

        }
        else{
            $searchName = $d42device.name
        }
        if ($searchName -notin $intuneDevices.devicedisplayname){
            $inTuneStatus = "Not MDM Managed"
        }
        else{
            $inTuneStatus = "MDM Managed"
            $intuneDevice = $intuneDevices | where-object {$_.devicedisplayname -eq $searchName}
        }
        if ($d42device.RAM -le "4"){
            $incompatbilityReason       = "Not Compatible: Insufficient RAM"
        }
        if($d42device.cpu_speed -lt "1.0" -or $d42device.core_per_cpu -lt "2"){
            if ($null -ne $incompatbilityReason){
                $incompatbilityReason += "`nNot Compatible: Insufficient CPU"
            }
            else{
                $incompatbilityReason = "Not Compatible: Insufficient CPU"
            }
        }
        if ($null -eq $incompatbilityReason){
            $compatbility = "Compatible"
            $incompatbilityReason = "N/A"
        }
        else{
            $compatbility = "Not Compatible"
        }
        $d42DevicesNewNames +=[PSCustomObject]@{
        d42DeviceName       = $searchName
        OfficeLocation      = $d42device.Customer
        intuneStatus        = $inTuneStatus
        primaryUser         = $intuneDevice.devicePrimaryUser
        primaryUserEmail    = $intuneDevice.userPrincipalName
        shopOrOffice        = $intuneDevice.devicePrimaryUserShoporOffice
        win11Ready          = $compatbility
        incompabilityReason = $incompatbilityReason
        cpuCount            = $d42device.total_cpus
        cpuCoreCount        = $d42device.core_per_cpu
        threadPerCore       = $d42device.threads_per_core
        cpuSpeed            = $d42device.cpu_speed
        RAMSize             = $d42device.ram
        RAMUnit             = $d42device.ram_size_type   
        osName              = $d42device.os_name
        osVersion           = $d42device.os_version
        } 
    }
    $d42InTuneWin11Ready = $d42DevicesNewNames | Sort-Object -Property @{expression = "compatbility"; descending = $false}, @{expression = "intuneStatus"; descending = $false}, @{expression = "OfficeLocation"}, @{expression = "d42DeviceName"; descending = $false}
    return $d42InTuneWin11Ready
} 
function Get-parentCompanyUser{
    <#
    .SYNOPSIS
    This function will allow you to search a local domain, graph, or both, for the user information.
    .DESCRIPTION
    This function will allow you to search a local domain, graph, or both, for the user information.
    .COMPONENT
    EntraID, ActiveDirectory
    .PARAMETER UserPrincipalName
    The user's UserPrincipalName
    Example: TestUser.LastName@Domain.extension1
    .PARAMETER Graph
    Requires runnning Connect-MgGraph and the permissions for User.Read.All
    It will search the graph tenant by UPN to look for the user.
    .PARAMETER LocalAD
    Requires a connection to a local domain, and for the current executing user to have permissions used to review the user as they exist on the specified domain controller.
    It will search the entire Active Directory Structure for a user with the UserPrincipalName matching the input.
    .PARAMETER Full
    The default. 
    Requires runnning Connect-MgGraph and the permissions for User.Read.All
    Requires a connection to a local domain, used to review the user as they exist on the specified domain controller.
    It will search the entire Active Directory Structure of the specificede Domain and the Current Graph Tenant for a user with the UserPrincipalName matching the input.
    .PARAMETER Domain
    Specify the Domain / Server to connect to. Usually it's the ending of the user's UPN.
    Example: Domain.extension1
    .PARAMETER Credential
    Enter the credential for authentication to the local domain.
    .EXAMPLE 
    #Get the User Data from the Local Domain 'Domain.extension1' and from Graph
    Get-parentCompanyUser -UserPrincipalName "David.Drosdick@Domain.extension1" -Full -Domain "Domain.extension1"
    .EXAMPLE
    #Get the User Data from Graph
    Get-parentCompanyUser -UserPrincipalName "David.Drosdick@Domain.extension1" -Graph
    .EXAMPLE 
    #Get the User Data from the Local Domain 'Domain.extension1'
    Get-parentCompanyUser -UserPrincipalName "David.Drosdick@Domain.extension1" -LocalAD -Domain "Domain.extension1"
    .NOTES
    This is largely just for learning how to write a module!
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser
    .OUTPUTS
    A user object from either Graph, Local AD, or both depending on the parameter set used
    #>
    [CmdletBinding(DefaultParameterSetName = 'Full')] 
    param(
        #This Parameter is available to all sets
        [Parameter(Mandatory = $True,Position = 0,HelpMessage = "Enter a UPN for the user, `nExample: TestUser.TestLast@Domain.extension1",ValueFromPipelineByPropertyName)]
        [ValidatePattern( "[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?")]
        [string]$UserPrincipalName,
        #This Parameter is available only the the Graph Set
        [Parameter(ParameterSetName = 'Graph',Position = 1,Mandatory)]
        [switch]$Graph,
        #This Parameter is available only to the Domain Set
        [Parameter(ParameterSetName = 'Domain',Position = 1,Mandatory)]
        [switch]$LocalAD,
        [Parameter(ParameterSetName = 'Full', Position = 1)]
        [switch]$Full,
        #These Parameters are only available to the All and Domain Set
        [Parameter(ParameterSetName = 'Full',Mandatory = $True, Position = 2,HelpMessage = "Enter Domain to Check.`nExample:Domain.extension1")]
        [Parameter(ParameterSetName = 'Domain',Mandatory = $True, Position = 2,HelpMessage = "Enter Domain to Check.`nExample:Domain.extension1")]
        [string]$Domain,
        [Parameter(ParameterSetName = 'Full',Mandatory = $True, Position = 3,HelpMessage = "Enter credentials to authenticate to the local domain.",ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'Domain',Mandatory = $True, Position = 3,HelpMessage = "Enter credentials to authenticate to the local domain.",ValueFromPipelineByPropertyName)]
        [System.Management.Automation.Credential()]
        [PSCredential]$Credential
    )
    $userObject = @()
    switch ($PSCmdlet.ParameterSetName){
        'Graph' {
            $user = Get-MgUser -userid $UserPrincipalName | Select-Object *
            $userObject = $user
        }
        'LocalAD'{
            $user = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -Server $Domain -Credential $Credential -erroraction SilentlyContinue
            $userObject = $user 
        }
        'Full'{
            $localUser = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -Server $Domain -Credential $Credential -erroraction SilentlyContinue
            $graphUser = Get-MgUser -userid $UserPrincipalName | Select-Object *
            $userObject = [PSCustomObject]@{
                localUserData       = $localUser
                cloudUserData       = $graphUser
            }
        }
    }
    return $userObject
}
function Get-parentCompanyUserDevices{
    <#
    .SYNOPSIS
    This function retrieves all of the user's owned devices and prints them in an easy to read manner.
    .DESCRIPTION
    This function
    .COMPONENT
    EntraID, Intune
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the Primary User to remove from Devices. It pulls based off InTune and returns all devices where they are listed as the primary user.
    .EXAMPLE
    Get-parentCompanyUserDevices -UserPrincipalName $userUPN 
    .NOTES
    You need to start with Connect-MgGraph, and then you will need to have the permissions required.
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    .OUTPUTS
    A list of devices assigned to the user with their details.
    #>
    [CmdletBinding()] 
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the User Principal Name for the Device to Remove",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$UserPrincipalName
    )
    #This removes all the devices assigned to the user
    try{ 
    $devices = Get-MGBetaUserOwnedDevice -UserId $UserPrincipalName -ErrorAction SilentlyContinue
    }
    catch{
        Write-Output "Failed to Retrieve: $UserPrincipalName, please try again"
        continue
    }
    $tracking = @()
    If ($devices){ 
        ForEach($device in $devices){
            $deviceData = $device | Select-Object -Property AdditionalProperties -ExpandProperty AdditionalProperties | ConvertTo-Json -Depth 10 | ConvertFrom-Json -Depth 10
            $tracking += [PSCustomObject]@{
                deviceUser          =   $UserPrincipalName
                deviceDisplayName   =   $deviceData.displayName
                created             =   $deviceData.createdDateTime
                enrollment          =   $deviceData.enrollmentType
                trustType           =   $deviceData.trustType
                management          =   $deviceData.managementType
                manufacturer        =   $deviceData.manufacturer
                model               =   $deviceData.model
                OS                  =   $deviceData.operatingSystem
                OSVersion           =   $deviceData.operatingSystemVersion
                
            }
        }
        return $tracking
        
    }
    Else{
        return "$UserPrincipalName has no devices assigned!"
    }
}
function Get-InTuneWindowsManagedDevices{
    <#
    .SYNOPSIS
    This module pulls all of the Windows Managed Devices from InTune.
    .DESCRIPTION
    This module pulls all of the Windows Managed Devices from InTune. It does not support any parameters, it simply returns all devices, their DisplayName, 
    Operating System, ID, DeviceID, Location, Department, and Primary User, and Primary User Email
    .COMPONENT
    EntraID, Intune
    .EXAMPLE
    Get-InTuneWindowsManagedDevices
    .NOTES
    General notes
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    .OUTPUTS
    A list of all Windows Managed Devices in InTune with their details.
    #>
    $allDevices = Get-MgBetaDevice -All -ConsistencyLevel eventual -Property * | Select-Object -Property *
    $windowsManagedDevices = $allDevices| where-object {($_.ManagementType -eq 'MDM') -and ($_.OperatingSystem -eq 'Windows')}
    $deviceDetails = @()
    forEach ($managedDevice in $windowsManagedDevices){
        $deviceOwner = Get-MgDeviceRegisteredUser -DeviceId $managedDevice.Id -Property * | Select-Object -Property additionalproperties -ExpandProperty AdditionalProperties
        if ($null -ne $deviceOwner.userPrincipalName){
            $deviceOwnerDetails = Get-MgBetaUser -userid $deviceOwner.userPrincipalName
        } 
        $shopOrOffice = $null
        if ($null -ne $deviceOwnerDetails.OnPremisesExtensionATtributes.ExtensionAttribute1){
            [string]$shopOrOffice = $deviceOwnerDetails.OnPremisesExtensionAttributes.ExtensionAttribute1
        }
        else{
            $shopOrOffice = "Not Found"
        }
        $OSVersion = $managedDevice.operatingSystemVersion
        if ($OSVersion -like "10.0.1*"){
            $OSVersion = "Windows 10"
        }
        else{
            $OSVersion = "Windows 11"
        }
        if($null -eq $deviceOwner){
            $deviceDepartment   = "No listed department"
            $deviceLocation     = "No listed location"
            $deviceOwner        = "No listed owner"
            $deviceOwnerEmail   = "No listed owner" 
        }
        else{
            $deviceDepartment   = $deviceOwnerDetails.department
            $deviceLocation     = $deviceOwnerDetails.officeLocation
            $deviceOwner        = $deviceOwnerDetails.displayName
            $deviceOwnerEmail   = $deviceOwnerDetails.userPrincipalName 
        }
        $deviceDetails += [PSCustomObject]@{
            deviceDisplayName               =   $managedDevice.DisplayName
            deviceOperatingSystem           =   $OSVersion
            deviceID                        =   $managedDevice.Id
            deviceDeviceID                  =   $managedDevice.DeviceId
            deviceLocation                  =   $deviceLocation
            deviceDepartment                =   $deviceDepartment
            devicePrimaryUser               =   $deviceOwner
            devicePrimaryUserEmail          =   $deviceOwnerEmail
            devicePrimaryUserShoporOffice   =   $shopOrOffice
        }
    }
    $sortedDetails = $deviceDetails | sort-object -property @{expression="deviceOperatingSystem"; asc=$true},@{Expression = "deviceLocation";Descending =$true}, @{expression="deviceDisplayName"; asc=$true}
    return $sortedDetails
}
function Get-InTuneApp {
    <#
    .SYNOPSIS
    Retrieves the Intune application details for a specific app.

    .DESCRIPTION
    This function retrieves the details of an Intune application based on the provided app ID.
    
    .PARAMETER AppId
    The ID of the application to retrieve.

    .EXAMPLE
    Get-InTuneApp -AppId "12345678-1234-1234-1234-123456789012"
    
    Retrieves the details of the specified Intune application.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppId
    )

    $uri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$AppId"
    
    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get
        return $response
    } 
    catch {
        Write-Error "Failed to retrieve app details: $_"
        return $null
    }
}
function Get-InTuneAppByDisplayName {
    <#
    .SYNOPSIS
    Retrieves the Intune application details for a specific app by its display name.

    .DESCRIPTION
    This function retrieves the details of an Intune application based on the provided display name.

    .PARAMETER DisplayName
    The display name of the application to retrieve. PLEASE NOTE, IT IS CASE SENSITIVE.

    .EXAMPLE
    Get-InTuneAppByDisplayName -DisplayName "parentCompany PowerShell Module: parentCompanyModule"

    Retrieves the details of the specified Intune application.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    $uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?`$filter=startsWith(DisplayName,'", "$DisplayName", "')" -join ""

    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get
        return $response
    } catch {
        Write-Error "Failed to retrieve app details: $_"
        return $null
    }
}

function Get-JiraTicket{
    <#
    .SYNOPSIS
    This function retrieves Jira tickets based on the provided parameters and returns their details.
    .DESCRIPTION
    This function connects to a Jira instance using the provided credentials and retrieves tickets based on the specified parameters. It returns a list of ticket details including key, summary, status, and assignee.
    .COMPONENT
    Jira
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It defaults to the current user's username and domain.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER jiraTicket
    The Jira ticket key to retrieve details for. Example: "GHD-1234".
    .PARAMETER ouputType
    To what degree of detail you want the returned object to provide. The default is filtered, which returns a limited set of properties.
    .EXAMPLE
    Get-JiraTicket -jiraKey $jiraKey -jiraTicket "GHD-1234"
    Retrieves the details of the Jira ticket with key "GHD-1234" using the provided API key.
    .NOTES
    This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
    The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A list of Jira ticket details including key, summary, status, and assignee.
    #>
    [CmdletBinding()]
    param(
        
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2,HelpMessage = "The Jira Ticket, Example: GHD-1234 ")]
        [string]$jiraTicket,
        [Parameter(Mandatory = $false, HelpMessage = "Output type: Filtered or Full. Defaults to Filtered")]
        [PSDefaultValue(Help="Filtered", Value='Filtered')]
        [ValidateSet('Filtered','Full', IgnoreCase = $true)]
        [string]$outputType = 'Filtered'
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    try{
        $Form = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket" -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
         if ($outputType -eq 'Filtered'){
                $filteredOutput += [PSCustomObject]@{
                    Reporter        = $form.fields.reporter.displayName
                    ReporterEmail   = $form.fields.reporter.emailAddress
                    Key             = $form.key
                    Summary         = $form.fields.summary
                    Description     = $form.fields.Description
                    Status          = $form.fields.status.name
                    Created         = $form.fields.created
                    Updated         = $form.fields.updated
                    Priority        = $form.fields.priority.name
                    IssueType       = $form.fields.issuetype.name
                }
            return $filteredOutput  
        }
        return $Form
    }
    catch{
        Write-Error "Failed to connect to Jira API. Please check your credentials and network connection."
        throw $error[0] | select-object -Property *
    }
}
function Get-JiraRequiredFields {
    <#
    .SYNOPSIS
    Creates a new Jira ticket in the specified project.
    .DESCRIPTION
    This function creates a new Jira ticket in the specified project using the Jira API.
    It retrieves the required fields for the specified issue type and project, ensuring that all necessary information is provided before creating the ticket.
    .COMPONENT
    Jira, PowerShell
    .PARAMETER jiraOrg
    The Jira organization name. Defaults to 'parentCompany'.
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER jiraAssignee
    The UPN of the user to assign the ticket to. Defaults to the current user's username and domain.
    .PARAMETER jiraProject
    The Jira project to retrieve.
    .PARAMETER jiraIssueType
    The Jira issue type to retrieve. Defaults to "Task".
    .EXAMPLE
    Get-JiraRequiredFields -jiraProject "GHD" -jiraIssueType "Task
    Retrieves the required fields for creating a Jira ticket in the "GHD" project with the issue type "Task".
    .EXAMPLE
    Get-JiraRequiredFields -jiraProject "GHD" -jiraIssueType "Bug"
    Retrieves the required fields for creating a Jira ticket in the "GHD" project with the issue type "Bug".
    .NOTES
    This function is used to retrieve the required fields for creating a Jira ticket in a specific project and issue type.
    It ensures that all necessary information is provided before creating the ticket, preventing errors during ticket creation.
    The function checks if the specified project and issue type exist, and if the  issue type is available for the project.
    If the project or issue type does not exist, it throws an error with a list of available options.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function returns a collection of required fields for creating a Jira ticket in the specified project and issue type.
    Each field object contains properties such as 'name', 'key', and 'allowedValues', which describe the field and its requirements.
    If the operation is successful, it will return the required fields in JSON format. If there is an issue with the Jira API connection or the project or issue type, it will throw an error.
    If no required fields are found for the specified issue type, it will throw an error indicating that no required fields were found.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Mandatory = $false)]
    [string]$jiraOrg = 'parentCompany',
    [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
    [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
    [string]$jiraKey,
    [Parameter(Position = 2,Mandatory = $false,HelpMessage = "The assignee for the Jira issues. Defaults to the current user's username and domain.")]
    [string]$jiraAssignee = ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
    [parameter(Position = 3, Mandatory = $true, HelpMessage = "The Jira Project to Retrieve.")]
    [string]$jiraProject,
    [Parameter(Position = 4, Mandatory = $false, HelpMessage = "The Jira Issue Type to Retrieve.")]
    [string]$jiraIssueType = "Task"
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $projects = (invoke-restmethod -uri "https://parentCompany.atlassian.net/rest/api/3/project/search" -Headers $jiraHeader -method Get).values.key
    if ($projects -notcontains $jiraProject) {
        throw "The specified project '$jiraProject' does not exist or is not accessible."
    }
    $projectIssueMetaData = invoke-restmethod -uri "https://parentCompany.atlassian.net/rest/api/3/issue/createmeta/$jiraProject/issuetypes" -Headers $jiraHeader -Method Get
    $availableIssueTypes = $projectIssueMetaData.IssueTypes | select-object -Property ID , Name 
    if ($availableIssueTypes.Name -notcontains $jiraIssueType) {
        throw "The specified issue type '$jiraIssueType' is not available for the project '$jiraProject'. Available issue types are:`n$($availableIssueTypes.Name -join "`n")"
    }
    $issueTypeID = ($availableIssueTypes | Where-Object {($_.Name -eq $jiraIssueType)}).ID
    $createIssueMetaData = invoke-restmethod -uri "https://parentCompany.atlassian.net/rest/api/3/issue/createmeta/$jiraProject/issuetypes/$issueTypeID" -Headers $jiraHeader -Method Get
    $requirements = $createIssueMetaData.Fields | Where-Object {($_.required -eq $true)} | select-object -property  name , key , allowedValues 
    if ($requirements.Count -eq 0) {
        throw "No required fields found for the specified issue type '$jiraIssueType' in project '$jiraProject'."
    }
    else{
        return $requirements
    }
}
function Get-JiraTransition{
    <#
    .SYNOPSIS
    #This function will return all the transitions available for a given Jira ticket.
    .DESCRIPTION
    This function will return all the transitions available for a given Jira ticket. It does so by going to the Jira API and retrieving the available transitions. 
    After the data is returned, specifically review the 'to' property of the transition object. This will give you the available transitions for the ticket.
    .COMPONENT
    Jira, PowerShell
    .PARAMETER jiraTicket
    Enter the Jira Ticket Key to retrieve transitions for. This is a mandatory parameter.
    .PARAMETER jiraUser
    Enter the username of the account that is being used to connect to Jira via the API.
    It will default to your UserName and UserDNSDomain.
    .PARAMETER jiraKey
    Enter your API Key for Jira. This is a mandatory parameter.
    .PARAMETER jiraOrg
    Enter the Jira URL-PREFIX. This is a mandatory parameter. Example: yourcompany for yourcompany.atlassian.net.
    .EXAMPLE
    Get-JiraTransition -jiraTicket "GHD-53697" -jiraUser $jiraUser -jiraKey $jiraRetrSecret -jiraOrg "parentCompany"
    Retrieves all transitions available for the Jira ticket "GHD-53697" using the provided Jira user and API key.
    .EXAMPLE
    Get-JiraTransition -jiraTicket "GHD-53697" -jiraKey $jiraRetrSecret -jiraOrg "parentCompany"
    Retrieves all transitions available for the Jira ticket "GHD-53697" using the provided API key and default Jira user.
    .NOTES
    General notes
    This function is used to retrieve the available transitions for a given Jira ticket. It is useful for understanding what actions can be performed on the ticket.
    It is important to note that the transitions returned are specific to the current state of the ticket and the workflow it is associated with.
    If you are unsure of the transitions available for a ticket, you can use this function to retrieve them.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function returns a collection of transitions available for the specified Jira ticket.
    Each transition object contains properties such as 'id', 'name', and 'to', which describe the transition and the status it leads to.
    If the operation is successful, it will return the transitions in JSON format. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 2,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain -join ""),
    [Parameter(Position = 3 , HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey,  
    [Parameter(Position = 4, HelpMessage = "Enter the Jira URL-PREFIX`n`nExample yourcompany for yourcompany.atlassian.net)", Mandatory = $true)]
    [string] $jiraOrg = "parentCompany"
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $uri = "https://", "$jiraOrg", ".atlassian.net/rest/api/3/issue/$jiraTicket/transitions" -join ""
    $response = Invoke-RestMethod -uri $uri -method Get -headers $jiraHeader
    return $response.transitions
}
function Get-LAPSCredential{
    <#
    .SYNOPSIS
    Retrieves the LAPS credential for a specified computer.
    .DESCRIPTION
    This function retrieves the LAPS (Local Administrator Password Solution) credential for a specified computer.
    It uses the Get-LapsAADPassword cmdlet to fetch the password and account information,
    and then tests the validity of the credentials by attempting to establish a WSMan session.
    .PARAMETER computerName
    The name of the computer for which to retrieve the LAPS credential.
    .EXAMPLE
    Get-LAPSCredential -computerName "Computer01"
    Retrieves the LAPS credential for the computer named "Computer01".
    .OUTPUTS
    PSCredential
    Returns a PSCredential object containing the LAPS account and password if valid, otherwise returns $null.
    .NOTES
    Requires the Get-LapsAADPassword cmdlet to be available in the session.
    .LINK
    https://docs.microsoft.com/en-us/powershell/module/laps/get-lapsaadpassword
    .
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0, HelpMessage = "Enter the name of the computer to retrieve LAPS credentials for.")]
        [string]$computerName,
        [Parameter(Mandatory = $false, HelpMessage = "Use this switch to attempt to test the connection.")]
        [switch]$TestConnection,
        [Parameter(Mandatory = $false, HelpMessage = "Use this switch to force the use of PowerShell 7 for testing.")]
        [switch]$UsePS7,
        [Parameter(Mandatory = $false, HelpMessage = "Use this to return the LAPS User and Password in Plain Text.")]
        [switch]$asPlainText
    ) 
        $lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords  
        if($lapsData){
            $account  = ".\" , $($lapsData.account) -join ""
            $pw = $lapsData.password
            [PSCREDENTIAL]$LAPS = [PSCredential]::New($account,$pw)
        
            if ($TestConnection) {
                Write-Host "Testing LAPS Credential for $computerName..." -ForegroundColor Yellow
                $baseTestResult = Test-Wsman -ComputerName $computerName -Authentication Negotiate -Credential $LAPS
                $ps7TestResult = Test-PSSessionConfiguration -ComputerName $computerName -ConfigurationName "PowerShell.7" -Authentication Negotiate -Credential $LAPS
                if ($baseTestResult -and $ps7TestResult){
                    Write-Host "LAPS Credential for $computerName is valid" -ForegroundColor Green
                    return $LAPS
                }
                else{
                    throw "LAPS Credential for $computerName is not valid" 
                }
            }
            if ($asPlainText -eq $true){
                $lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords -AsPlainText
                return [PSCustomObject]@{
                    UserName = $account
                    Password = $lapsData.password
                }
            }
            else{      
                return $LAPS
            }
        }
        else{
            Throw "No LAPS data found for $computerName"
        }
}
function Get-LicenseAssignmentDate{
    <#
    .SYNOPSIS
    #This function will return all licenses and the first date that they were assigned to a user.
    .DESCRIPTION
    This function connects to Microsoft Graph and retrieves all users. 
    It will then retreive all of the SKUs that are enabled in the tenant, where there is an active assignment.
    It will then go through all of the users and determine when the license was first assigned to them.
    .COMPONENT
    EntraID
    .EXAMPLE
    Get-LicenseAssignmentDate
    .NOTES
    This was specifically created for a full tenant audit of all users and their assigned licenses. 
    For individual users, you would use the following, reviewing the 'AssignedDateTime' Property
    $userID = "givenName.surName@domain.extension"
    Get-MgbetaUser -userid $userID  | select AssignedPlans -ExpandProperty AssignedPlans 
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    .OUTPUTS
    A list of all users with their assigned licenses and the date the license was first assigned.
    #>
    $licenseAssignmentData = @()
    $allUsers = Get-MGBetaUser -all -consistencylevel:eventual
    $totalAssignedLicenses = Get-MGSubscribedSKU | Where-Object {($_.AppliesTo -eq 'User') -and ($_.ConsumedUnits -gt 0)} | Sort-Object -Property ConsumedUnits -Descending
    ForEach ($individualLicense in $totalAssignedLicenses){
        $licensedUsers = $allUSers | Where-Object {($_.AssignedLicenses.SkuId -contains $individualLicense.SkuId)}
        
        ForEach ($licensedUser in $licensedUsers){
            $licensedAssignedAt = $licensedUser.AssignedPlans | Where-Object {($_.ServicePlanID -in $individualLicense.ServicePlans.ServicePlanID)} | Select-Object AssignedDateTime -Unique | Sort-Object -Top 1
            $licenseAssignmentData +=[PSCustomObject]@{
                userName                = $licensedUser.DisplayName
                userUPN                 = $licensedUser.UserPrincipalName
                userID                  = $licenseduser.Id
                userTitle               = $licensedUser.JobTitle
                department              = $licensedUser.Department
                officeLocation          = $licensedUser.OfficeLocation
                company                 = $licensedUser.CompanyName
                licenseName             = $individualLicense.SkuPartNumber
                licenseAssignedAt       = $licensedAssignedAt.AssignedDateTime
            }
        }
    }
    return $licenseAssignmentData

}
function Get-LocationUserCount {
    <#
    .SYNOPSIS
    Gets the number of users in each location.
    .DESCRIPTION
    Gets the number of users in each location.
    .COMPONENT
    EntraID, Jira
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It
    defaults to the current user's username and domain.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER locationType
    Specify the type of location to filter by. All will return a split list of Shop and Office Users Office will return only Office Users.
    Combined will return a combined list of Office and Shop Users.
    .EXAMPLE
    Get-LocationUserCount
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A list of locations with the number of users in each location.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@' , $env:UserDNSDOmain.tolower() -join ""),
        [Parameter(Position = 1, HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
        [string] $jiraKey,
        [Parameter(Mandatory = $false,helpMessage = "Specify the type of location to filter by. All will return a split list of Shop and Office Users.`n
        Office will return only Office Users.`n
        Shop will return only Shop Users.`n
        Combined will return a combined list of Office and Shop Users.")]
        [ValidateSet("All", "Office", "Shop", "Combined","Needs Specified")]
        [string]$locationType = "Combined",
        [parameter(Mandatory = $false,HelpMessage = "Specify the name of the custom field to use for locations. Defaults to 'parentCompany Location'.")]
        [string]$customFieldName = "parentCompany Location",
        [Parameter(Mandatory = $false,HelpMessage = "Specify this if you would like to export the results to a CSV file. Defaults to `$false.")]
        [switch]$exportToCSV = $false,
        [Parameter(Mandatory = $false,HelpMessage = "Specify the path to export the results to. Defaults to C:\Temp\yyyy-MM-dd-locationUserCount.csv")]
        [string]$exportPath = "C:\Temp\",
        [Parameter(Mandatory = $false,HelpMessage = "Specify the date format for the export file name. Defaults to 'yyyy-MM-dd'.")]
        [string]$dateFormat = 'yyyy-MM-dd'

    )
    $today = Get-Date -Format $dateFormat
    $locations = @()
    $parentCompanyLocations = Get-CustomFieldValues -customFieldName $customFieldName -jiraUser $jiraUser -jiraKey $jiraKey
    if ($null -eq $parentCompanyLocations) {
        Throw "No parentCompany Locations found. Please ensure the custom field exists."
    }
    $allUsers = Get-MgBetaUser -All -ConsistencyLevel eventual | Select-Object -Property *
    $employees = $allUsers | Where-Object {($_.CompanyName -ne 'Not Affiliated') -and ($_.UserType -eq 'Member') -and ($_.AccountEnabled -eq $true)}
    ForEAch ($location in $parentCompanyLocations.value){
        $locations += $location
    }
    $employeeCounts = @()
    ForEAch ($location in $locations){
        If($locationType -eq 'All') {
            $officeOrShop = @("Office","Shop",$null)
            forEach ($type in $officeOrShop) {
                $employeeCount = ($employees | Where-Object {($_.OnPremisesExtensionAttributes.ExtensionAttribute1 -eq $type) -and ($_.OfficeLocation -eq $location)}).Count
                if ($null -eq $type){
                    $type = "Needs Specififed"
                }
                $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = $type
                }
            }
        }
        elseif($locationType -eq 'Combined'){
                $employeeCount = ($employees | Where-Object {($_.OfficeLocation -eq $location)}).Count
                $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = $locationType
                }
        }
        elseif($locationType -eq 'Needs Specified'){
            $employeeCount = ($employees | Where-Object {($null -eq $_.OnPremisesExtensionAttributes.ExtensionAttribute1) -and ($_.OfficeLocation -eq $location)}).Count
            $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = "Needs Specififed"
                }
        }
        else{
            $employeeCount = ($employees | Where-Object {($_.OnPremisesExtensionAttributes.ExtensionAttribute1 -eq $locationType) -and ($_.OfficeLocation -eq $location)}).Count
            $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = $locationType
                }
        }
    }
    $employeeCounts = $employeeCOunts | Sort-Object -Property numberOfEmployees -Descending   
    if ($exportToCSV) {
        $exportFileName = "$today-locationUserCount.csv"
        $exportFullPath = Join-Path -Path $exportPath -ChildPath $exportFileName
        $employeeCounts | Export-Csv -Path $exportFullPath -NoTypeInformation
        Write-Host "Exported results to $exportFullPath"
    }
    else {
        Write-Output "Results not exported. Use -exportToCSV to export the results."
    }
    return $employeeCounts
}
function Get-Permission{
    <#
    .SYNOPSIS
    Retrieves permissions for a specified user or group on a given object.
    .DESCRIPTION
    This function retrieves the permissions on a given object and returns the information in a human readable format.
    .PARAMETER Path
    The path to the object for which permissions are being retrieved.
    .PARAMETER Identity
    The user or group for which permissions are being retrieved.
    .PARAMETER Type
    The type of object for which permissions are being retrieved (e.g., 'User', 'Group').
    .PARAMETER ObjectType
    The type of object for which permissions are being retrieved (e.g., 'File', 'Folder', 'Share').
    .PARAMETER IncludeInherited
    A switch to include inherited permissions in the output.
    .PARAMETER IncludeEffective
    A switch to include effective permissions in the output.
    .EXAMPLE
    Get-Permission -Path "C:\MyFolder" -Identity "Domain\User" -Type "User" -ObjectType "Folder"
    Retrieves permissions for the user "Domain\User" on the folder "C:\MyFolder".
    .EXAMPLE
    Get-Permission -Path "C:\MyFolder" -Identity "Domain\Group" -Type "Group" -ObjectType "Folder" -IncludeInherited
    Retrieves permissions for the group "Domain\Group" on the folder "C:\MyFolder", including inherited permissions.
    .NOTES
    You must have the necessary permissions to retrieve permissions on the specified object.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-acl?view=powershell-7.5#notes
    .OUTPUTS
    System.Management.Automation.PSObject
    Returns a PSObject containing the permissions for the specified user or group on the given object.    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,HelpMessage = "Path to the object for which permissions are being retrieved.",Position = 0,
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false, HelpMessage = "The user or group for which permissions are being retrieved.", Position = 1,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Identity,

        [Parameter(Mandatory = $false, HelpMessage = "The type of object for which permissions are being retrieved.", Position = 2,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('User', 'Group')]
        [string]$Type,
        [Parameter(Mandatory = $false, HelpMessage = "The type of object for which permissions are being retrieved.", Position = 3,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('File', 'Folder', 'Share')]
        [string]$ObjectType,
        [Parameter(Mandatory = $false, HelpMessage = "Include inherited permissions in the output.", Position = 4,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$IncludeInherited
    )
    begin {
        Write-Verbose "Starting Get-Permission function"
    }
    process{
        try{Test-Path -Path $Path -ErrorAction Stop | Out-Null
            Write-Verbose "The specified path '$Path' exists and is accessible."
        }
        catch {
            Write-Error "The specified path '$Path' does not exist or is inaccessible."
            return
        }
        $acl = Get-Acl -Path $Path -ErrorAction Stop
        if ($null -eq $acl) {
            Write-Error "Failed to retrieve ACL for the specified path '$Path'."
            return
        }
        $permissions = @()
        foreach ($access in $acl.Access) {
            $permissions += [PSCustomObject]@{
                IdentityReference = $access.IdentityReference
                AccessControlType = $access.AccessControlType
                FileSystemRights  = $access.FileSystemRights
                IsInherited       = $access.IsInherited
                InheritanceFlags  = $access.InheritanceFlags
                PropagationFlags  = $access.PropagationFlags
            }
        }
        switch ($Identity){
            $null{
                Write-Verbose "No Identity specified, returning all permissions for the path '$Path'."
                [pscustomobject]$returnPermissions = $permissions | Select-Object IdentityReference, AccessControlType, FileSystemRights, IsInherited, InheritanceFlags, PropagationFlags
            }
            Default {
                Write-Verbose "Filtering permissions for Identity '$Identity'."
                $filteredPermissions = $permissions | Where-Object { $_.IdentityReference -like "*$Identity*" }
                if ($filteredPermissions.Count -eq 0) {
                    Write-Warning "No permissions found for Identity '$Identity' on the path '$Path'."
                    return
                }
                [pscustomobject]$returnPermissions = $filteredPermissions | Select-Object IdentityReference, AccessControlType, FileSystemRights, IsInherited, InheritanceFlags, PropagationFlags
            }
        }
        switch($Type) {
            'User' {
                Write-Verbose "Filtering permissions for User type."
                $returnPermissions = $returnPermissions | Where-Object { $_.IdentityReference -like "*$Identity*" -and $_.AccessControlType -eq 'Allow' }
            }
            'Group' {
                Write-Verbose "Filtering permissions for Group type."
                $returnPermissions = $returnPermissions | Where-Object { $_.IdentityReference -like "*$Identity*" -and $_.AccessControlType -eq 'Allow' }
            }
            'Share'{
                Write-Verbose "Filtering permissions for Share type."
                $returnPermissions = $returnPermissions | Where-Object { $_.IdentityReference -like "*$Identity*" -and $_.AccessControlType -eq 'Allow' }
            }
            Default {
                Write-Verbose "No specific type provided, returning all permissions."
            }
        }
        Switch($includeInherited) {
            $true {
                Write-Verbose "Including inherited permissions."
                $returnPermissions = $returnPermissions | Where-Object { $_.IsInherited -eq $true }
            }
            $false {
                Write-Verbose "Excluding inherited permissions."
                $returnPermissions = $returnPermissions | Where-Object { $_.IsInherited -eq $false }
            }
            default {
                Write-Verbose "No IncludeInherited switch provided, returning all permissions."
            }
        }
        if ($returnPermissions.Count -eq 0) {
            Write-Warning "No permissions found for the specified criteria."
            return
        }
        Else{
            Write-Verbose "Returning permissions for the specified criteria."
            return $returnPermissions
        }
    }
}
function Get-ReportedJiraIssues {
    <#
    .SYNOPSIS
        Retrieves the issues assigned to the current user in Jira.
    .DESCRIPTION
        This function connects to Jira and retrieves the issues assigned to the current user.
    .COMPONENT
        Jira
    .PARAMETER jiraOrg
        The organization name for the Jira instance. Defaults to 'parentCompany'.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .PARAMETER jiraReporter
        The person who reported the issue to Jira
    .EXAMPLE
        Get-ReportedJiraIssues -jiraOrg 'parentCompany' -jiraUser 'david.drosdick@Domain.extension1' -jiraKey $jiraKey -jiraReporter "David.Drosdick@Domain.extension1"
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
        The output will be a list of tickets assigned to the user
    .LINK
        https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
        A list of Jira issues assigned to the current user.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$jiraOrg = 'parentCompany',
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2,Mandatory = $false,HelpMessage = "The assignee for the Jira issues. Defaults to the current user's username and domain.")]
        [string]$jiraReporter = ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [parameter(Position = 3, Mandatory = $true, HelpMessage = "The Jira Project to Retrieve.")]
        [string]$jiraProject,
        [Parameter(Mandatory = $false, HelpMessage = "Output type: Filtered or Full. Defaults to Filtered")]
        [PSDefaultValue(Help="Filtered", Value='Filtered')]
        [ValidateSet('Filtered','Full', IgnoreCase = $true)]
        [string]$outputType
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $jql = "$jiraReporter"
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $userURI = "https://$jiraOrg.atlassian.net/rest/api/3/user/search?query=$encodedJQL"
    try {
        $userResponse = Invoke-RestMethod -Uri $userURI -Method Get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    if ($userResponse -and $userResponse.Count -gt 0) {
        $userId = $userResponse[0].accountId
    } else {
        throw "No user found with the specified username: $jiraReporter"
    }
    $jql = "reporter = ","$userID",' AND PROJECT IN ',"($jiraProject)",' AND Resolution = Empty ORDER BY created asc' -join ''
    #This encodes the JQL query to be used in the API call.
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $uri = 'https://',$jiraOrg,'.atlassian.net/rest/api/3/search/jql?jql=',$encodedJQL -join ''
    try{
        $jiraResponse = Invoke-RestMethod -uri $uri -method get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    $ticketsReported = @()
    $filteredOutput = @()
    if ($jiraResponse.issues) {
        $jiraTickets = $jiraResponse.Issues.ID
        ForEach ($jiraTicket in $jiraTickets){
            $ticketsReported += Get-JiraTicket -jiraUser $jiraUser -jiraKey $jiraKey -jiraTicket $jiraTicket
        }
        if ($outputType -eq 'Filtered'){
            ForEach ($item in $ticketsReported){
                $filteredOutput += [PSCustomObject]@{
                    Reporter        = $item.fields.reporter.displayName
                    ReporterEmail   = $item.fields.reporter.emailAddress
                    Assignee        = $item.fields.assignee.displayName
                    AssigneeEmail   = $item.fields.assignee.emailAddress
                    Key             = $item.key
                    Summary         = $item.fields.summary
                    Description     = $item.fields.Description
                    Status          = $item.fields.status.name
                    Created         = $item.fields.created
                    Updated         = $item.fields.updated
                    Priority        = $item.fields.priority.name
                    IssueType       = $item.fields.issuetype.name
                }
            }
            return $filteredOutput  

        }
        else{
            return $ticketsReported
        }
    }
    else {
        return "No issues found for the specified assignee."
    }
}
function Get-Windows11HardwareReadiness {
    <#
    .SYNOPSIS
    This script checks the hardware readiness for Windows 11.

    .DESCRIPTION
    The script checks the compliance of the system hardware against the requirements for Windows 11.
    It checks the OS disk size, memory, TPM version, processor details, secure boot status, and specific CPU model.
    
    .PARAMETER None
    #>

#=============================================================================================================================
#
# Script Name:     HardwareReadiness.ps1
# Description:     Verifies the hardware compliance. Return code 0 for success. 
#                  In case of failure, returns non zero error code along with error message.

# This script is not supported under any Microsoft standard support program or service and is distributed under the MIT license

# Copyright (C) 2021 Microsoft Corporation

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#=============================================================================================================================

$exitCode = 0

[int]$MinOSDiskSizeGB = 64
[int]$MinMemoryGB = 4
[Uint32]$MinClockSpeedMHz = 1000
[Uint32]$MinLogicalCores = 2
[Uint16]$RequiredAddressWidth = 64

$PASS_STRING = "PASS"
$FAIL_STRING = "FAIL"
$FAILED_TO_RUN_STRING = "FAILED TO RUN"
$UNDETERMINED_CAPS_STRING = "UNDETERMINED"
$UNDETERMINED_STRING = "Undetermined"
$CAPABLE_STRING = "Capable"
$NOT_CAPABLE_STRING = "Not capable"
$CAPABLE_CAPS_STRING = "CAPABLE"
$NOT_CAPABLE_CAPS_STRING = "NOT CAPABLE"
$STORAGE_STRING = "Storage"
$OS_DISK_SIZE_STRING = "OSDiskSize"
$MEMORY_STRING = "Memory"
$SYSTEM_MEMORY_STRING = "System_Memory"
$GB_UNIT_STRING = "GB"
$TPM_STRING = "TPM"
$TPM_VERSION_STRING = "TPMVersion"
$PROCESSOR_STRING = "Processor"
$SECUREBOOT_STRING = "SecureBoot"
$I7_7820HQ_CPU_STRING = "i7-7820hq CPU"

# 0=name of check, 1=attribute checked, 2=value, 3=PASS/FAIL/UNDETERMINED
$logFormat = '{0}: {1}={2}. {3}; '

# 0=name of check, 1=attribute checked, 2=value, 3=unit of the value, 4=PASS/FAIL/UNDETERMINED
$logFormatWithUnit = '{0}: {1}={2}{3}. {4}; '

# 0=name of check.
$logFormatReturnReason = '{0}, '

# 0=exception.
$logFormatException = '{0}; '

# 0=name of check, 1= attribute checked and its value, 2=PASS/FAIL/UNDETERMINED
$logFormatWithBlob = '{0}: {1}. {2}; '

# return returnCode is -1 when an exception is thrown. 1 if the value does not meet requirements. 0 if successful. -2 default, script didn't run.
$outObject = @{ returnCode = -2; returnResult = $FAILED_TO_RUN_STRING; returnReason = ""; logging = "" }

# NOT CAPABLE(1) state takes precedence over UNDETERMINED(-1) state
function Private:UpdateReturnCode {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(-2, 1)]
        [int] $ReturnCode
    )

    Switch ($ReturnCode) {

        0 {
            if ($outObject.returnCode -eq -2) {
                $outObject.returnCode = $ReturnCode
            }
        }
        1 {
            $outObject.returnCode = $ReturnCode
        }
        -1 {
            if ($outObject.returnCode -ne 1) {
                $outObject.returnCode = $ReturnCode
            }
        }
    }
}

$Source = @"
using Microsoft.Win32;
using System;
using System.Runtime.InteropServices;

    public class CpuFamilyResult
    {
        public bool IsValid { get; set; }
        public string Message { get; set; }
    }

    public class CpuFamily
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct SYSTEM_INFO
        {
            public ushort ProcessorArchitecture;
            ushort Reserved;
            public uint PageSize;
            public IntPtr MinimumApplicationAddress;
            public IntPtr MaximumApplicationAddress;
            public IntPtr ActiveProcessorMask;
            public uint NumberOfProcessors;
            public uint ProcessorType;
            public uint AllocationGranularity;
            public ushort ProcessorLevel;
            public ushort ProcessorRevision;
        }

        [DllImport("kernel32.dll")]
        internal static extern void GetNativeSystemInfo(ref SYSTEM_INFO lpSystemInfo);

        public enum ProcessorFeature : uint
        {
            ARM_SUPPORTED_INSTRUCTIONS = 34
        }

        [DllImport("kernel32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool IsProcessorFeaturePresent(ProcessorFeature processorFeature);

        private const ushort PROCESSOR_ARCHITECTURE_X86 = 0;
        private const ushort PROCESSOR_ARCHITECTURE_ARM64 = 12;
        private const ushort PROCESSOR_ARCHITECTURE_X64 = 9;

        private const string INTEL_MANUFACTURER = "GenuineIntel";
        private const string AMD_MANUFACTURER = "AuthenticAMD";
        private const string QUALCOMM_MANUFACTURER = "Qualcomm Technologies Inc";

        public static CpuFamilyResult Validate(string manufacturer, ushort processorArchitecture)
        {
            CpuFamilyResult cpuFamilyResult = new CpuFamilyResult();

            if (string.IsNullOrWhiteSpace(manufacturer))
            {
                cpuFamilyResult.IsValid = false;
                cpuFamilyResult.Message = "Manufacturer is null or empty";
                return cpuFamilyResult;
            }

            string registryPath = "HKEY_LOCAL_MACHINE\\Hardware\\Description\\System\\CentralProcessor\\0";
            SYSTEM_INFO sysInfo = new SYSTEM_INFO();
            GetNativeSystemInfo(ref sysInfo);

            switch (processorArchitecture)
            {
                case PROCESSOR_ARCHITECTURE_ARM64:

                    if (manufacturer.Equals(QUALCOMM_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                    {
                        bool isArmv81Supported = IsProcessorFeaturePresent(ProcessorFeature.ARM_SUPPORTED_INSTRUCTIONS);

                        if (!isArmv81Supported)
                        {
                            string registryName = "CP 4030";
                            long registryValue = (long)Registry.GetValue(registryPath, registryName, -1);
                            long atomicResult = (registryValue >> 20) & 0xF;

                            if (atomicResult >= 2)
                            {
                                isArmv81Supported = true;
                            }
                        }

                        cpuFamilyResult.IsValid = isArmv81Supported;
                        cpuFamilyResult.Message = isArmv81Supported ? "" : "Processor does not implement ARM v8.1 atomic instruction";
                    }
                    else
                    {
                        cpuFamilyResult.IsValid = false;
                        cpuFamilyResult.Message = "The processor isn't currently supported for Windows 11";
                    }

                    break;

                case PROCESSOR_ARCHITECTURE_X64:
                case PROCESSOR_ARCHITECTURE_X86:

                    int cpuFamily = sysInfo.ProcessorLevel;
                    int cpuModel = (sysInfo.ProcessorRevision >> 8) & 0xFF;
                    int cpuStepping = sysInfo.ProcessorRevision & 0xFF;

                    if (manufacturer.Equals(INTEL_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                    {
                        try
                        {
                            cpuFamilyResult.IsValid = true;
                            cpuFamilyResult.Message = "";

                            if (cpuFamily >= 6 && cpuModel <= 95 && !(cpuFamily == 6 && cpuModel == 85))
                            {
                                cpuFamilyResult.IsValid = false;
                                cpuFamilyResult.Message = "";
                            }
                            else if (cpuFamily == 6 && (cpuModel == 142 || cpuModel == 158) && cpuStepping == 9)
                            {
                                string registryName = "Platform Specific Field 1";
                                int registryValue = (int)Registry.GetValue(registryPath, registryName, -1);

                                if ((cpuModel == 142 && registryValue != 16) || (cpuModel == 158 && registryValue != 8))
                                {
                                    cpuFamilyResult.IsValid = false;
                                }
                                cpuFamilyResult.Message = "PlatformId " + registryValue;
                            }
                        }
                        catch (Exception ex)
                        {
                            cpuFamilyResult.IsValid = false;
                            cpuFamilyResult.Message = "Exception:" + ex.GetType().Name;
                        }
                    }
                    else if (manufacturer.Equals(AMD_MANUFACTURER, StringComparison.OrdinalIgnoreCase))
                    {
                        cpuFamilyResult.IsValid = true;
                        cpuFamilyResult.Message = "";

                        if (cpuFamily < 23 || (cpuFamily == 23 && (cpuModel == 1 || cpuModel == 17)))
                        {
                            cpuFamilyResult.IsValid = false;
                        }
                    }
                    else
                    {
                        cpuFamilyResult.IsValid = false;
                        cpuFamilyResult.Message = "Unsupported Manufacturer: " + manufacturer + ", Architecture: " + processorArchitecture + ", CPUFamily: " + sysInfo.ProcessorLevel + ", ProcessorRevision: " + sysInfo.ProcessorRevision;
                    }

                    break;

                default:
                    cpuFamilyResult.IsValid = false;
                    cpuFamilyResult.Message = "Unsupported CPU category. Manufacturer: " + manufacturer + ", Architecture: " + processorArchitecture + ", CPUFamily: " + sysInfo.ProcessorLevel + ", ProcessorRevision: " + sysInfo.ProcessorRevision;
                    break;
            }
            return cpuFamilyResult;
        }
    }
"@

# Storage
try {
    $osDrive = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property SystemDrive
    $osDriveSize = Get-WmiObject -Class Win32_LogicalDisk -filter "DeviceID='$($osDrive.SystemDrive)'" | Select-Object @{Name = "SizeGB"; Expression = { $_.Size / 1GB -as [int] } }  

    if ($null -eq $osDriveSize) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $STORAGE_STRING
        $outObject.logging += $logFormatWithBlob -f $STORAGE_STRING, "Storage is null", $FAIL_STRING
        $exitCode = 1
    }
    elseif ($osDriveSize.SizeGB -lt $MinOSDiskSizeGB) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $STORAGE_STRING
        $outObject.logging += $logFormatWithUnit -f $STORAGE_STRING, $OS_DISK_SIZE_STRING, ($osDriveSize.SizeGB), $GB_UNIT_STRING, $FAIL_STRING
        $exitCode = 1
    }
    else {
        $outObject.logging += $logFormatWithUnit -f $STORAGE_STRING, $OS_DISK_SIZE_STRING, ($osDriveSize.SizeGB), $GB_UNIT_STRING, $PASS_STRING
        UpdateReturnCode -ReturnCode 0
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $STORAGE_STRING, $OS_DISK_SIZE_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
}

# Memory (bytes)
try {
    $memory = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object @{Name = "SizeGB"; Expression = { $_.Sum / 1GB -as [int] } }

    if ($null -eq $memory) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $MEMORY_STRING
        $outObject.logging += $logFormatWithBlob -f $MEMORY_STRING, "Memory is null", $FAIL_STRING
        $exitCode = 1
    }
    elseif ($memory.SizeGB -lt $MinMemoryGB) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $MEMORY_STRING
        $outObject.logging += $logFormatWithUnit -f $MEMORY_STRING, $SYSTEM_MEMORY_STRING, ($memory.SizeGB), $GB_UNIT_STRING, $FAIL_STRING
        $exitCode = 1
    }
    else {
        $outObject.logging += $logFormatWithUnit -f $MEMORY_STRING, $SYSTEM_MEMORY_STRING, ($memory.SizeGB), $GB_UNIT_STRING, $PASS_STRING
        UpdateReturnCode -ReturnCode 0
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $MEMORY_STRING, $SYSTEM_MEMORY_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
}

# TPM
try {
    $tpm = Get-Tpm

    if ($null -eq $tpm) {
        UpdateReturnCode -ReturnCode 1
        $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
        $outObject.logging += $logFormatWithBlob -f $TPM_STRING, "TPM is null", $FAIL_STRING
        $exitCode = 1
    }
    elseif ($tpm.TpmPresent) {
        $tpmVersion = Get-WmiObject -Class Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm | Select-Object -Property SpecVersion

        if ($null -eq $tpmVersion.SpecVersion) {
            UpdateReturnCode -ReturnCode 1
            $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, "null", $FAIL_STRING
            $exitCode = 1
        }

        $majorVersion = $tpmVersion.SpecVersion.Split(",")[0] -as [int]
        if ($majorVersion -lt 2) {
            UpdateReturnCode -ReturnCode 1
            $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, ($tpmVersion.SpecVersion), $FAIL_STRING
            $exitCode = 1
        }
        else {
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, ($tpmVersion.SpecVersion), $PASS_STRING
            UpdateReturnCode -ReturnCode 0
        }
    }
    else {
        if ($tpm.GetType().Name -eq "String") {
            UpdateReturnCode -ReturnCode -1
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
            $outObject.logging += $logFormatException -f $tpm
        }
        else {
            UpdateReturnCode -ReturnCode  1
            $outObject.returnReason += $logFormatReturnReason -f $TPM_STRING
            $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, ($tpm.TpmPresent), $FAIL_STRING
        }
        $exitCode = 1
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $TPM_STRING, $TPM_VERSION_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
}

# CPU Details
$cpuDetails;
try {
    $cpuDetails = @(Get-WmiObject -Class Win32_Processor)[0]

    if ($null -eq $cpuDetails) {
        UpdateReturnCode -ReturnCode 1
        $exitCode = 1
        $outObject.returnReason += $logFormatReturnReason -f $PROCESSOR_STRING
        $outObject.logging += $logFormatWithBlob -f $PROCESSOR_STRING, "CpuDetails is null", $FAIL_STRING
    }
    else {
        $processorCheckFailed = $false

        # AddressWidth
        if ($null -eq $cpuDetails.AddressWidth -or $cpuDetails.AddressWidth -ne $RequiredAddressWidth) {
            UpdateReturnCode -ReturnCode 1
            $processorCheckFailed = $true
            $exitCode = 1
        }

        # ClockSpeed is in MHz
        if ($null -eq $cpuDetails.MaxClockSpeed -or $cpuDetails.MaxClockSpeed -le $MinClockSpeedMHz) {
            UpdateReturnCode -ReturnCode 1;
            $processorCheckFailed = $true
            $exitCode = 1
        }

        # Number of Logical Cores
        if ($null -eq $cpuDetails.NumberOfLogicalProcessors -or $cpuDetails.NumberOfLogicalProcessors -lt $MinLogicalCores) {
            UpdateReturnCode -ReturnCode 1
            $processorCheckFailed = $true
            $exitCode = 1
        }

        # CPU Family
        Add-Type -TypeDefinition $Source
        $cpuFamilyResult = [CpuFamily]::Validate([String]$cpuDetails.Manufacturer, [uint16]$cpuDetails.Architecture)

        $cpuDetailsLog = "{AddressWidth=$($cpuDetails.AddressWidth); MaxClockSpeed=$($cpuDetails.MaxClockSpeed); NumberOfLogicalCores=$($cpuDetails.NumberOfLogicalProcessors); Manufacturer=$($cpuDetails.Manufacturer); Caption=$($cpuDetails.Caption); $($cpuFamilyResult.Message)}"

        if (!$cpuFamilyResult.IsValid) {
            UpdateReturnCode -ReturnCode 1
            $processorCheckFailed = $true
            $exitCode = 1
        }

        if ($processorCheckFailed) {
            $outObject.returnReason += $logFormatReturnReason -f $PROCESSOR_STRING
            $outObject.logging += $logFormatWithBlob -f $PROCESSOR_STRING, ($cpuDetailsLog), $FAIL_STRING
        }
        else {
            $outObject.logging += $logFormatWithBlob -f $PROCESSOR_STRING, ($cpuDetailsLog), $PASS_STRING
            UpdateReturnCode -ReturnCode 0
        }
    }
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormat -f $PROCESSOR_STRING, $PROCESSOR_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
}

# SecureBooot
try {
    $isSecureBootEnabled = Confirm-SecureBootUEFI
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $CAPABLE_STRING, $PASS_STRING
    UpdateReturnCode -ReturnCode 0
}
catch [System.PlatformNotSupportedException] {
    # PlatformNotSupportedException "Cmdlet not supported on this platform." - SecureBoot is not supported or is non-UEFI computer.
    UpdateReturnCode -ReturnCode 1
    $outObject.returnReason += $logFormatReturnReason -f $SECUREBOOT_STRING
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $NOT_CAPABLE_STRING, $FAIL_STRING
    $exitCode = 1
}
catch [System.UnauthorizedAccessException] {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
}
catch {
    UpdateReturnCode -ReturnCode -1
    $outObject.logging += $logFormatWithBlob -f $SECUREBOOT_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
    $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
    $exitCode = 1
}

# i7-7820hq CPU
try {
    $supportedDevices = @('surface studio 2', 'precision 5520')
    $systemInfo = @(Get-WmiObject -Class Win32_ComputerSystem)[0]

    if ($null -ne $cpuDetails) {
        if ($cpuDetails.Name -match 'i7-7820hq cpu @ 2.90ghz'){
            $modelOrSKUCheckLog = $systemInfo.Model.Trim()
            if ($supportedDevices -contains $modelOrSKUCheckLog){
                $outObject.logging += $logFormatWithBlob -f $I7_7820HQ_CPU_STRING, $modelOrSKUCheckLog, $PASS_STRING
                $outObject.returnCode = 0
                $exitCode = 0
            }
        }
    }
}
catch {
    if ($outObject.returnCode -ne 0){
        UpdateReturnCode -ReturnCode -1
        $outObject.logging += $logFormatWithBlob -f $I7_7820HQ_CPU_STRING, $UNDETERMINED_STRING, $UNDETERMINED_CAPS_STRING
        $outObject.logging += $logFormatException -f "$($_.Exception.GetType().Name) $($_.Exception.Message)"
        $exitCode = 1
    }
}

Switch ($outObject.returnCode) {

    0 { $outObject.returnResult = $CAPABLE_CAPS_STRING }
    1 { $outObject.returnResult = $NOT_CAPABLE_CAPS_STRING }
    -1 { $outObject.returnResult = $UNDETERMINED_CAPS_STRING }
    -2 { $outObject.returnResult = $FAILED_TO_RUN_STRING }
}
$exitCode | Out-Null
$isSecureBootEnabled | Out-Null
return [pscustomobject]$outObject | Format-List
}   
function Install-CustomModule{
    <#
    .SYNOPSIS
    This function will install Custom parentCompany Modules that have been authored by GIT.
    .DESCRIPTION
    This function installs Custom Modules to the "C:\Program Files\PowerShell\Modules\[ModuleName]" path. 
    It searches commonly used deployment areas, GitHub, File Shares, LocalFiles, etc, to install the Modules.
    It will only install the Modules for PowerShell 7 as earlier versions are quickly approaching EOL.
    .COMPONENT
    PowerShell, Modules
    .PARAMETER moduleName
    The name of the module to install. This will create a folder in "C:\Program
    Files\PowerShell\Modules\[ModuleName]".
    .PARAMETER localSource
    Use this switch to install a module from a Local Path. This will copy all of the
    files found at that path into the PowerShell module folder '[ModuleName]'.
    .PARAMETER localPath
    Define the path to the directory where the modules are contained.
    Example: "C:\Temp\Show-ExampleModule\" will get all the .ps
    m1 and .ps1 files in "C:\Temp\Show-ExampleModule".
    .PARAMETER gitHubSource
    Use this switch to install a Module from a GitHub Repo. It will connect to the
    parentCompany Approved GitHub Repository to pull the module named '[ModuleName]'.
    .PARAMETER shareSource
    Use this switch to install a module from a Server Share. It will connect to an
    parentCompany Approved Server Share to install custom modules.
    .PARAMETER shareString
    Enter the path to the share. Example: "\\server\Share\Install-CustomModule
    \" will get the files from "\\server\share\Install-CustomModule".
    .EXAMPLE
    #The following example will use a localPath and will move the files into the PowerShell Modules Folder for long-term use.
    Install-CustomModule -moduleName "Start-BetterMessageTrace -localSource -localPath "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\____Modules\Start-BetterMessageTrace\0 - Prod\"
    .EXAMPLE
    #The following will connect to an parentCompany Approved GitHub Repository to pull the module named 'Start-BetterMessageTrace'
    Install-CustomModule -moduleName "Start-BetterMessageTrace" -gitHub
    .EXAMPLE
    #The following example will connect to an parentCompany Approved Server Share to install custom modules.
    Install-CustomModule -moduleName "Start-BetterMessageTrace" -serverShare '\\parentCompanyusers\public\tech-items\script configs\Modules\start-bettermessagetrace'
    .NOTES
    This module installs PowerShell Files as Custom Modules.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-item
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core
    .OUTPUTS
    This function does not return any output, it simply installs the module to the specified path.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,HelpMessage="Enter the name of the Module to install, this will create a folder in C:\Program Files\PowerShel\Modules\moduleName",Mandatory)]
        [string]
        $moduleName,
        [Parameter(HelpMessage="Use this switch to install a module from a Local Path",ParameterSetName = "Local")]
        [switch]
        $localSource,
        [Parameter(HelpMessage="Define the path to the directory where the modules are contained.`nExample: C:\Temp\Show-ExampleModule\ will get all the .psm1 and .ps1 files in C:\Temp\Show-ExampleModule",ParameterSetName = "Local",Mandatory)]
        [string]
        $localPath,
        [Parameter(HelpMessage="Use this switch to install a Module from a GitHub Repo",ParameterSetName = "GitHub")]
        [switch]
        $gitHubSource,
        [Parameter(HelpMessage="Use this switch to install a module from a Server Share",ParameterSetName = "Server")]
        [switch]
        $shareSource,
        [Parameter(HelpMessage = "Enter the path to the share.`nExample: \\server\Share\Install-CustomModule\ will get the files from \\server\share\Install-CustomModule",ParameterSetName ="Server",Mandatory)]
        [string]
        $shareString
    )
        $modulePath = 'C:\Program Files\PowerShell\Modules\',$moduleName ,"\" -join ''
        if (!(Test-Path $modulePath -ErrorAction SilentlyContinue)){
            New-Item -Type Directory -Path $modulePath
        }
        if ($localSource){
            If(!(Test-Path $localPath)){
                Throw "Invalid Path, please try again"
            }
            else{
                $items = Get-ChildItem -Path $localPath -Recurse  | select-Object -Property *  | Where-Object  {($_.Extension -like ".ps*1")}
                Copy-Item $items.FullName -destination $modulePath 
            }
        }
        if ($gitHubSource){
            $baseURI = 'https://raw.githubusercontent.com/DirtyDabe23/parentCompanyRepo/refs/heads/main/Modules/'
            $extensions = '.psm1','.psd1','.ps1'
            ForEach ($extension in $extensions){
                $moduleURI = $baseURI , $moduleName ,'/' ,$moduleName , "$extension" -join ""
                If(invoke-restmethod -Method Get -uri $moduleURI -errorAction SilentlyContinue){
                    Invoke-RestMethod -method Get -uri $moduleURI -OutFile ($modulePath,$moduleName,$extension -join "")
                } 
            }
        }
        if($shareSource){
            If(!(Test-Path $shareString)){
                Throw "Invalid Path or Insufficient Privileges, please try again"
            }
            else{
                Copy-Item -path $shareString -Recurse -Destination $modulePath
            }
        }
    
}    
function Install-parentCompanyModule {
    <#
    .SYNOPSIS
    Installs the parentCompany PowerShell module from the specified path.
    .DESCRIPTION
    This function copies the parentCompany PowerShell module from a specified user profile path to the system's PowerShell modules directory.
    .COMPONENT
    parentCompany, PowerShell
    .EXAMPLE
    Install-parentCompanyModule
    .NOTES
    This function is designed to be run in a PowerShell session with administrative privileges.
    It will copy the parentCompany module to the default PowerShell modules directory.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/copy-item
    .OUTPUTS
    This function does not return any output, but it will copy the parentCompany module to the specified directory.
    #>
    [CmdletBinding()]
    param ()
    # Copy the parentCompany module to the PowerShell modules directory
    Write-Verbose "Moving all parentCompany Modules to the PowerShell Modules Directory"
    $parentCompanyModulePath = "$env:USERPROFILE",'\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\parentCompanyRepo\Modules\' -join ""
    try{
        Test-Path -Path $parentCompanyModulePath -PathType Container -ErrorAction Stop | Out-Null
    }
    catch{
        throw "The specified parentCompany module path does not exist: $parentCompanyModulePath"
    }
    $currentItems = Get-ChildItem -Path $parentCompanyModulePath -Directory -ErrorAction SilentlyContinue | Where-Object {($_.BaseName -ne 'parentCompanyModule')}
    if ($null -eq $currentItems){$currentItems = @()
        throw "No parentCompany modules found in the specified path: $parentCompanyModulePath"
    }
    # Create backup directory if it doesn't exist
    $backupDir = "C:\Temp\backupModules\$((Get-Date).ToString('yyyy-MM-dd_HH-mm'))"
    if (!(Test-Path -Path $backupDir -PathType Container -ErrorAction SilentlyContinue)){
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }
    # Create module install location if it doesn't exist
    $moduleInstallLocation = "C:\Program files\PowerShell\Modules" 
    Test-Path -Path $moduleInstallLocation -PathType Container -ErrorAction SilentlyContinue | Out-Null
    if (!(Test-Path -Path $moduleInstallLocation -PathType Container -ErrorAction SilentlyContinue)){
        New-Item -Path $moduleInstallLocation -ItemType Directory -Force | Out-Null
    }
    # Move existing modules to backup directory
    $modules = Get-ChildItem -Path $moduleInstallLocation -Directory -ErrorAction SilentlyContinue
    if ($null -eq $modules){$modules = @()}
        $moveModules = $modules | Where-Object {($_.BaseName -in $currentItems.BaseName) -and ($_.BaseName -ne 'parentCompanyModule')
    }
    if($moveModules.count -eq 0){
        Write-Verbose "No existing parentCompany modules found to move to backup directory."
        }
    else{
        Write-Verbose "Moving existing parentCompany modules to backup directory: $backupDir"
        ForEach ($moveModule in $moveModules){
            Move-Item $moveModule -Destination $backupDir -Force
        }
    }
    try{
        Test-Path -Path ($parentCompanyModulePath , "parentCompanyModule") -PathType Container -ErrorAction Stop | Out-Null
    }
    catch{
        throw "The specified parentCompany module path does not exist: $($parentCompanyModulePath , 'parentCompanyModule' -join '')"
    }
    try{
        Copy-Item -path ($parentCompanyModulePath , "parentCompanyModule\" -join "") -Destination $moduleInstallLocation -Recurse -Force
        return "parentCompany PowerShell modules installed successfully.`nUse Get-Command -Module parentCompanyModule to see available commands.`nUse Import-Module parentCompanyModule to import the module into your session.`nUse Get-Module -ListAvailable parentCompanyModule to see the installed version."
    }
    catch{
        throw "Failed to copy parentCompany modules to $moduleInstallLocation. Error: $_"
    }
}
function Install-SolidEdge{
    <#
    .SYNOPSIS
    Installs Solid Edge software.
    .DESCRIPTION
    This function installs Solid Edge software using the provided installer path and options.
    It can also set environment variables and optionally reboot the machine after installation.
    .COMPONENT
    Endpoint
    .PARAMETER InstallerPath
    The path to the Solid Edge installer executable.
    .PARAMETER Options
    Additional options to pass to the installer.
    .PARAMETER SetEnvironmentVariables
    Specifies whether to set environment variables after installation.
    .PARAMETER SELicenseServer
    Specifies the Solid Edge license server to set after installation.
    .PARAMETER RebootAfterInstallation
    Specifies whether to reboot the machine after installation.
    .PARAMETER ForceReboot
    Specifies whether to force a reboot without user confirmation after installation.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'"
    Installs Solid Edge silently with specified options.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation
    Installs Solid Edge and sets the environment variables for the license server, then reboots the machine after installation.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation -ForceReboot
    Installs Solid Edge, sets the environment variables for the license server, and forces a reboot immediately after installation.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation -ForceReboot:$false
    Installs Solid Edge, sets the environment variables for the license server, and reboots the machine in 5 minutes after installation, allowing the user to save their work.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables
    Installs Solid Edge and sets the environment variables for the license server without rebooting the machine.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation -ForceReboot:$true
    Installs Solid Edge, sets the environment variables for the license server, and forces a reboot immediately after installation.
    .NOTES
    You must have administrative privileges to run this function and said account must be able to authenticate to the target machine.
    .OUTPUTS
    None. This function performs an installation and does not return any output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,helpMessage = "Path to the Solid Edge installer executable.`nYou can target a full version OR a service pack!",Position = 0)]
            [string]$InstallerPath,
        [Parameter(Mandatory = $false,HelpMessage = "Additional options for the installer, e.g., '/s /v '/qn'")]
        [ValidateNotNullOrEmpty()]
            [string]$Options = "/s /v '/qn'",
        [Parameter(Mandatory = $false,HelpMessage = "Use ths parameter to specify you want to set environment variables after the installation completes.`nThis is useful for setting up paths or configurations that Solid Edge requires to run properly.")]
            [switch]$SetEnvironmentVariables,
        [Parameter(Mandatory = $false,ParameterSetName = "EnvironVariables", HelpMessage = "Use this parameter to specify you want to set the Solid Edge license after the installation completes.`nThis is useful for setting up the license server or other licensing configurations that Solid Edge requires to run properly.`n`
        Note: This parameter is only used if the SetEnvironmentVariables switch is also specified.`nIf you do not specify this parameter, the default license server will be used.`nYou can specify a different license server by providing the server name and port in the format 'server:port'.`n
        As this is an parentCompany module, the default license server is set to '29000@Hertz-TFS'.")]
        [Parameter(Mandatory = $false,ParameterSetName = "EnvironVariablesReboot", HelpMessage = "Use this parameter to specify you want to set the Solid Edge license after the installation completes.`nThis is useful for setting up the license server or other licensing configurations that Solid Edge requires to run properly.`n`
        Note: This parameter is only used if the SetEnvironmentVariables switch is also specified.`nIf you do not specify this parameter, the default license server will be used.`nYou can specify a different license server by providing the server name and port in the format 'server:port'.`n
        As this is an parentCompany module, the default license server is set to '29000@Hertz-TFS'.")]
            [string]$SELicenseServer = '29000@Hertz-TFS',
        [Parameter(Mandatory = $false , ParameterSetName = "EnvironVariablesReboot", HelpMessage = "Use this parameter to specify you want to reboot the machine after the installation completes.`nThis is useful for ensuring that all changes take effect and that Solid Edge is ready to use after installation.`n`
        Note: This parameter is only used if the SetEnvironmentVariables switch is also specified.`nIf you do not specify this parameter, the machine will not be rebooted after the installation completes.")]
            [switch]$RebootAfterInstallation,
        [Parameter(Mandatory = $false, ParameterSetName = "EnvironVariablesReboot", HelpMessage = "Use this to specify if you want to force a reboot or wait for user confirmation before rebooting.`nThis is useful for ensuring that the machine is rebooted immediately after the installation completes, without waiting for user confirmation.")]
            [switch]$ForceReboot
        )
    # Check if the installer path exists
    if (-Not (Test-Path -Path $InstallerPath)) {
        Write-Error "Installer path '$InstallerPath' does not exist."
        return
    }
    # Start the installation process
    try {
        Write-Host "Starting Solid Edge installation... This can take up to 10 minutes"
        Start-Process -FilePath $InstallerPath -ArgumentList $Options -Wait -NoNewWindow
        Write-Host "Solid Edge installation completed successfully."
        if($SetEnvironmentVariables){
            Write-Host "Setting environment variables for Solid Edge..."
            [System.Environment]::SetEnvironmentVariable('SE_License_Server', $SELicenseServer,'Machine')
            Write-Host "Environment variables set successfully. You NEED to restart your computer for the changes to take effect."
            if($RebootAfterInstallation) {
                if($ForceReboot) {
                    Write-Host "Rebooting the machine immediately..."
                    Restart-Computer -Force
                } else {
                    Write-Host "Rebooting the machine in 5 minutes. Please save your work."
                    Restart-Computer -Delay 300 -Confirm:$false
                    return "The machine will reboot in 5 minutes. Please save your work."
                }
                    return "Please restart your computer to apply the changes."
                }
            }
        return "Solid Edge installation completed successfully. Environment variables set. Please restart your computer to apply the changes."
    } 
    catch {
        throw "An error occurred during the installation: $_"
    }
}
function Invoke-parentCompanySync{
    <#
    .SYNOPSIS
    This function invokes a sync cycle on the specified sync server.
    .DESCRIPTION
    This function connects to the specified sync server and starts a sync cycle using the provided credentials.
    It will wait for the sync to complete, with a maximum wait time of 5 minutes
    .COMPONENT
    EntraID, AzureAD, AAD Connect
    .PARAMETER syncServer
    The name of the server that syncs devices. Default is "ServerAADC01.Domain.extension1".
    .PARAMETER SyncServerCred
    A PSCredential object containing the credentials for the sync server. This account must have the required permissions to invoke a sync.
    .EXAMPLE
    Invoke-parentCompanySync -syncServer "ServerAADC01.Domain.extension1" -SyncServerCred $syncCred
    Starts a sync cycle on the specified sync server using the provided credentials.
    .NOTES
    This function is designed to be used with Azure AD Connect to trigger a sync cycle.
    It will wait for the sync to complete, with a maximum wait time of 5 minutes.
    If the sync takes longer than 5 minutes, it will output an error message indicating that something is wrong with the sync.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/start-adsyncsynccycle
    .OUTPUTS
    This function does not return any output, but it will output messages indicating the status of the sync cycle.
    If the sync is successful, it will output a message indicating that the sync started and that it can take up to 5 minutes to apply.
    If the sync fails or takes longer than 5 minutes, it will output an error message indicating that something is wrong with the sync.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 2, HelpMessage = "Enter the name of the sever that syncs devices. Example: ServerAADC01.Domain.extension1`n`nEnter")]
    [string] $syncServer = "ServerAADC01.Domain.extension1",
    [Parameter(Position=3,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to invoke a sync",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$SyncServerCred
    )
    #Ensures you aren't going to wait over 5 minutes for a sync, if it takes over 5 minutes, something is wrong.
    $waitedTime = 0
    try{
        Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -credential $SyncServerCred -erroraction Stop
        Write-Output "Sync started! It can take up to 5 minutes to apply"
    }
    catch{
        $busySync = $true
        while (($busySync -eq $true) -and ($waitedTime -lt 50))
        {
            $syncErrorMessage = ($error[0] | Select-Object exception).exception
            If (Select-String -InputObject $syncErrorMessage -Pattern "The user name or password is incorrect.")
            {
                Write-Output "Your entered credentials are invalid!"
                Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $SyncServerCred -erroraction Stop
            }
            else
            {
                Write-Output "Waiting 6 seconds for Sync to Finish at $(Get-Date -Format HH:mm:ss)"
                $waitedTime++
                Start-Sleep -Seconds 6
                $syncResult = Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $SyncServerCred -ErrorAction SilentlyContinue
                Write-OUtput "The Sync Result Is $syncResult"
                if ($syncResult.Result -eq "Success")
                {
                    $busySync = $false
                }
            }
        }
        if($waitedTime -eq 50){Write-Output "Somethning is wrong with the sync."}
        else{Write-Output "Sync ran at $(Get-Date -Format HH:mm:ss), it will take up to 5 minutes for all changes to replicate"}
    }
    return $syncResult
}
function New-CustomField{
    <#
    .SYNOPSIS
    This function creates a custom field in Jira
    .DESCRIPTION
    This function allows you to create a custom field in Jira. It requires the Jira API and appropriate permissions to execute successfully.
    .COMPONENT
    Jira, PowerShell
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It will default to your UserName and UserDNSDomain. 
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER fieldName
    The name of the custom field to be created. This should be a unique name that does not conflict with existing fields.
    .PARAMETER description
    The description of the custom field to be created. This should provide a clear understanding of the field's purpose.    
    .PARAMETER fieldType
    The type of the custom field to be created. This should be a valid Jira field type such as 'text', 'number', 'date', etc. Valid options include:
    cascading, datepicker, datetime, float, grouppicker, importid, labels, multicheckboxes, multigrouppicker, multiselect, multiversion,
    .EXAMPLE
    New-CustomField -jiraUser "david.drosdick" -jiraKey $jiraKey -fieldName "New Custom Field" -description "This is a new custom field" -fieldType "textfield"
    This example creates a new custom field named "New Custom Field" with the type "textfield" and the provided description.
    .EXAMPLE
    New-CustomField -jiraKey $jiraKey -fieldName "New Custom Field" -description "This is a new custom field" -fieldType "textfield"
    This example creates a new custom field named "New Custom Field" with the type "textfield" and the provided description, using the default Jira user.
    .EXAMPLE
    New-CustomField -jiraKey $jiraKey -fieldName "New Custom Field" -description "This is a new custom field" -fieldType "multiselect"
    This example creates a new custom field named "New Custom Field" with the type "multiselect" and the provided description, using the default Jira user.    
    .NOTES
    This function requires the Jira API to be accessible and the user must have permissions to create custom fields in Jira.
    The function will return the details of the created custom field if successful, or an error message if it fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2 , Mandatory = $true, HelpMessage = "The name of the custom field to be created. This should be a unique name that does not conflict with existing fields.")]
        [string]$fieldName,
        [Parameter(Position = 3,Mandatory = $true,HelpMessage = "The description of the custom field to be created.")]
        [string]$description,
        [Parameter(Position = 3,Mandatory = $true,HelpMessage = "The type of the custom field to be created. This should be a valid Jira field type such as 'text', 'number', 'date', etc.")]
        [ValidateSet("cascading", "datepicker", "datetime", "float", "grouppicker", "importid", "labels", "multicheckboxes", "multigrouppicker", "multiselect", "multiversion","project"
        ,"radiobuttons","readonlyfield","select","textarea","textfield","url","userpicker","version")]
        [string]$fieldType
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    
    $jiraFieldType = 'com.atlassian.jira.plugin.system.customfieldtypes:' ,$fieldType.ToLower() -join ""

    $body = [ordered]@{
        "name" = $fieldName
        "description" = $description
        "type" = $jiraFieldType
    } | ConvertTo-JSON -Depth 5

    $requestURI = "https://parentCompany.atlassian.net/rest/api/3/field"
    try {
        $response = Invoke-RestMethod -Uri $requestURI -Method Post -Headers $jiraHeader -Body $body
        Write-Output "Custom field created successfully: $($response.name)"
        return $response
    } 
    catch {
        Throw "Failed to create custom field $fieldName`: $_"
    }
}
function New-DeviceGroupPerparentCompanyLocation{
    <#
    .SYNOPSIS
    This function creates a dynamic group in Microsoft Entra ID for each parentCompany location based on a custom field.
    .DESCRIPTION
    This function retrieves the custom field values for "Affected parentCompany Locations" and creates a dynamic group in Microsoft Entra ID for each location.
    Each group is named with the format "Affected parentCompany Locations: CC - All Devices" and is filtered by the device's extensionAttribute1.
    .COMPONENT
    Microsoft Entra ID, PowerShell
    .PARAMETER customFieldName
    The name of the custom field to retrieve values from. Defaults to "Affected parentCompany Locations".
    .EXAMPLE
    New-DeviceGroupPerparentCompanyLocation -customFieldName "Affected parentCompany Locations"
    Creates dynamic groups for each parentCompany location based on the custom field "Affected parentCompany Locations".
    .NOTES
    This function requires the Microsoft Graph PowerShell SDK to be installed and connected to Microsoft Entra ID.
    It retrieves the custom field values and creates dynamic groups based on those values.
    If a group with the same display name already exists, it will skip creating that group and output a message indicating that the group already exists.
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-mggroup
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/new-mggroup
    .OUTPUTS
    This function does not return any output, but it will create dynamic groups in Microsoft Entra ID for each parentCompany location.
    If a group already exists, it will output a message indicating that the group already exists.
    If there is an error during group creation, it will output the error message.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, HelpMessage = "Enter the name of the custom field to retrieve values from. Defaults to 'Affected parentCompany Locations'.", Mandatory = $false)]
        [string]$customFieldName = "Affected parentCompany Locations"
    )
    $customField = "Affected parentCompany Locations"
    $customField = Get-CustomField -customFieldName $customFieldName
    $customFieldValues = Get-CustomFieldValues -customFieldName $customFIeld.Name
    ForEach ($parentCompanyLocation in $customFieldValues.value){
        $displayName = $parentCompanyLocation , ": CC - All Devices" -join ""
        $mailNN = (New-Guid).guid
        If(!(Get-MgGroup -Filter "DisplayName eq '$displayName'" -ConsistencyLevel eventual -ErrorAction SilentlyContinue)){
        $filter = "(device.extensionAttribute1 -eq ""$parentCompanyLocation"")"
        try{
        New-MGgroup -DisplayName $displayName -mailNickname $mailNN -securityenabled:$true -MailEnabled:$false -GroupTypes @("DynamicMembership") -MembershipRule $filter  `
        -MembershipRuleProcessingState "On" -erroraction Stop
        }
        catch{
            write-output $error[0].exception.message
        }
        }
        Else{
            Write-OUtput "$displayName Already Exists!"
        }
    }
}
function Remove-parentCompanyDeviceAssignment{
    <#
    .SYNOPSIS
    This script removes the user as the primary user of the device.
    .DESCRIPTION
    This script removes the user as the primary user of the device by their UserPrincipalName
    It does not remove Entra Enrolled Devices
    .COMPONENT
    Microsoft Graph, PowerShell
    .PARAMETER intuneDeviceName
    The DisplayName of the Intune Device to remove the Primary User from.
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the Primary User to remove from Devices.
    .PARAMETER intuneDeviceID
    The ID of the Intune Device to remove the Primary User from.
    .PARAMETERSetName DeviceDisplayName
    This parameter set is used when you want to remove the primary user from a device by its display name.
    .PARAMETERSetName DeviceID
    This parameter set is used when you want to remove the primary user from a device by its ID.
    .PARAMETERSetName UserPrincipalName
    This parameter set is used when you want to remove the primary user from all devices associated with a specific user.
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -UserPrincipalName "TestFirst.TestLast@Domain.extension1"
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -intuneDeviceName "Test Device"
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -intuneDeviceID "12345678-1234-1234-1234-123456789012"
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -UserPrincipalName "TestFirst.TestLast@Domain.extension1" -intuneDeviceName "Test Device"
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -UserPrincipalName "TestFirst.TestLast@Domain.extension1" -intuneDeviceID "12345678-1234-1234-1234-123456789012"
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -intuneDeviceName "Test Device" -intuneDeviceID "12345678-1234-1234-1234-123456789012"
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -UserPrincipalName "TestFirst.TestLast@Domain.extension1" -intuneDeviceName "Test Device" -intuneDeviceID "12345678-1234-1234-1234-123456789012"
    .NOTES
    You need to start with Connect-MgGraph, and then you will need to have the permissions required. 
    This script requires the Microsoft Graph PowerShell SDK to be installed and connected to Microsoft Entra ID.
    It retrieves the devices associated with the specified user or device and removes the primary user from those devices.
    If the device is not found or the user is not associated with any devices, it will return a message indicating that no devices were found.
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-mgbetausermanageddevice
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/remove-mgbetausermanageddevice
    .OUTPUTS
    This function returns a collection of devices from which the primary user was removed.
    Each device object contains properties such as 'DeviceName', 'DeviceID', 'UserPrincipalName', 'SearchMethod', and 'SearchValue'.
    If the operation is successful, it will return the removed devices in a structured format.
    If there is an issue with the Microsoft Graph API connection or the device/user, it will throw an error.
    If no devices are found matching the specified criteria, it will return a message indicating that no devices were found.    
    #>
    [CmdletBinding()] 
    param(
    [Parameter(Position = 0, HelpMessage = "Enter The User Prinicpal Name to remove said user from the specified devices where they are the primary user.",ValueFromPipelineByPropertyName,Mandatory = $false)]
    [Parameter(ParameterSetName = "UserPrincipalName",  Position = 0, HelpMessage = "Enter the User Principal Name to remove as the Primary User from all devices.",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Position = 1, HelpMessage = "Enter the Intune Device DisplayName to Remove the Primary User from it",ValueFromPipelineByPropertyName,Mandatory = $false)]
    [Parameter(ParameterSetName = "DeviceDisplayName" , Position = 1, HelpMessage = "Enter the Intune Device DisplayName to Remove the Primary User from it",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$intuneDeviceName,
    [Parameter(Position = 2, HelpMessage = "Enter the Intune Device ID to Remove the Primary User from it.",ValueFromPipelineByPropertyName,Mandatory = $false)]
    [Parameter(ParameterSetName = "DeviceID",           Position = 2, HelpMessage = "Enter the Intune Device ID to Remove the Primary User from it.",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$intuneDeviceID
    )
    $removalData = @()
    if ($PSCmdlet.ParameterSetName -eq "DeviceDisplayName"){
        $searchMethod   = "DeviceDisplayName"
        $searchValue    = "$intuneDeviceName"
        #Get the Device ID from the Display Name
        $allAPIDevices = @()
        $pageData = @()
        $pageData += invoke-mggraphrequest -method get -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices" -headers @{ConsistencyLevel = 'eventual'} -ContentType application/json -outputType PSObject
        if ($pageData.'@odata.nextLink'){
            $allAPIDevices += $pageData.Value
            $nextPage = $pageData.'@odata.nextLink'
            while ($nextPage){
                $nextPageDevices = invoke-mggraphrequest -method get -uri $nextPage -headers @{ConsistencyLevel = 'eventual'} -ContentType application/json -OutputType PSObject
                $allAPIDevices += $nextPageDevices.value
                $nextPage = $nextPageDevices.'@odata.nextLink'
            }
        }
        else{
            $allAPIDevices = $pageData.Value
        }
        $devices = $allAPIDevices | Where-Object { $_.deviceName -eq $intuneDeviceName }
    }
    if ($psCmdlet.ParameterSetName -eq "DeviceID"){
        $searchMethod = 'DeviceID'
        #Validate the Device ID
        $devices = Get-MgBetaDeviceManagementManagedDevice -ManagedDeviceId $intuneDeviceID -ErrorAction SilentlyContinue
        $searchValue = "$intuneDeviceID" 
    }
    if ($PSCmdlet.ParameterSetName -eq "UserPrincipalName"){
        $searchMethod = 'UserPrincipalName'
        $searchValue =  "$userPrincipalName"
        try{ 
            $userURI = 'https://graph.microsoft.com/beta/users?$search="UserPrincipalName:' , "$UserPrincipalName"  , '"&?select=id' -join "" 
            $userResponse = invoke-mggraphrequest -method Get -uri $userURI -Headers @{ConsistencyLevel = 'eventual'} -ContentType application/json -OutputType PSObject 
            }
        catch{
            return "Failed to Retrieve: $UserPrincipalName, please try again"
        }
        $devices = (invoke-mgGraphRequest -method GEt -uri ('https://graph.microsoft.com/beta/users/{',$userResponse.Value.ID,'}/managedDevices' -join "") -OutputType PSObject -Headers @{ConsistencyLevel = 'eventual'} -ContentType application/json).value
    }
    If ($devices){
            ForEach ($device in $devices){
                $intuneDeviceID = $device.ID
                $graphApiVersion = "beta"
                $Resource = "deviceManagement/managedDevices('$intuneDeviceID')/users/`$ref"
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
                Invoke-MgGraphRequest -Method DELETE $uri
                $removalData += [PSCustomObject]@{
                    DeviceName              =   $device.deviceName
                    DeviceID                =   $device.ID
                    UserPrincipalName       =   $device.userPrincipalName
                    SearchMethod            =   $searchMethod 
                    SearchValue             =   $searchValue
                }
            }
            return $removalData
        }
        Else{
            return "There is no device registration matching $searchValue via $searchMethod"
        }
}
function Remove-TeamsCache {
    <#
        .SYNOPSIS
            Remove Teams Cache
        .DESCRIPTION
            This script removes the Teams cache files.
        .COMPONENT
            Microsoft Teams, PowerShell
        .EXAMPLE
            Remove-TeamsCache
            This will remove the Teams cache files and restart Teams.
        .NOTES
            This script is used to remove the Teams cache files and restart Teams.
            It is useful for troubleshooting issues with Teams, such as performance problems or unexpected behavior.
            The script will stop the Teams process, remove the cache files, and then restart Teams.
        .LINK
            https://learn.microsoft.com/en-us/microsoftteams/hard-reset-your-teams-app
        .OUTPUTS
            This function does not return any output, but it will remove the Teams cache files and restart Teams.
            If the operation is successful, it will not throw any errors. If there is an issue with stopping the Teams process or removing the cache files, it will throw an error.
    #>
    [CmdletBinding()]
    param()
    Get-Process -Name "Ms-Teams" | Stop-Process -Force
    Write-Output "Waiting for Ms-Teams to close..."
    while (Get-Process -Name "Ms-Teams" -ErrorAction SilentlyContinue){
        Start-Sleep -Seconds 5
    }
    $startingLocation = Get-Location
    Set-Location "$env:UserPRofile\appdata\local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams"
    $removedFiles = remove-item -path .\* -Force -Recurse
    Start-Process "Ms-Teams"
    Set-Location $startingLocation
    return $removedFiles
}
function Rename-parentCompanyUser {
    <#
    .SYNOPSIS
    This renames a specified user, either on local AD or Graph.
    .DESCRIPTION
    This function renames an parentCompany User either on Graph, or their Local AD server.
    It will update their UPN, Mail Nickname, DisplayName, DistinguishedName, CannonicalName, GivenName, SurName, and ProxyAddresses
    .COMPONENT
    parentCompany, PowerShell, Microsoft Graph, Local AD
    .PARAMETER userDataDirectory
    The path to the user's data directory. This is used to store the user's data files.
    The default value is "\\parentCompanyusers\users\".
    .PARAMETER Auto
    Use this switch to bypass all confirmations and process changes in bulk.
    This will automatically rename the user based on the current UPN and the new UPN format
    .PARAMETER Custom
    Use this switch to bypass all confirmations and process changes in bulk.
    This will allow you to pass the new UPN, first name, and last name in
    programmatically for bulk use.
    .PARAMETER newUPN
    The new UPN for the user. This is required if the Custom switch is used.
    It should be in the format "FirstName.LastName@domain.com".
    .PARAMETER firstName
    The first name of the user. This is required if the Custom switch is used.
    .PARAMETER lastName
    The last name of the user. This is required if the Custom switch is used.
    .PARAMETER CurrentUserName
    The current UPN of the user to modify. This is a mandatory parameter.
    .PARAMETER LocalADCred
    Create a Credential Via $LocalADCred = Get-Credential
    Then use this -LocalADCred $LocalADCred 
    The Credential should be entered as UserPrincipalName, and the password that corresponds with the account.
    .PARAMETER SyncServerCred
    Create a Credential Via $SyncServerCred = Get-Credential
    Then use this SyncServerCred $SyncServerCred 
    The Credential should be entered as UserPrincipalName, and the password that corresponds with the account to connect to the synching server
    .EXAMPLE
    #The following will rename a user with the UPN matching TTestUserLast@domain.extension
    #This is assuming your user account has the required permissions to invoke a sync, and modify a user on their domain.
    $cred = Get-Credential
    Rename-parentCompanyUser -CurrentUserName "TTestUserLast@domain.extension" -LocalADCred $cred -SyncServerCred $cred
    .EXAMPLE
    #The following will update the user to the 'FirstName.LastName' format, without confirmation.
    Rename-parentCompanyUser -currentUserName "testUser@domain.extension" -Auto -LocalADCred $cred -SyncServerCred $cred
    .EXAMPLE
    #The following will rename a testUser@domain.extension and set the following properties
    Rename-parentCompanyUser -currentUserName "testUser@domain.extension" -Auto -custom -newUPN "TestName.TestLast-NewLast@domain.extension" -firstName "tName" -lastName "lastName" -LocalADCred $cred -SyncServerCred $cred
    #Properties Changed:
    #UPN + Email:                                   TestName.TestLast-NewLast@domain.extension
    #MailNickName , DisplayName, CannonicalName:    Tname Lname 
    #FirstName:                                     Tname
    #LastName:                                      Lastname
    #SamAccountName:                                TestName.TestLast-Ne
    #Classic Logon Format in this case would be:    DOMAIN\TestName.TestLast-Ne
    #oldAlias:                                      smtp:testUser@domain.extension
    #primaryAlias:                                  SMTP:TestName.TestLast-NewLast@domain.extension
    .NOTES
    If you are not authenticated with Connect-MgGraph you will be prompted to do so every time.
    You will need Graph: 'User.ReadWrite.All' permissions
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-mguser
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/new-mguser
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/remove-mguser
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/set-mguser
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/invoke-mggraphrequest
    .OUTPUTS
    This function does not return any output, but it will modify the user in Microsoft Entra ID or Local AD as specified.
    If the operation is successful, it will not throw any errors.
    If there is an issue with the Microsoft Graph API connection or the user, it will throw an error.
    If the user does not exist or the UPN is invalid, it will throw an error.
    If the user is not found in Local AD, it will throw an error.
    If the user is found in Local AD, it will update the user's properties as specified.
    If the user is found in Microsoft Entra ID, it will update the user's properties as specified.
    If the user is found in both Local AD and Microsoft Entra ID, it will update the user's properties in both places.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the User Principal Name for the user to modify",Mandatory = $true)]
    [ValidatePattern( "[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?")]
    [string]$currentUserName,
    [Parameter(Position = 1,HelpMessage = "Enter the path to the user's data directory.`nExample:\\parentCompanyusers\users\`nEnter")]
    [string]$userDataDirectory ="\\parentCompanyusers\users\",
    [Parameter(ParameterSetName="Auto",Position =3,HelpMessage = "Use this Switch to Bypass all Confirmations and Process Changes in Bulk")]
    [Parameter(ParameterSetName="Custom",Position =3,HelpMessage = "Use this Switch to Bypass all Confirmations and Process Changes in Bulk")]
    [switch]$auto,
    [Parameter(ParameterSetName="Auto",Position =4,HelpMessage = "Use this Switch to Bypass all Confirmations and Process Changes in Bulk")]
    [Parameter(ParameterSetName="Custom",Position =4,HelpMessage = "Use this switch to be able to pass 'newUPN' 'firstName' and 'lastName' in programmatically for bulk use.")]
    [switch]$custom,
    [Parameter(ParameterSetName="Custom",Position =5,HelpMessage = "Enter the New UPN",Mandatory = $true)]
    [ValidatePattern( "[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?")]
    [string]$newUPN,
    [Parameter(ParameterSetName="Custom",Position =6,HelpMessage = "Enter the User's Preferred Given Name",Mandatory = $true)]
    [string]$firstName,
    [Parameter(ParameterSetName="Custom",Position =7,HelpMessage = "Enter the User's Surname",Mandatory = $true)]
    [string]$lastName,
    [Parameter(Position=8,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to create users",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$LocalADCred,
    [Parameter(Position=9,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to invoke a sync",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$SyncServerCred
    
    )
    $isFinished = $False
    Write-Output "Welcome $($env:USERNAME) to the parentCompany User Renamer!"
    Do{
    $runningUserDomainSuffix = "@" , $env:USERDNSDOMAIN -join ""
    # Output the domain suffix

    $GRAPHOrLocal = $null
    $userExists = $false
    $usertoModify = $null
    $scopes = $null
    $contexts = $null
    
    Connect-MGGRaph -NoWelcome -ErrorAction Stop
    $contexts = Get-MGContext
    $scopes = Get-MGcontext | Select-Object -ExpandProperty Scopes
    If ($scopes -notcontains 'User.ReadWrite.All'){
        Write-Output "Contexts are as follows:"
        Write-Output $contexts
        Write-output "`nScopes are as follows: "
        Write-Output $Scopes
        
        Throw 'Insufficient privileges. Please PIM, use a different account, or contact GHD'
    }
    try{
    $graphUser = Get-MGBetaUser -userid $currentUserName -ErrorAction Stop | select-object *
    if ($graphUser.OnPremisesSyncEnabled){$graphOrLocal =2}
    else{$graphOrLocal = 1}
    }
    catch{
        $graphOrLocal = 2
    }

    If ($graphOrLocal -eq 2){
        do{
            $userToModify = Get-ADUser -Filter "UserPrincipalName -eq '$currentUserName'" -properties * -erroraction SilentlyContinue -Credential $LocalADCred
            if ($null -ne $userToModify)
            {
                $userExists = $true
                Write-Output "User Mapped. Proceeding"
            }
            Else
            {
                switch ($auto) {
                    $true {Throw "Attempting to find $currentUserName Failed"
                    }
                    Default {
                        Write-Output "No user found with Username: $currentUserName Please try again`n`n`n"
                        $currentUserName = Read-Host -Prompt "Enter the UPN of the user to fix"
                    }
                }
            }
        } While ($userExists -eq $false)
        $upnSuffix = ($usertoModify.userPrincipalName -replace '^[^@]+', '').ToUpper()
        Write-Output "User Information is as follows:"
        Write-Output "User's FirstName: $($usertoModify.GivenName)"
        Write-Output "User's LastName: $($usertoModify.Surname)"
        Write-Output "User's DisplayName: $($usertoModify.DisplayName)"
        Write-Output "User's UPN: $($usertoModify.UserPrincipalName)"
        Write-Output "User's UPN Suffix: $upnSuffix"
        Write-Output "User's Aliases: $($usertoModify.proxyAddresses)"
        Write-Output "User's SAM Account Name: $($usertoModify.SamAccountName)"
        Write-Output "User's Distinguished Name: $($usertoModify.DistinguishedName)"
        

        $givenName = $userToModify.GivenName
        $surName = $usertoModify.Surname
        $oldSAM = $userToModify.SamAccountName
        $oldUPN = $userToModify.UserPrincipalName
        $newAlias = "smtp:"+$oldUPN
        $firstNameFormatted = Format-Name -inputName $givenName
        $lastNameFormatted = Format-NAme -inputName $surName
        write-output "First Name Formatted: $firstNameFormatted `nLast Name Formatted: $lastNameFormatted"
        $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
        $mailNN = $firstNameFormatted + "." +$lastNameFormatted
        $mailNN = $mailNN.trim()
        [string]$testNewUPN = $mailNN , $upnSuffix -join ""
        If ($mailNN.length -gt 20)
        {
            $newSAMName = $mailNN.substring(0,20)
        }

        Else
        {
            $newSAMName = $mailNN
        }

        Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
        Write-Output "User's NEW FirstName:         $firstNameFormatted"
        Write-Output "User's NEW LastName:          $lastNameFormatted"
        Write-Output "User's NEW DisplayName:       $newDisplayName"
        Write-Output "User's NEW UPN:               $testNewUPN"
        Write-Output "User's NEW SAM Account Name:  $newSAMName"
        Write-Output "User's ADDED Aliases:         $newAlias"
        Write-Output "User's Redirected Drive:      $userDataDirectory"

        if (($auto) -and ($custom)){$confirmation = "E"}
        elseif (($auto) -and (!($custom))){$confirmation = "Y"}
        else{$confirmation = Read-Host "`n`nWould you like to process these changes? Y for Yes, N, for No, E to Edit Manually"}

        #Auto Accept
        If($confirmation.substring(0,1) -eq 'Y'){
                [string]$newUPN = $mailNN , $upnSuffix -join ""
                $primaryAlias = "SMTP:"+$newUPN
                try{
                    if ($primaryAlias -eq $newAlias){
                        Write-Output "Line 641: Attempting to add the Primary Alias $primaryAlias"
                        Add-Alias -inputAlias $primaryAlias -GraphOrLocal "Local" -LocalADCred $LocalADCred -ErrorAction Stop
                    }
                    else{
                        Write-Output "Line 645: attempting to add both New Alias $newAlias and $primaryAlias"
                        $newAlias , $primaryAlias| ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -ErrorAction Stop}
                    }
                }
                catch{
                    Throw $error[0] 
                }
                try{
                Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -ErrorAction Stop
                }
                catch{
                    try{
                        Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -Credential $LocalADCred -ErrorAction Stop
                    }
                    catch{
                        Throw $error[0]  
                    }
                }
                try{
                    $userChanged = Get-ADUser $newSAMName -properties * -ErrorAction Stop -Credential $LocalADCred
                    Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Credential $LocalADCred -ErrorAction Stop
                    $userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -ErrorAction Stop
                    Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                    Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                    Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                    Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                    Write-Output "User's Distinguished NAme: $($userChanged.DistinguishedName)"
                    Invoke-parentCompanySync -SyncServerCred $SyncServerCred
                }
                catch{
                    Throw $error[0].exception.message
                }    
            }
        
                #Manual Edits
                ElseIf ($confirmation.substring(0,1) -eq 'E'){
                    try{
                        switch("" -eq $newUPN){
                            $true {$newUPN = Read-Host "Enter the New UPN"}
                            Default {$null}
                        }
                        switch ("" -eq $firstName) {
                            $true {$firstName = Read-Host "Enter the User's Preferred Given Name"}
                            Default {$null}
                        }
                        switch ("" -eq $lastName) {
                            $true {$lastName = Read-Host "Enter the User's Surname"}
                            Default {$null}
                        }                        
                        
                        #nameFunctionality
                        $oldSAM = $userToModify.SamAccountName
                        $oldUPN = $userToModify.UserPrincipalName
                        $newAlias = "smtp:"+$oldUPN
                        $firstNameFormatted = Format-Name -inputName $firstName
                        $lastNameFormatted  = Format-Name -inputName $lastName
                        $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
                        $newSAMName = $newUPN.Split('@')[0]
                        If ($newSAMName.length -gt 20){
                            $newSAMName = $newSAMName.substring(0,20)
                        }
                        Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
                        Write-Output "User's NEW FirstName:     $firstNameFormatted"
                        Write-Output "User's NEW LastName:      $firstNameFormatted"
                        Write-Output "User's NEW DisplayName:   $newDisplayName"
                        Write-Output "User's NEW UPN:           $newUPN"
                        Write-Output "User's NEW SAM Account Name: $newSAMName"
                        Write-Output "User's ADDED Aliases:     $newAlias"
                        Write-Output "Users NEW "
                        $primaryAlias = "SMTP:"+$newUPN
                        if ($primaryAlis -eq $newAlias){
                            $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -LocalADCred $LocalADCred -ErrorAction Stop}
                        }
                        else{
                            $newAlias , $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -LocalADCred $LocalADCred -ErrorAction Stop}
                        }
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $True{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Credential $LocalADCred -Replace @{"MailNickName"="$newDisplayName"} -ErrorAction Stop}
                            $false{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Credential $LocalADCred -Replace @{"MailNickName"="$newDisplayName"} -Server $upnSuffix -ErrorAction Stop}
                        }
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $True{$userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -ErrorAction Stop
                                Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Credential $LocalADCred -ErrorAction Stop
                                $userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -ErrorAction Stop}
                            $false{$userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -Server $upnSuffix -ErrorAction Stop
                                Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Server $upnSuffix -Credential $LocalADCred -ErrorAction Stop
                                $userChanged = Get-ADUser $newSAMName -properties * -Server $upnSuffix -Credential $LocalADCred -ErrorAction Stop}
                            }

                        Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                        Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                        Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                        Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                        Write-Output "User's Distinguished NAme: $($userChanged.DistinguishedName)"
                        Set-NewUserDataPath -userDataPath $userDataDirectory -previousName $oldSAM -newUserName $newSAMName 
                    }
                    catch{  
                        Throw $error[0]
                    }
                }
                #Exit
                ElseIf ($confirmation.substring(0,1) -eq 'N')
                {
                    Throw "Aborting Changes."
                }
                #Invalid Entries
                ElseIf (($confirmation.substring(0,1) -ne 'E') -and ($confirmation.substring(0,1) -ne 'Y') -and ($confirmation.substring(0,1) -ne 'N'))
                {
                    Write-Output "Invalid Selection, Aborting Changes"
                }
    
    }
    elseIf ($graphOrLocal -eq 1)
    {
        $contexts = Get-MGContext
        If ($null -eq $contexts)
        {
            Connect-MgGraph -NoWelcomec-ErrorAction Stop
        }
        $scopes = Get-MGcontext | Select-Object -ExpandProperty Scopes
        If ($scopes -notcontains 'User.ReadWrite.All')
        {
            Throw 'Insufficient privileges. Please PIM, use a different account, or contact GHD'
        }
        Else{
            do{
                $userToModify = Get-MGBetaUser -userid "$currentUserName" -property * -erroraction SilentlyContinue
                if ($null -ne $userToModify)
                {
                    $userExists = $true
                    Write-Output "User Mapped. Proceeding"
                }
                Else
                {
                    switch ($auth) {
                        $true {Throw "No user found with Username: $currentUserNAme on Microsoft Graph"}
                        Default {Write-Output "No user found with Username: $currentUserName Please try again`n`n`n"
                        $currentUserName = Read-Host -Prompt "Enter the UPN of the user to fix"}
                    }

                }
            } While ($userExists -eq $false)


            Write-Output "User Information is as follows:"
            Write-Output "User's UPN: $($usertoModify.UserPrincipalName)"
            Write-Output "User's Aliases: $($usertoModify.proxyAddresses)"

            $givenName = $userToModify.GivenName
            $surName = $usertoModify.Surname
            $oldUPN = $userToModify.UserPrincipalName
            $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
            $newAlias = "smtp:"+$oldUPN
            $upnSuffix ="@" +$usertoModify.userPrincipalName.Split('@')[1]
            $firstNameFormatted = Format-Name -inputName $givenName
            $lastNameFormatted  = Format-Name -inputName $surName
            $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
            $mailNN = $firstNameFormatted + "."+$lastNameFormatted
            $mailNN = $mailNN.trim()
            [string]$testNewUPN = $mailNN , $upnSuffix -join ""
            Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
            Write-Output "User's NEW UPN: $testNewUPN"
            Write-Output "User's ADDED Aliases: $newAlias"

            if (($auto) -and ($custom)){$confirmation = "E"}
            elseif(!($auto) -and ($custom)){$confirmation = "E"}
            elseif (($auto) -and (!($custom))){$confirmation = "Y"}
            else{$confirmation = Read-Host "`n`nWould you like to process these changes? Y for Yes, N, for No, E to Edit Manually"}
                
            If ($confirmation.substring(0,1) -eq 'Y'){
                $newUPN = $testNewUPN
                Update-MGBetaUser -userid $usertoModify.Id -userprincipalname $newUPN -GivenName $firstNameFormatted -Surname $lastNameFormatted -DisplayName $newdisplayName -MailNickname $mailNN -ErrorAction Stop
                $userChanged = Get-MGBetaUser -UserId $newUPN | Select-Object *
                Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                }
                ElseIf ($confirmation.substring(0,1) -eq 'E'){
                    switch("" -eq $newUPN){
                        $true {$newUPN = Read-Host "Enter the New UPN"}
                        Default {$null}
                    }
                    switch ("" -eq $firstName) {
                        $true {$firstName = Read-Host "Enter the User's Preferred Given Name"}
                        Default {$null}
                    }
                    switch ("" -eq $lastName) {
                        $true {$lastName = Read-Host "Enter the User's Surname"}
                        Default {$null}
                    }
                $newSAMName = $newUPN.split('@')[0]
                If ($newSAMName.length -gt 20){
                    $newSAMName = $newSAMName.substring(0,20)
                }
                $firstNameFormatted = Format-Name -inputName $firstName
                $lastNameFormatted  = Format-Name -inputName $lastName
                $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
                $mailNN = $firstNameFormatted , $lastNameFormatted -join "."
                Update-MGBetaUser -userid $usertoModify.Id -userprincipalname $newUPN -GivenName $firstNameFormatted -Surname $lastNameFormatted -DisplayName $newdisplayName -MailNickname $mailNN -ErrorAction Stop
                $userChanged = Get-MGBetaUser -userid $newUPN -property *
                Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                }
                ElseIf ($confirmation.substring(0,1) -eq 'N'){
                    Write-Output "Aborting Changes."
                }
                ElseIf(($confirmation.substring(0,1) -ne 'E') -and ($confirmation.substring(0,1) -ne 'Y') -and ($confirmation.substring(0,1) -ne 'N')){
                    Write-Output "Invalid Selection, Aborting Changes"
                }
        }
    }

    Elseif (($graphOrLocal -ne 1) -and ($graphOrLocal -ne 2))
    {
        Write-Output 'Invalid Selection'
    }
                
                switch ($auto){
                    $true{$rerun = "N"}
                    Default{$rerun = Read-Host "Would you like to rerun the script? Y for Yes, N, or any other Letter, for No"}
                }
                If ($rerun.substring(0,1) -eq 'Y')
                {
                    $userToModify = $null
                    $currentUserName = $null
                    $newUPN = $null
                    $firstName = $null
                    $lastName = $null
                    $graphOrLocal = $null
                    $isFinished = $False
                }
                Else
                {
                    $isFinished = $True
                }

    $graphOrLocal = $null
    }
    while ($isFinished -ne $True)
}
function Set-DevEnrionment{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,ParameterSetName = 'Minimal',HelpMessage = "Use this switch to just make some small changes to your terminal configuration")]
        [Parameter(Mandatory = $false,ParameterSetName = 'Modules',HelpMessage = "Use this switch to just make some small changes to your terminal configuration")]
        [switch]$minimal,
        [Parameter(Mandatory = $true,ParameterSetName = 'Full',HelpMessage = "Use this switch to install all files, programs, and make all changes, that would configure your environment to be ready for development")]
        [switch]$full,
        [Parameter(Mandatory = $false,ParameterSetName = 'Minimal',HelpMessage = "Use this switch to install all modules that are required for development")]
        [Parameter(Mandatory = $true,ParameterSetName = 'Modules',HelpMessage = "Use this switch to install all modules that are required for development")]
        [switch]$modules
    )
    if ($minimal) {
        if (!(Test-Path $profile -ErrorAction SilentlyContinue)){
        New-Item -Type File -Path $profile
        }
        If (!((Get-PSRepository -Name PSGAllery | Select-Object -Property InstallationPolicy) -eq "Trusted")){Set-PSResourceRepository -Name PSGallery -Trusted:$true}
        if(!(Get-AppXPackage -name Microsoft.DesktopAppInstaller)){Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe}
        if (!(Get-PackageProvider -Name PowerShellGet)){Install-PackageProvider WinGet -Force}
        If (!(Get-PSResource -Name PSWinGet -Scope AllUsers -erroraction silentlyContinue)){Install-PSResource -Name PSWinGet -Scope AllUsers}
        try{
        $wingetPackages = Get-WinGetPackage}
        catch{
            Throw "Winget is not installed. Please install it from the Microsoft Store or the official website."
        }
        $programs = @('DEVCOM.JetBrainsMonoNerdFont','JanDeDobbeleer.OhMyPosh','Microsoft.WindowsTerminal')
        ForEach ($program in $programs){
            if ($wingetPackages -notcontains $program) {
                Write-Host "Installing $program..."
                winget install $program --scope Machine
            } else {
                Write-Host "$program is already installed."
            }
        }
        Write-Host "Minimal configuration selected. Making small changes to your terminal configuration..."
        $JSONData = invoke-restMethod -uri 'https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/OhMyPoshConfig.JSON' -Method Get | ConvertTo-Json -Depth 10
        $JSONDATA | Out-File "$env:POSH_THEMES_PATH\ddrosdickTheme.OMP.json"
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ddrosdickTheme.omp.json" | Invoke-Expression
        $terminalSettings = Invoke-RestMethod -Method Get -URI "https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/WinTerminalSettings.JSON" | ConvertTo-JSON -Depth 10
        set-content -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Value $terminalSettings
        $content ='oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ddrosdickTheme.omp.json" | Invoke-Expression'
        Set-Content -value $content -Path $PROFILE
        $item = New-Item -Path "HKCU:\Software\Classes\CLSID" -Name "{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -ItemType "Key"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\" -Name 'AppsUseLightTheme' -Value '0' -Type DWORD
        New-Item -path $item.PSPath -Name 'InprocServer32' -Value ''
        Get-Process Explorer | Stop-Process
        . $profile
    }
    if($modules){
    If (!((Get-PSRepository -Name PSGAllery | Select-Object -Property InstallationPolicy) -eq "Trusted")){Set-PSResourceRepository -Name PSGallery -Trusted:$true}
    if(!(Get-AppXPackage -name Microsoft.DesktopAppInstaller)){Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe}
    if (!(Get-PackageProvider -Name PowerShellGet)){Install-PackageProvider WinGet -Force}
    If (!(Get-PSResource -Name PSWinGet -Scope AllUsers -erroraction silentlyContinue)){Install-PSResource -Name PSWinGet -Scope AllUsers}
    $modules = Invoke-RestMethod -Method Get -URI "https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/PSModules.JSON"
    $allInstalledModules = Get-PSResource -Scope Allusers
    $missingModules = $modules | Where-Object {($_.Name -notin $allInstalledModules.Name)}
    $moduleErrorLog = @()
    $moduleErrorCount = 0
    ForEach ($module in $missingModules){
        try{
            Install-PSREsource -Name $module.name -Version ($module.version.Major, $module.version.Minor -join ".") -Scope AllUsers -ErrorAction SilentlyContinue
        }
        catch{
            $moduleErrorCount++
            $moduleErrorLog+= [PSCustomObject]@{
                moduleName = $Module.name
                error       = $error[0]
            }
        }
    }
    if ($moduleErrorCount -gt 0){
        Write-Output "Please review the `$moduleErrorLog after this completes"
    }
    }
    if($full) {
        Write-Host "Full configuration selected. Installing all files, programs, and making all changes to configure your environment for development..."
        $totalAsks = 0
    $response = Read-Host "Enter 'I Agree' exactly as it appears between both single quotes, to agree that you understand you're installing Dave's Dev Config at your own discretion, and it's assumed you got approval, AKA, this isn't the fault of the author"
    while ($response -cne 'I Agree' -and ($totalAsks -lt 2)){
        $response = Read-Host "Try Again"
        $totalAsks++
    }
    if ($totalAsks -ge 2){
        Throw "Not trusted."
    }
    if (!(Test-Path $profile -ErrorAction SilentlyContinue)){
    New-Item -Type File -Path $profile
    }
    If (!((Get-PSRepository -Name PSGAllery | Select-Object -Property InstallationPolicy) -eq "Trusted")){Set-PSResourceRepository -Name PSGallery -Trusted:$true}
    if(!(Get-AppXPackage -name Microsoft.DesktopAppInstaller)){Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe}
    if (!(Get-PackageProvider -Name PowerShellGet)){Install-PackageProvider WinGet -Force}
    If (!(Get-PSResource -Name PSWinGet -Scope AllUsers -erroraction silentlyContinue)){Install-PSResource -Name PSWinGet -Scope AllUsers}
    $wingetPackages = Get-WingetPackage 
    $devProgs = Invoke-RestMethod -Method Get -uri 'https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/devProgs.json'
    forEach ($devProg in $devProgs.Sources.Packages.PackageIdentifier){if ($devProg -notin $wingetPackages.id){winget install --id $devProg --accept-source-agreements --accept-package-agreements --silent --force}}
    $reqExtensions = @("github.codespaces",`
    "github.vscode-pull-request-github",`
    "dillonchanis.midnight-city",`
    "ms-python.debugpy",`
    "ms-python.python",`
    "ms-python.python",`
    "ms-python.python",`
    "ms-python.python",`
    "ms-python.vscode-pylance",`
    "ms-toolsai.jupyter",`
    "ms-toolsai.jupyter-keymap",`
    "ms-toolsai.jupyter-renderers",`
    "ms-toolsai.vscode-jupyter-cell-tags",`
    "ms-toolsai.vscode-jupyter-slideshow",`
    "ms-vscode-remote.remote-wsl",`
    "ms-vscode.notepadplusplus-keybindings",`
    "ms-vscode.powershell",`
    "ms-vscode.vscode-github-issue-notebooks")
    $currentExtensions = code --list-extensions
    ForEach($reqExtension in $reqExtensions){if ($reqExtension -notin $currentExtensions){code --install-extension $reqExtension}}

    $modules = Invoke-RestMethod -Method Get -URI "https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/PSModules.JSON"
    $allInstalledModules = Get-PSResource -Scope Allusers
    $missingModules = $modules | Where-Object {($_.Name -notin $allInstalledModules.Name)}
    $moduleErrorLog = @()
    $moduleErrorCount = 0
    ForEach ($module in $missingModules){
    try{
        Install-PSREsource -Name $module.name -Version ($module.version.Major, $module.version.Minor -join ".") -Scope AllUsers -ErrorAction SilentlyContinue
    }
    catch{
        $moduleErrorCount++
        $moduleErrorLog+= [PSCustomObject]@{
            moduleName = $Module.name
            error       = $error[0]
        }
    }
    }
    if ($moduleErrorCount -gt 0){
    Write-Output "Please review the `$moduleErrorLog after this completes"
    }


    $JSONData = invoke-restMethod -uri 'https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/OhMyPoshConfig.JSON' -Method Get | ConvertTo-Json -Depth 10
    $JSONDATA | Out-File "$env:POSH_THEMES_PATH\ddrosdickTheme.OMP.json"
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ddrosdickTheme.omp.json" | Invoke-Expression
    $content = 'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ddrosdickTheme.omp.json" | Invoke-Expression'
    Set-Content -value $content -Path $PROFILE
    $terminalSettings = Invoke-RestMethod -Method Get -URI "https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/WinTerminalSettings.JSON" | ConvertTo-JSON -Depth 10
    set-content -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Value $terminalSettings
    .$profile 
    $item = New-Item -Path "HKCU:\Software\Classes\CLSID" -Name "{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -ItemType "Key"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\" -Name 'AppsUseLightTheme' -Value '0' -Type DWORD
    New-Item -path $item.PSPath -Name 'InprocServer32' -Value ''
    Get-Process Explorer | Stop-Process
    }
}
function Set-parentCompanyUserExtensionAttribute {
    <#
    .SYNOPSIS
    Sets a user extension attribute in Active Directory.
    .DESCRIPTION
    This function sets a specified user extension attribute for a user in Active Directory.
    .COMPONENT
    M365 , EntraID , Graph
    .PARAMETER UserPrincipalName
    The User Principal Name (UPN) of the user to modify.
    .PARAMETER ExtensionAttributeNumber
    The name of the extension attribute to set.
    Valid values are "1" through "15".
    .PARAMETER AttributeValue
    The value to set for the extension attribute.
    .PARAMETER WorkLocation
    If specified, sets the work location for the user.
    .PARAMETER WorkType
    The work type for the user. Valid values are "Shop", "Shop Office", "Office", "Contractor".
    .PARAMETER FirstResponder
    If specified, sets the user as a first responder.
    .PARAMETER ApplyO365AppTypes
    If specified, applies Office 365 app types to the user.
    .PARAMETER o365Type
    Specifies the Office 365 app type for the user. Valid values are "64", "32-NoAccess", "Git-Test", "Excluded".
    .PARAMETER ExcludedFromGlobalConfig
    If specified, marks the user as excluded from global configurations.
    .PARAMETER CompliantUsername
    If specified, marks the user's username as compliant with the naming convention despite failing the rules.
    .EXAMPLE
    Set-parentCompanyUserExtensionAttribute -UserPrincipalName "<UserPrincipalName>" -ExtensionAttributeNumber "1" -AttributeValue "New Value"
    Sets the extension attribute 01 for the specified user to "New Value".
    .EXAMPLE
    Set-parentCompanyUserExtensionAttribute -UserPrincipalName "<UserPrincipalName>" -WorkLocation -WorkType "Office" -FirstResponder -ApplyO365AppTypes -o365Type "64" -ExcludedFromGlobalConfig -CompliantUsername
    Sets multiple easy attributes for the specified user, including work location, first responder status, Office 365 app types, exclusion from global config, and compliance with naming conventions.
    .NOTES
    This function requires the M365 and EntraID modules to be installed and imported.
    It also requires appropriate permissions to modify user attributes in Active Directory.
    .LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.graph.users/?view=graph-powershell-1.0
    .LINK
    https://parentCompany.atlassian.net/wiki/spaces/GOC/pages/1083867137/parentCompany+-+User+Custom+Extension+Attributes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory = $true,ParameterSetName = "ExtensionAttribute")]
        [ValidateSet("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15")]
        [string]$ExtensionAttributeNumber,
        [Parameter(Mandatory = $true,ParameterSetName = "ExtensionAttribute")]
        [string]$AttributeValue,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Select this to set easy attributes for the work location and type.")]
        [switch] $WorkLocation,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Enter the work location for the user.")]
        [ValidateSet("Shop", "Shop Office", "Office", "Contractor")]
        [string] $WorkType,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true if the user is a first responder.")]
        [switch] $FirstResponder,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true to Apply Office 365 App Types to the user")]
        [switch] $ApplyO365AppTypes,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true to Apply Office 365 App Types to the user")]
        [ValidateSet("64", "32-NoAccess", "Git-Test", "Excluded")]
        [switch] $o365Type,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true if they are excluded from Global Configurations")]
        [switch] $ExcludedFromGlobalConfig,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true if their username is compliant with the naming convention despite failing the rules.")]
        [switch] $CompliantUsername
    )
    $postExtensionAttributes = @()
    $user = Get-MGBetaUser -userid $userPrincipalName -ErrorAction Stop
    if (-not $user) {
        Throw "User with UPN '$UserPrincipalName' not found."
    } 
    switch ($PSCmdlet.ParameterSetName) {
        "ExtensionAttribute" {
           $extensionAttribute = "ExtensionAttribute" , "$ExtensionAttributeNumber" -join ""
           $postExtensionAttributes += @{
                $extensionAttribute = $AttributeValue
            } | ConvertTo-JSON -Depth 10
            # Set the extension attribute for the user'
            try{
            $result = Update-MgBetaUser -userid $user.ID -OnPremisesExtensionAttributes $postExtensionAttributes -ErrorAction Stop
            }
            catch {
                Throw "Failed to set extension attribute '$extensionAttribute' for user '$UserPrincipalName'. Error: $_"
            }
            Write-Output "Extension attribute '$extensionAttribute' set to '$AttributeValue' for user '$UserPrincipalName'."
            
        }
        "Easy-Attributes" {
            # Handle the Easy-Attributes parameter set
            if ($WorkLocation) {
                # Set the work location attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute1' = $WorkLocation
                }
            }
            if ($FirstResponder) {
                # Set the first responder attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute2' = "First Responder"
                }
            }
            if ($ApplyO365AppTypes) {
                # Set the O365 app types attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute3' = $o365Type
                }
            }
            if ($ExcludedFromGlobalConfig) {
                # Set the excluded from global config attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute13' = "Y"
                }
            }
            if ($CompliantUsername) {
                # Set the compliant username attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute14' = "Compliant"
                }
            }
            $finalPost = $postExtensionAttributes | ConvertTo-JSON -Depth 10
            try{
            $result = Update-MgBetaUser -userid $user.Id -OnPremisesExtensionAttributes $finalPost -ErrorAction Stop
            }
            catch {
                Throw "Failed to set extension attributes for user '$UserPrincipalName'. Error: $_"
            }
            return $result
        }
        Default {
            # Handle the default case
            Throw "Invalid parameter set. Please specify either 'ExtensionAttribute' or 'Easy-Attributes'."
        }
    }
}
function Set-JiraComment{
    <#
    .SYNOPSIS
    This function sets a comment on a Jira ticket.
    .DESCRIPTION
    This function connects to Jira via the API and sets a comment on a specified Jira ticket.
    It uses the Jira API key provided as a parameter to authenticate the request.
    .COMPONENT
    Jira, PowerShell
    .PARAMETER jiraTicket
    The Jira ticket key to which the comment will be added. This is a mandatory parameter.
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of
    "An Error has Occurred".
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It will default to your UserName and UserDNSDomain.
    .PARAMETER jiraKey
    The API key for Jira. This is a mandatory parameter.
    .PARAMETER privateComment
    Use `$true if this comment should be private, meaning only available to be viewed by logged in users of the Jira system.
    If this is not set, it will default to `$false
    .PARAMETER transition
    Use this if you would like to transition the issue to a new status. This will default to `$false.
    .PARAMETER transitionID
    Enter the transition ID of the status. This is a mandatory parameter if the transition parameter is set to `$true.
    .EXAMPLE
    Set-JiraComment -jiraTicket "GHD-1234" -message "An error has occurred while processing the request." -jiraUser $jiraUser -jiraKey $jiraKey
    Sets a comment on the Jira ticket with key "GHD-1234" using the provided message, Jira user, and API key.
    .EXAMPLE
    Set-JiraComment -jiraTicket "GHD-1234" -message "An error has occurred while processing the request." -jiraUser $jiraUser -jiraKey $jiraKey -privateComment $true
    Sets a private comment on the Jira ticket with key "GHD-1234" using the provided message, Jira user, and API key.
    .EXAMPLE
    Set-JiraComment -jiraTicket "GHD-1234" -message "An error has occurred while processing the request." -jiraUser $jiraUser -jiraKey $jiraKey -transition $true -transitionID "981"
    Sets a comment on the Jira ticket with key  "GHD-1234" and transitions the ticket to the status with ID "981" using the provided message, Jira user, and API key.
    .NOTES
    This function requires the Jira API key to be provided as a parameter. It constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    If the transition parameter is set to `$true`, it will also transition the ticket to the specified status using the transition ID.
    .LINK
        https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
        https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a comment to the specified Jira ticket.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error. 
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "An Error has Occured",
    [Parameter(Position = 2,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain -join ""),
    [Parameter(Position = 3 , HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey,  
    [Parameter (Position = 4 , ParameterSetName = "Private", HelpMessage = "Use `$true if this comment should be private, meaning only available to be viewed by logged in users of the Jira system.`
    `n`nIf this is not set, it will default to `$false")]
    [Bool]$privateComment,
    [Parameter (Position = 4 , ParameterSetName = "Public", HelpMessage = "Use this if you would like to transition the issue to a new status.`n`nThis will default to `$false")]
    [Bool]$transition,
    [Parameter (Position = 5 , ParameterSetName = "Public", HelpMessage = "Enter the transition ID of the status", Mandatory = $true)]
    [string]$transitionID
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    if ($transition){
        #This constructs the payload for a comment with a transition.
        $body = @{"body"="$message"}
        $add = @{"add"=$body}
        $comment = @{"comment"=@($add)}
        #This creates the JSON for a transition.
        $id = [Ordered]@{"id" = $transitionID}
        $jiraBody = [Ordered]@{"update"=$comment;"transition" = $id}
        $uri = "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions"
    }
    else{
    #This Constructs the core of the post, making the paragraphs. This can only be done on comments that do not transition the ticket.
    $paragraph = @()
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content
    $jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
    $uri = "https://parentCompany.atlassian.net/rest/api/3/issue/$jiraTicket/comment"
    }
    if ($privateComment){
        #This Constructs the parts that are needed to make a private comment. This can only be done on comments that do not transition the ticket.
        $jiraValue = @{"internal" = $privateComment}
        $jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}
        $jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
    }
    else{
        if ($null -eq $jiraBody){
            #This constructs the payload for a comment without a transition.
            $jiraBody = [Ordered]@{"body"=$jiraType}
        }
    }
    #This constructs the final payload into JSON format for posting to Jira.
    $jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
    $jiraPayload
    #This makes the comment and transitions the ticket for Jira.
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $jiraPayload -Headers $jiraHeader
    return $response
}
function Set-JiraTicketTransition{
    <#
    .SYNOPSIS
    This function will transition a Jira ticket to a new status.
    .DESCRIPTION
    This function will transition a Jira ticket to a new status. It does so by going to the Jira API and transitioning the ticket to the new status.
   .COMPONENT
    Jira, PowerShell
    .PARAMETER jiraTicket
    Enter the Jira Ticket Key to transition. This is a mandatory parameter.
    .PARAMETER jiraUser
    Enter the username of the account that is being used to connect to Jira via the API. It will default to your UserName and UserDNSDomain.
    .PARAMETER jiraKey
    Enter your API Key for Jira. This is a mandatory parameter.
    .PARAMETER jiraOrg
    Enter the Jira URL-PREFIX. This is a mandatory parameter. Example: yourcompany for yourcompany.atlassian.net. This is a mandatory parameter.
    .PARAMETER transitionID
    Enter the transition ID of the status. This is a mandatory parameter.
    .EXAMPLE
    Set-JiraTicketTransition -jiraTicket "GHD-53697" -jiraUser $jiraUser -jiraKey $jiraRetrSecret -jiraOrg "parentCompany" -transitionID "981"
    Set-JiraTicketTransition -jiraTicket "GHD-53697" -jiraKey $jiraRetrSecret -jiraOrg "parentCompany" -transitionID "981"
    .NOTES
    General notes
    This function is used to transition a Jira ticket to a new status. It is used in conjunction with the Get-JiraTransition function to retrieve the available transitions for a given Jira ticket.
    It is important to note that the transition ID must be a valid transition for the ticket. If the transition ID is not valid, the function will throw an error.
    If you are unsure of the transition ID, you can use the Get-JiraTransition function to retrieve the available transitions for the ticket.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will transition the specified Jira ticket to the new status.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    If the transition ID is not valid for the ticket, it will throw an error.
    #>
    [CmdletBinding()]
#>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 2,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain -join ""),
    [Parameter(Position = 3 , HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey,
    [Parameter(Position = 4, HelpMessage = "Enter the Jira URL-PREFIX`n`nExample yourcompany for yourcompany.atlassian.net)", Mandatory = $true)]
    [string] $jiraOrg = "parentCompany",
    [Parameter(Position = 5, HelpMessage = "Enter the transition ID of the status", Mandatory = $true)]
    [string]$transitionID
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $transitions = Get-JiraTransition -jiraTicket $jiraTicket -jiraUser $jiraUser -jiraKey $jiraKey -jiraOrg $jiraOrg
    if ($transitionID -notin $transitions.id){
        Throw "The transition ID $transitionID is not a valid transition for the ticket $jiraTicket. Please check the transition ID and try again."
    }
    else{
        $transition = @{"transition" =@{"id" = $transitionID}} | ConvertTo-Json -Depth 10
    }
    #This constructs the payload for a transition.
    $uri = "https://", "$jiraOrg", ".atlassian.net/rest/api/3/issue/$jiraTicket/transitions" -join ""
    $response = Invoke-RestMethod -uri $uri -method Post -body $transition -headers $jiraHeader -SslProtocol TLS12 -HttpVersion 2.0
    if ($null -ne $response){
        Write-Host "The transition for the ticket $jiraTicket was successful."
        return $response
    }
    else{
        Throw "The transition for the ticket $jiraTicket failed. Please check the response and try again."
    }
}
function Set-PrivateErrorJiraRunbook{
    <#
    .SYNOPSIS
    This function sets a private error comment on a Jira ticket.
    .DESCRIPTION
    This function connects to Jira via the API and sets a private error comment on a specified Jira ticket.
    It uses the Jira API key stored in an Azure Key Vault to authenticate the request.
    .COMPONENT
    Jira, Azure Key Vault
    .PARAMETER jiraTicket
    The Jira ticket key to which the private error comment will be added. This is a mandatory parameter.
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of "An Error has Occurred".
    .EXAMPLE
    Set-PrivateErrorJiraRunbook -jiraTicket "GHD-1234"
    Sets a private error comment on the Jira ticket with key "GHD-1234" using the default message "An Error has Occurred".
    .EXAMPLE
    Set-PrivateErrorJiraRunbook -jiraTicket "GHD-1234" -message "A specific error occurred while processing the request."
    Sets a private error comment on the Jira ticket with key "GHD-1234" using a custom message.
    .NOTES
    This function requires the Jira API key to be stored in an Azure Key Vault named "KeyVaultName" with the secret name "jiraAPIKey".
    If the secret is not found, it will prompt the user to enter the Jira API key via Read-Host.
    The function constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a private comment to the specified Jira ticket.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "An Error has Occured" 
    )
    $privateComment = $true
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Testing a replacement for: Set-PrivateErrorJiraRunbook
    #This Constructs the core of the post, making the paragraphs.
    $paragraph = @()
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content


    #This Constructs the parts that are needed to make a private comment.
    $jiraValue = @{"internal" = $privateComment}
    $jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}

    #This Constructs the Body 
    $jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
    $jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
    $jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$jiraTicket/comment" -Method Post -Body $jiraPayload -Headers $jiraHeader

}
function Set-PrivateErrorJira{
    <#
    .SYNOPSIS
    This function sets a private error comment on a Jira ticket.
    .DESCRIPTION
    This function connects to Jira via the API and sets a private error comment on a specified Jira ticket.
    It uses the Jira API key stored in an Azure Key Vault to authenticate the request.
    .COMPONENT
    Jira, Azure Key Vault
    .PARAMETER jiraTicket
    The Jira ticket key to which the private error comment will be added. This is a mandatory parameter.
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of "An Error has Occurred".
    .EXAMPLE
    Set-PrivateErrorJira -jiraTicket "GHD-1234"
    Sets a private error comment on the Jira ticket with key "GHD-1234" using the default message "An Error has Occurred".
    .EXAMPLE
    Set-PrivateErrorJira -jiraTicket "GHD-1234" -message "A specific error occurred while processing the request."
    Sets a private error comment on the Jira ticket with key "GHD-1234" using a custom message.    
    .NOTES
    This function requires the Jira API key to be stored in an Azure Key Vault named "KeyVaultName" with the secret name "jiraAPIKey".
    If the secret is not found, it will prompt the user to enter the Jira API key via Read-Host.
    The function constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a private comment to the specified Jira ticket.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "An Error has Occured" 
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }
    

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Testing a replacement for: Set-PrivateErrorJiraRunbook
    #This Constructs the core of the post, making the paragraphs.
    $paragraph = @()
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content

    #This Constructs the parts that are needed to make a private comment.
    $jiraValue = @{"internal" = $privateComment}
    $jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}

    #This Constructs the Body 
    $jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
    $jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
    $jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$jiraTicket/comment" -Method Post -Body $jiraPayload -Headers $jiraHeader

}
function Set-SuccessfulComment{
    <#
    .SYNOPSIS
    This function sets a successful comment on a Jira ticket.
    .DESCRIPTION
    This function connects to Jira via the API and sets a successful comment on a specified Jira ticket.
    It uses the Jira API key stored in an Azure Key Vault to authenticate the request.
    .COMPONENT
    Jira, Azure Key Vault
    .PARAMETER jiraTicket
    The Jira ticket key to which the successful comment will be added. This is a mandatory parameter
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes".
    .EXAMPLE
    Set-SuccessfulComment -jiraTicket "GHD-1234"
    Sets a successful comment on the Jira ticket with key "GHD-1234" using the default message "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes".
    .EXAMPLE
    Set-SuccessfulComment -jiraTicket "GHD-1234" -message "The issue has been resolved successfully."
    Sets a successful comment on the Jira ticket with key "GHD-1234" using a custom message.
    .NOTES
    This function requires the Jira API key to be stored in an Azure Key Vault named "KeyVaultName" with the secret name "jiraAPIKey".
    If the secret is not found, it will prompt the user to enter the Jira API key via Read-Host.
    The function constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a successful comment to the specified Jira ticket.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes" 
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "961"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
    switch ($Continue){
    $False {$null}
    Default {Continue}
    }
}
function Set-SuccessfulCommentRunbook{
    <#
    .SYNOPSIS
    This function sets a successful comment on a Jira ticket.
    .DESCRIPTION
    This function connects to Jira via the API and sets a successful comment on a specified Jira ticket.
    It uses the Jira API key stored in an Azure Key Vault to authenticate the request.
    .COMPONENT
    Jira, Azure Key Vault
    .PARAMETER jiraTicket
    The Jira ticket key to which the successful comment will be added. This is a mandatory parameter
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes".
    .EXAMPLE
    Set-SuccessfulCommentRunbook -jiraTicket "GHD-1234"
    Sets a successful comment on the Jira ticket with key "GHD-1234" using the default message "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes".
    .EXAMPLE
    Set-SuccessfulCommentRunbook -jiraTicket "GHD-1234" -message "The issue has been resolved successfully."
    Sets a successful comment on the Jira ticket with key "GHD-1234" using a custom message.
    .NOTES
    This function requires the Jira API key to be stored in an Azure Key Vault named "KeyVaultName" with the secret name "jiraAPIKey".
    If the secret is not found, it will prompt the user to enter the Jira API key via Read-Host.
    The function constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a successful comment to the specified Jira ticket.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes" 
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $message = "An Error has occured. Contact GIT For Assistance"
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "981"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
}
function Set-PublicErrorJira{
    <#
    .SYNOPSIS
    This function sets a public error comment on a Jira ticket.
    .DESCRIPTION
    This function connects to Jira via the API and sets a public error comment on a specified Jira ticket.
    It uses the Jira API key stored in an Azure Key Vault to authenticate the request.
    .COMPONENT
    Jira, Azure Key Vault
    .PARAMETER jiraTicket
    The Jira ticket key to which the public error comment will be added. This is a mandatory parameter.
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of "An Error has Occurred. Contact GIT For Assistance".
    .EXAMPLE
    Set-PublicErrorJira -jiraTicket "GHD-1234"
    Sets a public error comment on the Jira ticket with key "GHD-1234" using the default message "An Error has Occurred. Contact GIT For Assistance".
    .EXAMPLE
    Set-PublicErrorJira -jiraTicket "GHD-1234" -message "A specific error occurred while processing the request."
    Sets a public error comment on the Jira ticket with key "GHD-1234" using a custom message.
    .NOTES
    This function requires the Jira API key to be stored in an Azure Key Vault named "KeyVaultName" with the secret name "jiraAPIKey".
    If the secret is not found, it will prompt the user to enter the Jira API key via Read-Host.
    The function constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a public comment to the specified Jira ticket.
    If the operation is successful, it will not throw any errors. If there is an issue with the Jira API connection or the ticket key, it will throw an error.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string] $message = "An Error has occured. Contact GIT For Assistance"
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "981"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
}
function Set-LicenseNeedPurchased{
    <#
    .SYNOPSIS
    This function sets a comment on a Jira ticket indicating that a license needs to be purchased.
    .DESCRIPTION
    This function connects to Jira via the API and sets a comment on a specified Jira ticket indicating that a license needs to be purchased.
    It uses the Jira API key stored in an Azure Key Vault to authenticate the request.
    .COMPONENT
    Jira, Azure Key Vault
    .PARAMETER jiraTicket
    The Jira ticket key to which the comment will be added. This is a mandatory parameter.
    .PARAMETER message
    The message contents for the Jira ticket. This is an optional parameter with a default value of "Automation failed, $license licenses need purchased".
    .EXAMPLE
    Set-LicenseNeedPurchased -jiraTicket "GHD-1234"
    Sets a comment on the Jira ticket with key "GHD-1234" indicating that a license needs to be purchased using the default message "Automation failed, $license licenses need purchased".
    .EXAMPLE
    Set-LicenseNeedPurchased -jiraTicket "GHD-1234" -message "We need to purchase 5 licenses for the new software."
    Sets a comment on the Jira ticket with key "GHD-1234" indicating that a specific number of licenses need to be purchased using a custom message.
    .NOTES
    This function requires the Jira API key to be stored in an Azure Key Vault named "KeyVaultName" with the secret name "jiraAPIKey".
    If the secret is not found, it will prompt the user to enter the Jira API key via Read-Host.
    The function constructs the body of the comment in a specific format required by Jira and makes a POST request to the Jira API to add the comment.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    https://learn.microsoft.com/en-us/powershell/module/az.keyvault/get-azkeyvaultsecret
    .OUTPUTS
    This function does not return any output, but it will add a comment to the specified Jira ticket indicating that a license needs to be purchased.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 1,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 2,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "Automation failed, $license licenses need purchased"
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "991"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
}
function Set-MgDeviceExtensionAttribute {
    <#
    .SYNOPSIS
    Sets the extension attribute for a device in Microsoft Graph.
    .DESCRIPTION
    This function updates the extension attribute of a specified device in Microsoft Graph.
    It requires the device's display name, the extension attribute number (1-15), and the value to set for that attribute.
    .COMPONENT
    Microsoft Graph
    .PARAMETER devicename
    The display name of the device to update.
    .PARAMETER ExtensionAttributeNumber
    The number of the extension attribute to set. This should be a value between 1 and 15.
    .PARAMETER ExtensionAttributeValue
    The value to set for the specified extension attribute. This should be a string. Refer to Confluence for valid values.
    .PARAMETER PatchLevel
    The patch level to set for the device. This can be "Alpha", "Test", "Do not Patch", or "Upgrade".
    .EXAMPLE
    Set-MgDeviceExtensionAttribute -devicename "MyDevice" -PatchLevel "Beta"
    .NOTES
    This function requires the Microsoft Graph PowerShell SDK to be installed and configured.
    It also requires appropriate permissions to update device attributes in Microsoft Graph.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/set-mgdeviceextensionattribute
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/get-mgdevice
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/invoke-mggraphrequest
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/get-mgbetaDevice
    .OUTPUTS
    This function returns the response from the Microsoft Graph API after updating the device's extension attribute.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,Mandatory = $true)]
        [string]$Devicename,

        [Parameter(Position = 1,Mandatory = $true,ParameterSetName = "ExtensionAttributeValue")]
        [ValidateRange(1, 15)]
        [Int]$ExtensionAttributeNumber,

        [Parameter(Position = 2, Mandatory = $true,ParameterSetName = "ExtensionAttributeValue")]
        [string]$ExtensionAttributeValue,

        [Parameter(Position = 1, Mandatory = $true,ParameterSetName = "PatchLevel")]
        [ValidateSet("Alpha", "Test","Do not Patch","Upgrade")]
        [string]$PatchLevel
    )

$device =   Get-MgBetaDevice -search "DisplayName:$deviceName" -ConsistencyLevel eventual -Top 1
if (!($device)){
    Throw "Device with display name '$Devicename' not found."
}

$uri = "https://graph.microsoft.com/beta/devices/" , $device.id -join ""
if($PSBoundParameters.ContainsKey("PatchLevel")){
    switch ($PatchLevel){
        "Alpha" {$ExtensionAttributeValue = "Alpha"}
        "Test" {$ExtensionAttributeValue = "Test"}
        "Do not Patch" {$ExtensionAttributeValue = "Do not Patch"}
        "Upgrade" {$ExtensionAttributeValue = "Upgrade"}
    }
    $attributeNumber = "extensionAttribute14"
}
else {
    if ($ExtensionAttributeNumber -lt 10){
        $ExtensionAttributeNumber = "0" , $ExtensionAttributeNumber -join ""
    }
$attributeNumber = "extensionAttribute" , $ExtensionAttributeNumber -join ""
    if ($ExtensionAttributeValue -eq "Clear"){
        Write-Output "Clearing the value of $attributeNumber for device $Devicename"
        $ExtensionAttributeValue = $null
    }
    else {
        Write-Output "Setting $attributeNumber to '$ExtensionAttributeValue' for device $Devicename"
    }
    }
$json = @{
    "extensionAttributes" = @{
    "$attributeNumber" = "$ExtensionAttributeValue"
        }
} | ConvertTo-Json
  
$response = Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
return $response
}
function Set-NewUserDataPath {
    <#
    .SYNOPSIS
    Renames the user data directory for a specified user.
    .DESCRIPTION
    This function renames the user data directory for a specified user by changing the directory name from the previous username to the new username.
    It checks if the user data path exists and if the old user directory exists before attempting to rename it.
    .PARAMETER userDataPath
    The path to the user data directory where the user's data is stored.
    .PARAMETER previousName
    The previous username of the user whose data directory is to be renamed.
    .PARAMETER newUserName
    The new username to which the user's data directory will be renamed.
    .EXAMPLE
    Set-NewUserDataPath -userDataPath "\\directory\share\" -previousName "testUser" -newUserName "Test.User"
    This will rename the user data directory from "testUser" to "Test.User" in the specified user data path.
    .NOTES
    This function requires PowerShell 5.1 or higher.
    It checks if the user data path and the old user directory exist before attempting to rename them.
    If the user data path does not exist or the old user directory cannot be found, it will issue a warning and not perform the rename operation.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-item
    .OUTPUTS
    This function does not return any output. It will issue warnings if the user data path or the old user directory does not exist.
    If the rename operation is successful, it will output a message indicating that the user can access the new user data path.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Path of the Current User Data Drive Directory, leading up to their user account. `nExample: \\directory\share\`nEnter",Mandatory = $true)]
    [string]$userDataPath,
    [Parameter(Position = 1, HelpMessage = "Enter the Previous Username`nExample: testUser`nEnter",Mandatory = $true)]
    [string]$previousName,
    [Parameter(Position = 2, HelpMessage = "Enter the New Username`nExample: Test.User`nEnter",Mandatory = $true)]
    [string]$newUserName
    )
    if ($userDataPath.EndsWith("\")){
            $confirmedTerminatingUserPath = $userDataPath
        }
    else{
        $confirmedTerminatingUserPath = $userDataPath , "\" -join ""
    }
    if(!(Test-Path $confirmedTerminatingUserPath -ErrorAction SilentlyContinue)){Write-Warning "No User Directory Found, no rename has occured."}
    Else{
        $oldUserPath = $confirmedTerminatingUserPath , $previousName -join ""
        if(!(Test-Path $oldUserPath)){Write-Warning "Failed to find $oldUserPath, no rename has occured."}
        else{
            try{
                $newUserPath = $confirmedTerminatingUserPath , $newUserName -join ""
                Rename-Item -Path $userDataPath -NewName $newUserPath
                Write-Output "Verify $newUserName can access $newUserPath"
            }
            catch{
                Write-Warning "Failed to rename $oldUserPath to $newUserPath, perform manual troubleshooting."
            }
        }
    }
}
function Set-Permission {
    <#
    .SYNOPSIS
    Sets permissions on a specified file or directory.
    .DESCRIPTION
    This function allows you to set specific permissions for a user on a given file or directory.
    It can either copy permissions from a source path or set specific permissions manually.
    .COMPONENT
    FileSystem
    .PARAMETER Path
    The path to the file or directory where permissions will be set.
    .PARAMETER SourcePath
    The source path to copy permissions from (Auto parameter set).
    .PARAMETER User
    The user or group to whom the permissions will be granted (Manual parameter set).
    .PARAMETER Permissions
    An array of permissions to be granted (Manual parameter set).
    .PARAMETER Inherit
    If true, permissions will be inherited by child items. Default is false.
    .PARAMETER PreserveExistingAccess
    If true, existing permissions will be preserved when setting new ones. Default is true.
    .PARAMETER ReplaceAll
    If true, all existing permissions will be replaced. Default is false (adds to existing).
    .EXAMPLE
    Set-Permission -Path "C:\Temp\MyFile.txt" -User "DOMAIN\User" -Permissions "Read", "Write"
    .EXAMPLE
    Set-Permission -Path "C:\Temp\MyFolder" -SourcePath "C:\Template\Folder"
    .NOTES
    Ensure you run this script with appropriate permissions to modify ACLs.
    #>
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the path to the file or directory that requires the update to the ACL.")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Specify the source path to copy ACL from.", ParameterSetName = "Auto")]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Specify the user or group to set permissions for.", ParameterSetName = "Manual")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^[a-zA-Z0-9_.-]+\\[a-zA-Z0-9_.-]+$")]
        [string]$User,
        [ValidateSet("ListDirectory", "ReadData", "CreateFiles", "WriteData", "AppendData", "CreateDirectories", "ReadExtendedAttributes", "WriteExtendedAttributes", 
        "ExecuteFile", "Traverse", "DeleteSubDirectoriesAndFiles", "ReadAttributes", "WriteAttributes", "Write", "Delete", "ReadPermissions", "Read",
        "ReadAndExecute", "Modify", "ChangePermissions", "TakeOwnership", "Synchronize", "FullControl")]        
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Specify the permissions to set.", ParameterSetName = "Manual")]
        [string[]]$Permissions,
        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "If true, permissions will inherit to child items. Default is false.")]
        [bool]$Inherit = $false,
        [Parameter(Mandatory = $false, Position = 4, HelpMessage = "If true, preserves existing ACL rules. Default is true.")]
        [bool]$PreserveExistingAccess = $true,
        [Parameter(Mandatory = $false, HelpMessage = "If true, replaces all existing permissions. Default is false (adds to existing).")]
        [bool]$ReplaceAll = $false
    )
    
    # Validate paths exist
    if (-not (Test-Path -Path $Path)) {
        Write-Warning "Specified path '$Path' does not exist."
        throw "Path not found: $Path"
    }
    
    if ($PSCmdlet.ParameterSetName -eq "Auto" -and -not (Test-Path -Path $SourcePath)) {
        Write-Warning "Specified source path '$SourcePath' does not exist."
        throw "Source path not found: $SourcePath"
    }
    
    # Get current ACL
    $currentACL = Get-Acl -Path $Path
    
    if ($PSCmdlet.ParameterSetName -eq "Auto") {
        # Copy ACL from source
        Write-Host "Copying permissions from '$SourcePath' to '$Path'"
        $sourceACL = Get-Acl -Path $SourcePath
        
        if ($ReplaceAll) {
            # Replace entire ACL
            Set-Acl -Path $Path -AclObject $sourceACL
        } else {
            # Add source ACL rules to current ACL
            foreach ($accessRule in $sourceACL.Access) {
                $currentACL.SetAccessRule($accessRule)
            }
            Set-Acl -Path $Path -AclObject $currentACL
        }
    } 
    elseif ($PSCmdlet.ParameterSetName -eq "Manual") {
        # Set specific permissions for user
        Write-Host "Setting permissions for '$User' on '$Path'"
        
        # Determine inheritance and propagation flags
        $inheritanceFlags = if ($Inherit) { 
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit 
        } else { 
            [System.Security.AccessControl.InheritanceFlags]::None 
        }
        
        $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
        
        # Convert permissions array to FileSystemRights
        $fileSystemRights = [System.Security.AccessControl.FileSystemRights]::None
        foreach ($permission in $Permissions) {
            $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::$permission
        }
        
        # Create the access rule
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $User,
            $fileSystemRights,
            $inheritanceFlags,
            $propagationFlags,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        
        if ($ReplaceAll) {
            # Remove existing rules for this user first
            $currentACL.PurgeAccessRules([System.Security.Principal.NTAccount]$User)
        }
        
        # Add the new rule
        if ($PreserveExistingAccess) {
            $currentACL.SetAccessRule($accessRule)  # Adds or updates
        } else {
            $currentACL.AddAccessRule($accessRule)  # Always adds
        }
        
        # Apply the ACL
        Set-Acl -Path $Path -AclObject $currentACL
    }
    
    # Verify the changes
    $finalACL = Get-Acl -Path $Path
    
    if ($PSCmdlet.ParameterSetName -eq "Manual") {
        $result = $finalACL.Access | Where-Object { $_.IdentityReference -eq $User }
        if ($result) {
            Write-Host "Permissions set successfully for '$User' on '$Path'" -ForegroundColor Green
            return $result
        } else {
            Write-Warning "Failed to set permissions for '$User' on '$Path'"
            return $null
        }
    } else {
        Write-Host "Permissions copied successfully from '$SourcePath' to '$Path'" -ForegroundColor Green
        return $finalACL.Access
    }
}
function Set-QuickResponse{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "Jira")]
        [switch]$Jira,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the GHD Project Overview",ParameterSetName = "Jira")]
            [switch]$GHD,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Access Request Form",ParameterSetName = "Jira")]
            [switch]$AccessRequest,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Software Request Form",ParameterSetName = "Jira")]
            [switch]$SoftwareRequest,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the User Change Form",ParameterSetName = "Jira")]
            [switch]$UserChange,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the New User Form",ParameterSetName = "Jira")]
            [switch]$NewUser,
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "GitHub")]
        [switch]$GitHub,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the Modules",ParameterSetName = "GitHub")]
            [switch]$Modules,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Runbooks",ParameterSetName = "GitHub")]
            [switch]$Runbooks,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Projects in GitHub",ParameterSetName = "GitHub")]
            [switch]$Projects,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Configurations",ParameterSetName = "GitHub")]
            [switch]$Configs,
        [Parameter(Mandatory = $true,HelpMessage="Select This to get links for M365",ParameterSetName = "M365")]
        [switch]$M365,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the Azure Portal",ParameterSetName = "M635")]
            [switch]$AzurePortal,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Exchange Admin Center",ParameterSetName = "M365")]
            [switch]$ExchangeAdmin,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the M365 Admin Portal",ParameterSetName = "M365")]
            [switch]$M365Portal,
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "Confluence")]
        [switch]$Confluence,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the Service Desk Home Page",ParameterSetName = "Confluence")]
            [switch]$GSD,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Operations Documentation",ParameterSetName = "Confluence")]
            [switch]$OPS,
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "InTune")]
        [switch]$InTune,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Devices Page",ParameterSetName = "Devices")]
            [switch]$Devices,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Apps Page",ParameterSetName = "Apps")]
            [switch]$Apps,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Policies Page",ParameterSetName = "Policies")]
            [switch]$Policies,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Users Page",ParameterSetName = "Users")]
            [switch]$Users,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Groups Page",ParameterSetName = "Groups")]
            [switch]$Groups
    )
        if($Jira){
            if ($GHD) {
                $quickResponse = "https://parentCompany.atlassian.net/jira/servicedesk/projects/GHD/queues/custom/340"
            } 
            if ($AccessRequest) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/create/263"
            } 
            if ($SoftwareRequest) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/group/58/create/315"
            } 
            if($UserChange) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/create/453"
            } 
            if($NewUser) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/group/57/create/244"
            }
        }
        if($GitHub){
            if ($Modules) {
                $quickResponse = "https://github.com/DirtyDabe23/parentCompanyRepo/tree/main/Modules"
            }
            if ($Runbooks) {
                $quickResponse = "https://github.com/DirtyDabe23/parentCompanyRepo/tree/main/Runbooks"
            }
            if($Projects) {
                $quickResponse = "https://github.com/DirtyDabe23/Projects"
            }
            if ($Configs) {
                $quickResponse = "https://github.com/DirtyDabe23/public_Configs_Misc"
            }
        if($M365){
            if($AzurePortal){
                $quickResponse = "https://portal.azure.com/"
            }
            if($ExchangeAdmin){
                $quickResponse = "https://admin.exchange.microsoft.com/"
            } 
            if($M365Portal) {
                $quickResponse = "https://admin.microsoft.com/"
            }
        }
        if($Confluence) {
            if( $GSD) {
                $quickResponse = "https://parentCompany.atlassian.net/wiki/spaces/GSD/overview"
            }  
            if($OPS) {
                $quickResponse = "https://parentCompany.atlassian.net/wiki/spaces/GOC/overview"
            }
        }
        if($InTune) {
            if ($Devices) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_DeviceSettings/DevicesMenuBlade/overview"
            } elseif ($Apps) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_Apps/AppsMenuBlade/overview"
            } elseif ($Policies) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_Policy/PolicyMenuBlade/overview"
            } elseif ($Users) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_User/UserMenuBlade/overview"
            } elseif ($Groups) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_Group/GroupMenuBlade/overview"
            }
        }
    }
    Set-Clipboard -Value $quickResponse
}
function Set-WindowTitle {
    <#
    .SYNOPSIS
    Sets the title of the current PowerShell window.
    .DESCRIPTION
    This function allows you to set the title of the current PowerShell window to a specified string
    .COMPONENT
    PowerShell
    .PARAMETER Title
    The title to set for the PowerShell window.
    .EXAMPLE
    Set-WindowTitle -Title "My PowerShell Window"
    This command sets the title of the current PowerShell window to "My PowerShell Window".
    .NOTES
    THis function is useful for organizing multiple PowerShell windows or scripts.
    .OUTPUTS
    None
    #>
    [CmdletBinding()]
    param (
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1, 100)]
    # Ensure the title is not null, empty, and has a reasonable length
    [Parameter(Mandatory = $true,HelpMessage = "Enter the title for the PowerShell window.",
                   Position = 0)]
        [string]$Title
    )
    # Set the title of the current PowerShell window
    $host.UI.RawUI.WindowTitle = $Title
    Write-Host "Window title set to: $Title" -ForegroundColor Green
}
function Start-BetterIISReset {
    Write-Output "This is the IIS Command that actually works"
    iisreset /stop /timeout:60
    taskkill /F /FI "SERVICES eq was"
    iisreset /start
    Write-Output "Brought to you by David Drosdick :)"
}
function Start-BetterMessageTrace {
    <#
    .SYNOPSIS
    This function performs a message trace based on a provided mailbox identity.  
    .DESCRIPTION
    This function performs a message trace based on the provided mailbox identity as a sender.
    It will search for all event types that correspond with a failure, run the command to pull all events that match the following
    EventType: Failed , Pending , FilteredAsSpam
    .COMPONENT
    Exchange Online Management
    .PARAMETER senderAddress
    The email address of the sender to trace messages for.
    .PARAMETER recipientAddress
    The email address of the recipient to trace messages for.
    .EXAMPLE
    Start-BetterMessageTrace -senderAddress givenName.surName@domain.com 
    .NOTES
    This module is most performant on PowerShell 5.1.2
    It requires ExchangeOnlineManagement and the requisite permissions to perform message traces.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/exchange/get-messagetrace
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/exchange/get-messagetracedetail
    .OUTPUTS
    This function returns a collection of message trace information, including sender, recipient, status, reason for failure, time of failure, and message ID.
    The output is structured as a collection of PSCustomObjects, each containing the properties:
        - senderAddress
        - recipientAddress
        - status
        - reasonFailed
        - timeFailed
        - messageID
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,HelpMessage="Enter an identity that would be used for -senderAddress in get-messagetrace -senderaddress")]
        [string]
        $senderAddress,
        [Parameter(Position=1,HelpMessage="Enter an identity that would be used for -recipientAddress in get-messagetrace -recipientAddress")]
        [string]
        $recipientAddress
    )
    if (!($messageTraceLogger)){
    $messageTraceLogger     =   @()
    }
    $params = @{}
    if ($senderAddress){$Params.Add('senderAddress',$senderAddress)}
    if($recipientAddress){$Params.Add('recipientAddress',$recipientAddress)}
    $continue               =   $true
    while($continue){
        $messageTraceInfo   =   @()
        $failedMessages     =   Get-MessageTrace @params -status Failed , Pending , FilteredAsSpam
        forEach($failedMessage in $failedMessages){
            $messageDetails          =   $failedMessage | Get-MessageTraceDetail | Where-Object {($_.Event -in @("Fail","Drop","Spam"))} | Select-Object -Property *
            ForEach ($messageDetail in $messageDetails){
                $messageTraceInfo       +=  [PSCustomObject]@{
                    senderAddress       =   $failedMessage.senderAddress
                    recipientAddress    =   $failedMessage.recipientAddress
                    status              =   $failedMessage.Status
                    reasonFailed        =   $messageDetail.Detail
                    timeFailed          =   $messageDetail.Date  
                    messageID           =   $failedMessage.MessageId
                    
                }
            }
        }
        $now = Get-Date -Format "HH:mm"
        $messageTraceLogger         +=   [PSCustomObject]@{
            Time                    =   $now
            traceData               =   $messageTraceInfo
        }
        Write-Output "The messageTraceInfo returned:`n"
        return $messageTraceLogger
    }
}
function Start-ConfigureparentCompanyServer{
    <#
    .SYNOPSIS
    This Function performs most of the standard configuration items for a Server for parentCompany Management.
    .DESCRIPTION
    This function installs various items on an parentCompany Server for Management. This includes:
    PowerShell 7
        Adding the required environmental variable as well.
    Azure Arc 
        Enrolls based on the timezone location of the server.
    ScreenConnect
        Downloads and installs based on the Domain that the server is on.
    .COMPONENT
    PowerShell 7, Azure Arc, ScreenConnect
    .EXAMPLE
    Start-ConfigureparentCompanyServer 
    .NOTES
    This module requires Administrative level permissions in addition to internet access. Files are downloaded from Microsoft's GitHub and Directly from the PSGallery. 
    Third Party Software:
        ScreenConnect - Downloaded from parentCompany-git.screenconnect.com
    .OUTPUTS
    This function does not return any output, but it will modify the server configuration and install necessary tools.
    #>
$Path = "C:\Temp"
if (!(Test-Path $Path)){
    New-Item -itemType Directory -Path C:\ -Name Temp
}
else{
    Write-Host "Folder already exists"
}

if ($psVersionTable.PSVersion.Major -ne 7){
Write-Output "Installing PowerShell 7"
## Using Invoke-RestMethod
$webData = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
## Using Invoke-WebRequest
$webData = ConvertFrom-JSON (Invoke-WebRequest -uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest")
## The release download information is stored in the "assets" section of the data
$assets = $webData.assets
## The pipeline is used to filter the assets object to find the release version we want
$asset = $assets | where-object { $_.name -match "win-x64" -and $_.name -match ".msi"}
## Download the latest version into the same directory we are running the script in
write-output "Downloading $($asset.name)"
Invoke-WebRequest $asset.browser_download_url -OutFile "$pwd\$($asset.name)"
msiexec.exe /package PowerShell-7.5.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1
Write-Output "Install of PowerShell 7 Completed"
}

Write-Output "Installing PowerShell Modules"
if (!(Get-PackageProvider -Name NuGet -Force)){Install-PackageProvider -Name NuGet -Force}
if (!(Get-PSResourceRepository -Name PSGAllery | Select-Object -Property Trusted) -ne "True"){Set-PSResourceRepository -Name PSGallery -Trusted}
Install-PSResource -Name Az -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph.Beta -Scope AllUsers -Verbose
Install-PSResource  ExchangeOnlineManagement -Scope AllUsers -Verbose
Write-Output "PowerShell Module Install Completed"


Write-Output "Enrolling into Azure Arc"
$azureAplicationId ="cd58df38-bda7-4ffa-9d3d-49ab4cb0eb1f"
$azureTenantId= "graphTenantID"
$azurePassword = ConvertTo-SecureString "$AzureARC" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal
Connect-AzConnectedMachine -ResourceGroupName "AzureARC_parentCompanyEAST" -Name "$env:ComputerName" -Location "EastUS" -subscriptionid "azSubsription"
Write-Output "Completed Azure Arc Enrollment"
Start-DefenderAudit
}
function Start-ConfigureServerTLS{
    <#
    .SYNOPSIS
    #This configures TLS 1.2 on Windows Server 2012 and later.
    .DESCRIPTION
    This configures TLS 1.2 on Windows Server 2012 and later. It was shamelessly stolen from https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-tls-enforcement
    .COMPONENT
    Windows Server, TLS 1.2
    .EXAMPLE
    Start-ConfigureServerTLS
    .NOTES
    General notes
    This function requires Administrative level permissions in addition to internet access. Files are downloaded from Microsoft's GitHub and Directly from the PSGallery.
    .LINK
    https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-tls-enforcement
    .OUTPUTS
    This function does not return any output, but it will modify the server configuration to enable TLS 1.2
    #>
        $rebootRequired = $false
        If (-Not (Test-Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319')){
            New-Item 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Force | Out-Null
            $rebootRequired = $true
        }
        New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SystemDefaultTlsVersions' -Value '1' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -PropertyType 'DWord' -Force | Out-Null
        If (-Not (Test-Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319')){
            New-Item 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Force | Out-Null
            $rebootRequired = $true
        }
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SystemDefaultTlsVersions' -Value '1' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -PropertyType 'DWord' -Force | Out-Null
        If (-Not (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server')){
            New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force | Out-Null
            $rebootRequired = $true
        }
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value '1' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'DisabledByDefault' -Value '0' -PropertyType 'DWord' -Force | Out-Null
        If (-Not (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client')){
            New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force | Out-Null
            $rebootRequired = $true
        }
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' -Value '1' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'DisabledByDefault' -Value '0' -PropertyType 'DWord' -Force | Out-Null
        if ($rebootRequired -eq $true){
        $return = Write-Host 'TLS 1.2 has been enabled. You must restart the Windows Server for the changes to take affect.' -ForegroundColor Cyan
        }
        else{
            $return = Write-Host 'TLS 1.2 is already enabled.' -ForegroundColor Green
        }
return $return
}
function Start-DefenderAudit{
    <#
    .SYNOPSIS
        This function checks the status of Windows Defender and the Firewall on the local machine.
    .DESCRIPTION
        The function checks if Windows Defender is running and enabled, and if the Firewall service is running
        It installs Windows Defender if it is not present, and enables it if it is disabled.
        It also checks the status of the Firewall service and enables it if it is not running.
    .COMPONENT
        Windows Defender, Firewall
    .EXAMPLE
        Start-DefenderAudit
        This command checks the status of Windows Defender and the Firewall on the local machine.
    .NOTES
        This function requires administrative privileges to install Windows Defender and check service statuses.
        It uses the Get-CimInstance cmdlet to query the status of Windows Defender and the Firewall service.
    .LINK
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.cim
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service
    .OUTPUTS
        This function does not return any output, but it will write messages to the console indicating the status of Windows Defender and the Firewall.
        If Windows Defender is not installed, it will indicate that a reboot is required to complete the installation.
        If Windows Defender is enabled, it will indicate that it is running.
        If the Firewall service is not running, it will indicate that it needs to be started.
    #>
    $runningAV = Get-CimInstance -namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Select-Object *
    if ($runningAV.displayName -eq 'Windows Defender' -OR $null -eq $runningAV){
    $osCaption = Get-CimInstance -ClassName CIM_OperatingSystem  | Select-Object caption
        if($osCaption -like "*Server*"){
            Write-output "$($env:COMPUTERNAME) is a Server. Using those methods"
            $defender = get-windowsFeature -name Windows-Defender
            IF ($defender.InstallState -ne "Installed"){
                $needsReboot = $true
                Install-WindowsFeature -Name Windows-Defender -Verbose}
            if (!(Get-Service -name windefend -ErrorAction SilentlyContinue)){Write-Output "Defender Service Not Installed"}
            else{
                Write-Output "Defender Service Installed"
                    $service = Get-Service -name windefend
                    If ($service.State -ne "Running"){
                        Write-Output "Defender Service Not Running"
                    }
                }
            if (!(Get-Service -name mpssvc -ErrorAction SilentlyContinue)){Write-Output "Firewall Service Not Installed"}
            else{
            Write-Output "Firewall Service Installed"
                $service = Get-Service -name mpssvc
                If ($service.State -ne "Running"){
                    Write-Output "Firewall Service Not Running"
                }
            }
            if ($needsReboot){Write-output "$($env:COMPUTERNAME) requires a reboot to install Defender"}}
        #If not a Server
        else{
            Write-output "$($env:COMPUTERNAME) is a Workstation or Laptop. Using those methods"
            try{$defenderStatus = Get-MPComputerStatus | Select-Object *
                IF ($defenderStatus.AntivirusEnabled -eq $true){
                    Write-Output "$($env:COMPUTERNAME) AV status is enabled"
                }
                Else{
                    Write-Output "$($env:COMPUTERNAME) AV status is not enabled"
                    Set-MpPreference -DisableRealtimeMonitoring $false -Verbose
                    Write-Output "$($env:COMPUTERNAME) AV status is now enabled"

                }
                If($defenderStatus.IoavProtectionEnabled -eq $true){
                    Write-Output "$($env:COMPUTERNAME) Firewall status is enabled"
                }
                Else{
                    Write-Output "$($env:COMPUTERNAME) Firewall status is not enabled"
                    Set-MpPreference -DisableIOAVProtection  $false -Verbose
                    Write-Output "$($env:COMPUTERNAME) Firewall status is now enabled"
                }
            
            }
            catch{
                Write-output "Defender not Present"
                Get-AppxPackage Microsoft.SecHealthUI -AllUsers | Reset-AppxPackage -Verbose
                Write-output "Re-Attemmpt Start-DefenderAudit"
            }
        }
    }
    Else{
        Write-Output "$($env:COMPUTERNAME) is using $($runningAV.displayName)"
        Write-Output $runningAV
    }
}
function Start-FullNetTest{
    <#
    .SYNOPSIS
        This function tests connectivity to specified remote domain controllers on essential ports.
    .DESCRIPTION
        The function uses Test-NetConnection to check connectivity on various ports required for Active Directory operations.
    .COMPONENT
        PowerShell, Test-NetConnection
    .PARAMETER target
        The IP or hostname of the remote domain controllers to test.
    .EXAMPLE
        Start-FullNetTest -target "dc1.domain.com"
        This command tests connectivity to the domain controller at dc1.domain.com on essential ports.
    .EXAMPLE
        Start-FullNetTest -target "12.76.23.01"
        This command tests connectivity to the domain controller at 12.76.23.01 on essential ports.
    .NOTES
        This function requires PowerShell 5.0 or higher.
        It is designed to be run on a Windows machine with network connectivity to the target domain controllers
        It will output the results of the connectivity tests, including whether the ping and TCP tests succeeded.
    .LINK
        https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection
    .OUTPUTS
        This function returns a collection of PSCustomObjects containing the results of the connectivity tests.
        Each object includes the target, source address, interface alias, interface index, port name,
        port number, ping success status, name resolution success status, TCP test success status,
        resolved address, remote address, and route information.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position = 0,HelpMessage = "Enter the IP or hostname of the remote domain controllers to test." )]
        [ValidateNotNullOrEmpty()]
        [string]$target
    )

        $trackingResult = @()
        # Define the list of ports you'd like to test.
        $Ports = @(
            [PSCustomObject]@{ PortName = "DNS (TCP 53)"; PortNumber = 53 }
            [PSCustomObject]@{ PortName = "Kerberos (TCP 88)"; PortNumber = 88 }
            [PSCustomObject]@{ PortName = "LDAP (TCP 389)"; PortNumber = 389 }
            [PSCustomObject]@{ PortName = "LDAP GC (TCP 3268)"; PortNumber = 3268 }
            [PSCustomObject]@{ PortName = "SMB (TCP 445)"; PortNumber = 445 }
            [PSCustomObject]@{ PortName = "RPC Endpoint Mapper (TCP 135)"; PortNumber = 135 }
            [PSCustomObject]@{ PortName = "RPC Dynamic Ports (TCP 49152-65535) 1"; PortNumber = 42069 }
            [PSCustomObject]@{ PortName = "RPC Dynamic Ports (TCP 49152-65535) 2"; PortNumber = 49200 }
            [PSCustomObject]@{ PortName = "RPC Dynamic Ports (TCP 49152-65535) 3"; PortNumber = 49303 }
        )
        # Testing each of the defined ports.
        foreach ($PortName in $Ports) {
            $port = $PortName.PortNumber
            Write-Host "Testing $($PortName.PortName) on port $Port..."
            try{
                $pingResult = Test-NetConnection -ComputerName "$target" -Port $Port -errorAction stop
            }
            catch{
                Write-Warning "Failed to connect to $target on port $Port. Error: $_"
                $pingResult = $null
            }
            ForEach ($resolvedAddress in $pingResult.ResolvedAddresses.IPAddressToString){
                [string]$resolvedAddressList += $resolvedAddress , ", " -join ""
            }
            $trackingResult += [PSCustomObject]@{
            Target              = "$target"
            SourceAddress       = $pingResult.SourceAddress
            InterfaceAlias      = $pingResult.InterfaceAlias
            InterfaceIndex      = $pingResult.InterfaceIndex
            PortName            = $PortName.PortName
            PortNumber          = $PortName.PortNumber
            PingSucceeded       = $pingResult.PingSucceeded
            NameResolution      = $pingResult.NameResolutionSucceeded
            TCPTestSucceeded    = $pingResult.TcpTestSucceeded
            ResolvedAddress     = $resolvedAddressList.TrimEnd(", ")
            RemoteAddress       = $pingResult.RemoteAddress
            Route               = "N/A"
            }
        }
        $traceRouteResult = Test-NetConnection -ComputerName "$target" -TraceRoute
        ForEach ($resolvedAddress in $traceRouteREsults.ResolvedAddresses.IPAddressToString){
            [string]$resolvedAddressList += $traceRouteResults.ResolvedAddresses.IPAddressToString + ", "
        }
        ForEach ($hop in $traceRouteResults.TraceRoute){
            [string] $hopList += $hop + ", "
        }
            $trackingResult += [PSCustomObject]@{
            Target              = "$target"
            SourceAddress       = $traceRouteResult.SourceAddress
            InterfaceAlias      = $traceRouteREsult.InterfaceAlias
            InterfaceIndex      = $traceRouteResult.InterfaceIndex
            PortName            = "Trace Route"
            PortNumber          = "N/A"
            PingSucceeded       = $traceRouteResult.PingSucceeded
            NameResolution      = $traceRouteResult.NameResolutionSucceeded
            TCPTestSucceeded     = $traceRouteResult.TcpTestSucceeded
            ResolvedAddress     = $resolvedAddressList.TrimEnd(", ")
            RemoteAddress       = $traceRouteResult.RemoteAddress
            Route               = $hopList.TrimEnd(", ")
            }
        return $trackingResult
}
function Start-MoveVMDatastore {
    <#
    .SYNOPSIS
    Moves a virtual machine to a different datastore in vCenter.
    .DESCRIPTION
    This script connects to a vCenter server, prompts for a virtual machine name,
    and moves the specified VM from one datastore to another. It provides progress updates
    during the migration process.
    .COMPONENT
    VMware PowerCLI, vCenter Server
    .PARAMETER vmNamestar
    The name of the virtual machine to be moved.
    .PARAMETER vCenterName
    The vCenter server to connect to.
    .PARAMETER sourceDatastoreName 
    The name of the source datastore from which the VM will be moved.
    .PARAMETER destinationDatastoreName
    The name of the destination datastore to which the VM will be moved.
    .PARAMETER credential
    The vCenter server credential used for authentication.
    .PARAMETER silent
    Set to `$true to suppress progress output.
    .EXAMPLE
    Start-MoveVMDatastore -vmName "MyVM" -vCenterName "vcenter.company.com" -sourceDatastoreName "SourceDatastore" -destinationDatastoreName "DestinationDatastore" -credential $credential
    .EXAMPLE
    Start-MoveVMDatastore -vmName "MyVM" -vCenterName "vcenter.company.com" -sourceDatastoreName "SourceDatastore" -destinationDatastoreName "DestinationDatastore" -credential $credential -silent $true
    .EXAMPLE
    Start-MoveVMDatastore -vmName "MyVM" -vCenterName "vcenter.company.com" -sourceDatastoreName "SourceDatastore" -destinationDatastoreName "DestinationDatastore" -credential $credential -silent $false
    .NOTES
    This script requires VMware PowerCLI to be installed and configured.
    It also requires appropriate permissions to move virtual machines between datastores in vCenter.
    .LINK
    https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core
    .LINK
    https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.common
    .OUTPUTS
    This script returns the task view of the migration process, including the percent complete and state of the task.
    If the migration is successful, it will output a success message. If it fails, it will throw an error with the failure reason.
    If the VM is not found in the source datastore, it will throw an error indicating that the VM was not found.
    If the source or destination datastore cannot be retrieved, it will throw an error indicating the issue.
    If the connection to the vCenter server fails, it will throw an error indicating the connection issue.
    If the required modules are not installed or imported, it will throw an error indicating the issue.
    If the VM cannot be retrieved, it will throw an error indicating the issue.
    If the migration task is cancelled or fails, it will throw an error indicating the failure status.
    If the VM is successfully moved, it will return the task view of the migration process.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,    HelpMessage = "Enter the Host Server Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$vCenterName,
        [Parameter(Position = 1,    HelpMessage = "Enter the Host Server Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$sourceDatastoreName,        
        [Parameter(Position = 2,    HelpMessage = "Enter the Host Server Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$destinationDatastoreName,
        [Parameter(Position = 3,    HelpMessage = "Enter the vm Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$vmName,
        [Parameter(Position = 4,    HelpMessage = "Enter the vCenter Server Credential.`nExample: vcenter.company.com",  Mandatory = $true)]
        [PSCredential]$credential,
        [Parameter(Position = 5,    HelpMessage = "Set to `$true to suppress progress output.", Mandatory = $false)]
        [Bool]$silent
    )
    #Validate that not only are the modules installed, but that they are imported with a new prefix, as there are conflicts between the VMware PowerCLI modules and the standard PowerShell cmdlets.
    $modules = @("VMWAre.VimAutomation.Core","VMWare.VimAutomation.Common")
    forEach ($module in $modules){
        try{
            Import-Module -Name $module -Prefix "VI" -ErrorAction Stop
        }
        catch {
            throw "Error importing '$module' module. Ensure it is installed and available.`nError: $_"
        }
    }
    # Connect to vCenter
    try{
        Connect-VIServer -Server $vCenterName -Credential $credential -ErrorAction Stop
    }
    catch{
        throw "Error connecting to vCenter server '$vCenterName'`nError: $_"   
    }
    # Retrieve both the destination and source datastores. This is a terminal error and would cause the process at large to fail.
    try{
        $sourceDatastore = Get-Datastore -Name $sourceDatastoreName -ErrorAction Stop
    }
    catch {
        Disconnect-VIServer -Confirm:$false
        throw "Error retrieving source datastore '$sourceDatastoreName'`nError: $_"
    }
    try{
        $destinationDatastore = Get-Datastore -Name $destinationDatastoreName -ErrorAction Stop
    }
    catch {
        Disconnect-VIServer -Confirm:$false
        throw "Error retrieving destination datastore '$destinationDatastoreName'`nError: $_"
    }
    # Retrieve the virtual machine object
    try{
        $vm = Get-VIVM -Name $vmName -ErrorAction SilentlyContinue
    }
    catch {
        Disconnect-VIServer -Confirm:$false
        throw "Error retrieving virtual machine '$vmName'`nError: $_"
    }

    # Validate the selected virtual machine
    if ($vm.ExtensionData.Storage.PerDatastoreUsage.Datastore -contains $sourceDatastore.Id) {
        try {
            Write-Output "Initiating migration of virtual machine '$vmName' to datastore '$($destinationDatastore.Name)'......"
            
            # Start migration asynchronously
            $task = Move-VIVM -VM $vm -Datastore $destinationDatastore -Confirm:$false -RunAsync

            # Monitor migration progress
            do {
                $taskView = Get-VITask | Where-Object { $_.Id -eq $task.Id }
                $percent = $taskView.PercentComplete
                $state = $taskView.State
                if(!($silent)){
                    if ($null -ne $percent) {
                        Write-Progress -Activity "Migrating virtual machine" -Status "$percent% Complete" -PercentComplete $percent
                    } else {
                        Write-Progress -Activity "Migrating virtual machine" -Status "Starting....." -PercentComplete 0
                    }
                }

                Start-Sleep -Milliseconds 200
            } while ($state -eq "In Progress")

            # Migration result
            if ($state -eq "Success") {
                Write-Output "VM '$vmName' has successfully moved." 
            } else {
                Throw "Migration failed or was cancelled. Status: $state"
            }

        } 
        catch {
            throw "Error during VM migration: $_"
        }
    } 
    else {
        # Disconnect from vCenter
        Disconnect-VIServer -Confirm:$false
        throw "VM '$vmName' not found in $($sourceDatastore.Name)."
    }
    # Disconnect from vCenter
    Disconnect-VIServer -Confirm:$false
    return $taskView
}
# Function to handle replacements
function Start-ReplaceNamesAndContent {
    <#
    .SYNOPSIS
    This will review all files and their contents for matching a string, and then will replace the value with a new one.
    .DESCRIPTION
    This will review all files and their contents for matching a string, and then will replace the value with a new one. By and large this can be used for the following things:
    Removing API Keys / PII / Sensitive Data
    Changing Variables
    .COMPONENT
    PowerShell, File System
    .PARAMETER rootPath
    The root path to start the search and replace operation.
    .PARAMETER removalStringValue
    The string value to be removed from file names and contents.
    .PARAMETER replacementStringValue
    The string value to replace the removed value with.
    .PARAMETER valueType
    The type of value being replaced, used for logging purposes.
    .PARAMETER rawJSON
    Use this switch to indicate that the replacements will be provided as raw JSON input.
    .PARAMETER jsonFilePath
    The path to a JSON file containing the replacement values and their types.
    .EXAMPLE
    #The following reviews all files names and contents for 'asldf23lkrewrlzx34530ae3', replaces it with '$apiKey' and sets the valueType of the operation as APIKey. At it's conclusion it reports all files modified.
    Start-ReplaceNamesAndContent -rootPath "C:\tempRepo" -removalStringValue "asldf23lkrewrlzx34530ae3" -replacementStringValue '$apiKey' -valueType 'APIKey'
    .EXAMPLE
    #The following reviews all files names and contents for 'asldf23lkrewrlzx34530ae3', replaces it with '$apiKey' and sets the valueType of the operation as APIKey. At it's conclusion it reports all files modified.
    Start-ReplaceNameAndContent -rootPath "C:\tempRepo" -removalStringValue "asldf23lkrewrlzx34530ae3" -replacementStringValue '$apiKey' -valueType 'APIKey'
    .EXAMPLE
    #The Following Example uses a JSON File to remove all values listed with their assigned replacements, and index them by assigned valueType
    Start-ReplaceNameAndContent -rootPath "D:\Scripts" -json -jsonFilePath "D:\scriptConfigs\ReplacementValues.JSON"
    .NOTES
    You must exercise extreme caution that you do not rename your userDrive. A Future Version will remove that as a possibility.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-content
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-item
    .OUTPUTS
    This function returns a collection of PSCustomObjects containing the details of the files modified during the replacement process.
    Each object includes the properties:
        - File: The full path of the file that was modified.
        - FileNewName: The new name of the file after renaming (if applicable).
        - operation: The type of operation performed (e.g., "File Content Replacement", "File Name Replacement").
        - valueType: The type of value that was replaced (e.g., "API Key", "PII", etc.).
    The output is structured as a collection of PSCustomObjects, each containing the properties:
        - File: The full path of the file that was modified.
        - FileNewName: The new name of the file after renaming (if applicable).
        - operation: The type of operation performed (e.g., "File Content Replacement", "File Name Replacement").
        - valueType: The type of value that was replaced (e.g., "API Key", "PII", etc.).
    If no files are modified, the function will return an empty collection.
    If an error occurs during the process, it will write a warning message to the console indicating the error and continue processing other files.
    If the specified root path does not exist, it will   write an error message and exit the function.
    If the JSON file specified does not exist or cannot be parsed, it will write an error message and exit the function.
    If the raw JSON input cannot be parsed, it will write an error message and exit the function.
    If the content of a file cannot be read or written, it will write a warning message and continue processing other files.
    If the name of a file cannot be changed, it will write a warning message and continue processing other files.
    If the replacement string value is empty, it will skip the replacement for that pattern.
    If the replacement string value is empty, it will skip the replacement for that pattern.
    If the replacement string value is not empty, it will perform the replacement in the file content and file names.
    If the content of a file is successfully modified, it will write the new content back to the file.
    If the name of a file is successfully changed, it will update the file name in the output collection.
    If the content of a file is not modified, it will not add that file to the output collection.
    If the name of a file is not modified, it will not add that file to the output collection.
    If the content of a file is modified, it will add that file to the output collection with the operation type "File Content Replacement".
    If the name of a file is modified, it will add that file to the output collection with the operation type "File Name Replacement".
    It will then output the collection of modified files at the end of the function.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, HelpMessage = "Enter the root path.`nExample: C:\tempRepo")]
        [string]$rootPath = $pwd,
        [Parameter(Position = 1,HelpMessage = "Enter the value to replace.`nExample:\'asldf23lkrewrlzx34530ae3\'",ParameterSetName = "Ad-Hoc",Mandatory = $true)]
        [string]$removalStringValue,
        [Parameter(Position = 2,HelpMessage = "Enter the value to replace the previous value WITH`nExample:\'`$apiKey\'",ParameterSetName = "Ad-Hoc",Mandatory = $true)]
        [string]$replacementStringValue,
        [Parameter(Position = 3, HelpMessage = "Enter the valueType that you are replacing.`nExample: \'API Keys\'",ParameterSetName = "Ad-Hoc", Mandatory = $true)]
        [string]$valueType,
        [Parameter(Position = 4, HelpMessage = "Use this switch to use a JSON file",ParameterSetName = "jsonRaw", Mandatory = $true)]
        [switch]$rawJSON,
        [Parameter(position = 5, HelpMessage = "Enter the Path to the JSON File",ParameterSetName = "JSONFile",Mandatory = $true)]
        [string]$jsonFilePath
    )
    Write-Output "Starting Replacement of Names and Content in $rootPath"
   if ($PSCmdlet.ParameterSetName -eq "Ad-Hoc") {
        # Create a replacement object
        $replacements = @(
            [PSCustomObject]@{
                Pattern           = $removalStringValue
                ReplacementValue = $replacementStringValue
                ValueType        = $valueType
            }
        )
    }
    if ($PSCmdlet.ParameterSetName -eq "JSONFile") {
        # Read the JSON file
        if (-not (Test-Path -Path $jsonFilePath)) {
            Write-Error "The specified JSON file does not exist: $jsonFilePath"
            return
        }
        try {
            $replacements = Get-Content -Path $jsonFilePath | ConvertFrom-Json
        } catch {
            Write-Error "Failed to read or parse the JSON file: $_"
            return
        }
    }
    if ($PSCmdlet.ParameterSetName -eq "jsonRaw") {
        # Read the JSON from the pipeline
        try {
            $replacements = $rawJSON | ConvertFrom-Json
        } catch {
            Write-Error "Failed to parse the JSON input: $_"
            return
        }
    }

    $filesModified = @()

    # --- PASS 1: Content Replacement ---
    Write-Verbose "Starting Pass 1: Content Replacement"
    $filesForContent = Get-ChildItem -Path $rootPath -Recurse -File

    foreach ($file in $filesForContent) {
        try {
            $originalContent = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $currentContent = $originalContent
            $contentChanged = $false

            foreach ($replacement in $replacements) {
                if ($replacement.ReplacementValue -eq ''){
                    $pattern = $replacement.Pattern
                    $currentContent = $currentContent -replace $pattern , $replacement.ReplacementValue
                }
                
                else{
                    if($currentContent -match [regex]::Escape($replacement.Pattern)) {
                    $currentContent = $currentContent -replace [regex]::Escape($replacement.Pattern), $replacement.ReplacementValue
                    }
                }
                    if ($currentContent -ne $originalContent) {
                        $contentChanged = $true
                        $filesModified += [PSCustomObject]@{
                            File        = $file.FullName
                            FileNewName = "N/A"
                            operation   = "File Content Replacement"
                            valueType   = $replacement.ValueType
                        }
                    }
            }
            if ($contentChanged) {
                Set-Content -Path $file.FullName -Value $currentContent -Force -ErrorAction Stop
            }
        }
        catch {
            Write-Warning "An error occurred during content replacement for $($file.FullName): $_"
        }
    }

    # --- PASS 2: Name Replacement ---
    Write-Verbose "Starting Pass 2: Name Replacement"
    $itemsForRenaming = Get-ChildItem -Path $rootPath -Recurse | Sort-Object { $_.FullName.Length } -Descending

    foreach ($item in $itemsForRenaming) {
        $originalPath = $item.FullName
        $currentName = $item.Name
        $newName = $currentName

        # Determine the final name by applying all replacement patterns sequentially
        foreach ($replacement in $replacements) {
            if ($newName -match [regex]::Escape($replacement.Pattern)) {
                $newName = $newName -replace [regex]::Escape($replacement.Pattern), $replacement.ReplacementValue
            }
        }

        # If the calculated new name is different, perform a single rename operation.
        if ($newName -ne $currentName) {
            try {
                Rename-Item -LiteralPath $originalPath -NewName $newName -ErrorAction Stop
                $filesModified += [PSCustomObject]@{
                    File        = $originalPath
                    FileNewName = $newName
                    operation   = if ($item.PSIsContainer) { "Folder Name Replacement" } else { "File Name Replacement" }
                    valueType   = "N/A" # ValueType is ambiguous when multiple patterns could apply.
                }
            }
            catch {
                Write-Warning "Failed to rename '$originalPath' to '$newName'. Error: $_"
            }
        }
    }


    if ($filesModified.count -le 0) {
        Write-Host "No files were modified."
        return
    }
    return $filesModified
}
function Start-SignparentCompanyPsScript {
    <#
    .SYNOPSIS
    This script will sign all of the PowerShell Scripts listed at a provided path.
    
    .DESCRIPTION
    This script will sign all of the PowerShell Scripts listed at a provided path.
    You must have permissions to access the Key Vault in order to access the required secrets.

    
    .PARAMETER Path
    Enter a path to the directory which contains the scripts:
    C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\* 
    
    .EXAMPLE
    #Sign all the PowerShell Scripts that are stored under C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\*
    Start-SignparentCompanyPSsScript 

    #Sign all the PowerShell Scripts that are stored at C:\Temp
    Start-SignparentCompanyPSsScript -Path "C:\Temp"
    .NOTES
    This is for signing all scripts that either need a new signature as they have been updated, have never been signed, or have their certificate expired.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, HelpMessage = "Enter the path of the script to sign, or use \* to sign a wildcarded directory.",ValueFromPipelineByPropertyName)]
        [string[]]$Path = "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\GIT-PowerShell\*"
    )
    [PSCustomObject] $output = @()
    
    $AzContext = Get-AzContext  
    if ($null -eq $AzContext){
        Connect-AzAccount -Subscription 'azSubsription'
    }
    If ($null -eq $codeSigningSecret){
        try{
            $codeSigningSecret = get-azkeyvaultsecret -vaultname KeyVaultName -Name codeSigner -AsPlainText -erroraction SilentlyContinue
        }
        Catch{
            Throw "Failed to retrieve the secret"
            Continue
        }
    }
    $TenantId = 'graphTenantID'
    $ApplicationId = 'd8eb3ee1-5a22-461c-a5ac-da204ae20f74'
    $vaultURI = "https://git-dev.vault.azure.net/"
    $certName = "GIT-CSC-2024"
    If (Test-Path -Path $Path){
        "*.ps1","*.psm1","*.psd1" | ForEach-Object{
            Get-ChildItem -Path $Path -filter $_  -Recurse | ForEach-Object {
                If ((Get-AuthenticodeSignature -FilePath $_.FullName).status -ne "Valid"){
                    $script = “$($_.FullName)"
                    $successString = $response | Select-String -Pattern 'Successful Operations: [0-9]+' -raw
                    $response = azuresigntool sign -kvu "$vaultURI" -kvc $certName -kvi $applicationID -kvs "$codeSigningSecret" --azure-key-vault-tenant-id "$TenantID" -tr http://timestamp.globalsign.com/tsa/advanced -td sha256 “$($_.FullName)"
                    $successString = $response | Select-String -Pattern 'Successful Operations: [0-9]+' -raw
                    if($successString){
                        $successCount = [int] $successString.split(':')[1]
                    }
                    $failedString = $response | Select-String -Pattern 'Failed Operations: [0-9]+' -raw
                    if($failedString){
                        $failedCount = [int] $failedString.Split(':')[1]
                    }
                    
                    if ($failedCount -ne 0){
                        if($successCount -ne 0){
                            $status = "Mixed"
                        }
                        else{
                            $status = "Failed"
                        }
                    }
                    else{
                        if ($succesCount -ne 0){
                            $status = "Successful"
                        }
                        else{
                            $status = "Error"
                        }
                    }
                    $now = Get-DAte -Format "yyyy-MM-dd HH:mm"
                    $output +=[PSCustomObject]@{
                        timeOfSign      =   $now
                        status          =   $status
                        script          =   $script
                    }

                }
            }
        }
    }
    Else{
        Throw "Invalid Path"
        Continue
    }
        switch ($output.count) {
            '0'{Write-Output "No scripts were signed"}
            Default {return $output}
        }

}
function Start-WrapparentCompanyModule{
    <#
        .SYNOPSIS
        This function wraps an parentCompany PowerShell module for Intune deployment.
        .DESCRIPTION
        The function copies the specified parentCompany module to a designated input path, creates an installation script, and then uses IntuneWinAppUtil to create a .intunewin package for deployment.
        .PARAMETER ModuleName
        The name of the parentCompany PowerShell module to be wrapped.
        .PARAMETER modulePath
        The path to the parentCompany PowerShell module on the local machine. Default is set to a specific directory in the user's profile.
        .PARAMETER moduleInputPath
        The path where the module will be copied for wrapping. Default is set to a specific directory in the user's profile.
        .PARAMETER moduleOutputPath
        The path where the wrapped module will be outputted. Default is set to a specific directory in the user's profile.
        .EXAMPLE
        Start-WrapparentCompanyModule -ModuleName "MyparentCompanyModule"
        This command will wrap the specified parentCompany module and create a .intunewin package for deployment.
        .NOTES
        This function requires the IntuneWinAppUtil.exe to be available in the system PATH.
        Ensure that the specified paths exist or are created before running the function.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [Parameter(Mandatory=$false)]
        [string]$modulePath = "$env:USERPROFILE\parentCompany, Inc\GIT IT Support - Documents\General\PowerShell Scripts\parentCompanyRepo\Modules\$ModuleName",
        [Parameter(Mandatory=$false)]
        [string]$moduleInputPath = "$env:USERPROFILE\parentCompany, Inc\GIT IT Support - Documents\General\InTune-Apps\Pre-Wrap\Modules\$ModuleName\",
        [Parameter(Mandatory=$false)]
        [string]$installScriptPath = "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\InTune-Apps\Pre-Wrap\Modules\$ModuleName\",
        [parameter(Mandatory=$false)]
        [string]$moduleOutputPath = "$env:USERPROFILE\parentCompany, Inc\GIT IT Support - Documents\General\InTune-Apps\Post-Wrap\Modules\$ModuleName"
    )
    if (!(Test-Path -Path $modulePath)){
        throw "Module path does not exist: $modulePath"
    }
    if (!(Test-Path -Path $moduleInputPath)){
        Write-Warning "Module input path does not exist: $moduleInputPath"
        New-Item -ItemType Directory -Path $moduleInputPath -Force | Out-Null
        if (Test-Path -Path $moduleInputPath){
            Write-Output "Module input path created successfully: $moduleInputPath"
        } else {
            throw "Failed to create module input path: $moduleInputPath"
        }
    }
    if (!(Test-Path -Path $moduleOutputPath)){
        Write-Warning "Module output path does not exist: $moduleOutputPath"
        New-Item -ItemType Directory -Path $moduleOutputPath -Force | Out-Null
        if (Test-Path -Path $moduleOutputPath){
            Write-Output "Module output path created successfully: $moduleOutputPath"
        } else {
            throw "Failed to create module output path: $moduleOutputPath"
        }
    }

    Copy-Item -Path $modulePath -Destination $moduleInputPath -Recurse -Force
    Write-Output "Module $ModuleName copied to input path: $moduleInputPath"
    $installScript = @"
    sourcePath = ".\$moduleName"
    targetPath = "C:\Program Files\PowerShell\Modules\$moduleName"
    if (-not (Test-Path -Path targetPath)) {
        New-Item -ItemType Directory -Path targetPath -Force
    }

    Copy-Item -Path ".\$moduleName\*" -Destination targetPath -Recurse -Force

    Write-Output "Module $moduleName installed successfully to targetPath."
"@
    $installScript = $installScript -replace "sourcePath", "`$sourcePath"
    $installScript = $installScript -replace "targetPath", "`$targetPath"

    New-Item -Path $moduleInputPath -Name "InstallModule.ps1" -ItemType File -Value $installScript -Force | Out-Null
    Write-Output "Install script created at: $moduleOutputPath\InstallModule.ps1"
    $installScriptPath = $moduleInputPath , "\", "InstallModule.ps1" -join ""
    IntuneWinAppUtil -c $moduleInputPath -s $installScriptPath -o $moduleOutputPath 
    if ($LASTEXITCODE -ne 0) {
        throw "IntuneWinAppUtil failed with exit code $LASTEXITCODE"
    }
    Write-Output "IntuneWinAppUtil executed successfully. Output path: $moduleOutputPath"  
   
}
function Start-Windows11Upgrade{
    <#
    .SYNOPSIS
    Starts the Windows 11 Upgrade process using the official upgrade tool.
    .DESCRIPTION
    This function downloads the Windows 11 Upgrade Tool from Microsoft's official site and starts the upgrade process
    with specified arguments.
    .PARAMETER Quiet
    If specified, runs the upgrade in quiet mode without user interaction.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Run the upgrade in quiet mode without user interaction.')]
        [switch]$Quiet,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Directory to store the upgrade tool. Defaults to C:\_Windows_FU\packages.')]
        [string]$Directory = 'C:\_Windows_FU\packages'
    )
    
    $dir = $Directory
    if ($dir -notlike 'C:\*') {
        Write-Host "Directory must be on the C: drive. Defaulting to C:\_Windows_FU\packages."
        $dir = 'C:\_Windows_FU\packages'
    }
    # Ensure the directory exists
    if (!(Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
    # Download the Windows 11 Upgrade Tool
    Write-Host "Downloading Windows 11 Upgrade Tool to $dir..."
    $ProgressPreference = 'SilentlyContinue' # Suppress progress bar
    $ErrorActionPreference = 'Stop' # Stop on errors
    $global:ProgressPreference = 'SilentlyContinue'
    $global:ErrorActionPreference = 'Stop'
    # Define the URL and file path
    $url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
    $file = "$($dir)\Win11Upgrade.exe"
    # Remove the file if it already exists
    Write-Host "Checking for existing upgrade tool..."
    if (Test-Path $file) {
        Write-Host "Existing upgrade tool found at $file. Removing it..."
        # Remove the existing file
        Remove-Item -Path $file -Force
    }
    # Download the upgrade too
    Write-Host "Downloading Windows 11 Upgrade Tool..."
    Invoke-RestMethod -Uri $url -OutFile $file -HttpVersion '1.1' -UseBasicParsing
    if($quiet){
        Write-Host "Running Windows 11 Upgrade Tool in quiet mode..."
        Write-Verbose "Start the upgrade process with quiet mode and other arguments"
        Write-Verbose "Note: The '/quiet' argument is used to run the upgrade without user interaction"
        Write-Verbose "'/auto upgrade' is used to automatically upgrade the system"
        Write-Verbose "'/EULA accept' is used to accept the End User License Agreement"
        Write-Verbose "The '/copylogs $dir' argument is used to copy logs to the specified directory"
        # Start the upgrade process with quiet mode and other arguments
        Write-Host "Starting the upgrade process... This may take some time."
        Start-Process -FilePath $file -ArgumentList "/QuitInstall /SkipEULA /auto upgrade /copylogs $dir" -Wait -NoNewWindow
        Write-Host "Windows 11 Upgrade Tool has been started in quiet mode. Please wait for the upgrade to complete."
        Write-Host "You can check the logs in the specified directory: $dir"
        Write-Host "If you need to interact with the upgrade process, please run this script without the -Quiet parameter."
        Write-Host "Note: The upgrade process may take some time to complete. Please be patient."
        Write-Host "If you encounter any issues, please check the logs in the specified directory: $dir"
    }
    else {
        Write-Host "Running Windows 11 Upgrade Tool..."
        Write-Host "This is not in quiet mode. You will need to interact with the upgrade process."
        Write-Verbose "Start the upgrade process without quiet mode"
        Write-Verbose "This is useful to see the upgrade process and interact with it, and so the user can accept the EULA and be notified of reboots and any other prompts"
        Start-Process -FilePath $file
    }
}
function Uninstall-CimProgram {
    <#
    .SYNOPSIS
    Uninstalls a specified CIM program.
    .DESCRIPTION
    This function uninstalls a CIM program by its name using the Win32_Product class.
    .COMPONENT
    Endpoint
    .PARAMETER CimProgramName
    The name of the CIM program to uninstall.
    .EXAMPLE
    Uninstall-CimProgram -CimProgramName "Example CIM Program"
    Uninstalls the specified CIM program.
    .NOTES
    You must have administrative privileges to run this function and said account must be able to authenticate to the target machine.
    .OUTPUTS
    None. This function performs an uninstallation and does not return any output.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage = "Name of the CIM program to uninstall.",Position = 0)]
        [string]$CimProgramName
    )
    # Check if the CIM program is installed
    $cimProgram = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -eq $CimProgramName }
    if ($null -eq $cimProgram) {
        Write-Host "CIM program '$CimProgramName' is not installed."
        return
    }

    # Uninstall the CIM program
    try {
        $cimProgram.Uninstall() | Out-Null
        return "CIM program '$CimProgramName' has been uninstalled successfully."
    } catch {
        Write-Error "Failed to uninstall CIM program '$CimProgramName'. Error: $_"
    }
}
function Update-CustomField {
    <#
    .SYNOPSIS
    This function updates a custom field in Jira.
    .DESCRIPTION
    This function allows you to update a custom field in Jira by specifying the custom field name, parent ID, new value, and whether to hide it from users. 
    It uses the Jira REST API for the update operation.
    .COMPONENT
    PowerShell, Jira
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER customFieldName
    The name of the custom field to update. This should match the name used in Jira.
    .PARAMETER customFieldParentID
    The parent ID of the custom field option to update. This is usually the ID of the context or parent option.
    .PARAMETER newValue
    The ID of the custom field option to update. This is the specific option ID within the custom field context.
    .PARAMETER hideFromUsers
    Optional parameter to hide the custom field from users. Default is false.
    .EXAMPLE
    Update-CustomField -jiraKey "your_jira_api_key" -customFieldName "Custom Field Name" `
                       -customFieldParentID "12345" -newValue "New Value" -hideFromUsers
    This example updates the custom field with the specified name and parent ID to the new value, and hides it from users.
    .EXAMPLE
    Update-CustomField -jiraKey "your_jira_api_key" -customFieldName "Custom Field Name" `
                       -customFieldParentID "12345" -newValue "New Value"
    This example updates the custom field with the specified name and parent ID to the new value without hiding it from users.
    .NOTES
    This function requires the Get-CustomField function to retrieve the custom field details.
    Ensure that you have the necessary permissions to update custom fields in Jira.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-field-contexts/
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-fields/
    .OUTPUTS
    This function returns the response from the Jira API after updating the custom field.
    If the update is successful, it will output a success message.
    If the custom field is not found, it will throw an error.
    If the update fails, it will throw an error with the failure reason.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Mandatory = $true, HelpMessage = "Name of the custom field to update. This should match the name used in Jira.")]
        [string]$customFieldName,
        [Parameter(Mandatory = $true, HelpMessage = "ID of the custom field option to update. This is the specific option ID within the custom field context.")]
        [string]$newValue,
        [Parameter(Mandatory = $false, HelpMessage = "Use this switch if this is a cascading field child option",ParameterSetName = "ParentID")]
        [switch]$isCascadingChild,
        [Parameter(Mandatory = $false, HelpMessage = "Parent ID of the custom field option to update. This is usually the ID of the context or parent option.",ParameterSetName = "ParentID")]
        [string]$customFieldParentID ,
        [Parameter(Mandatory = $false, HelpMessage = "Optional parameter to hide the custom field from users. Default is false.")]
        [switch]$hideFromUsers
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }

    switch ($hideFromUsers.IsPresent){
        $true{
                    $hidden = $true
        }
        Default {
                    $hidden = $false
        }
    }
    Write-Output "Hidden: $hidden"

    # Get the custom field by name
    $customField    = Get-CustomField -customFieldName $customFieldName -jiraKey $jiraKey
    $contextID      = (Invoke-RestMethod -uri ("https://parentCompany.atlassian.net/rest/api/3/field/",$customField.id , "/contexts" -join "") -Headers $jiraHeader).values.ID

    if ($null -eq $customField) {
        throw "Custom field '$customFieldName' not found."
    }
    if($isCascadingChild){
            $body = @{
            options = @(
                [Ordered]@{
                    disabled    = $hidden
                    optionId    = "$customFieldParentID" 
                    value       = "$newValue"
                }
            )
        } | ConvertTo-Json -Depth 5
    }
    else{
        $body = @{
            options = @(
                [Ordered]@{
                    disabled    = $hidden 
                    value       = "$newValue"
                }
            )
        } | ConvertTo-Json -Depth 5
    }

    # Construct the request URI for updating the custom field option
    $requestURI = "https://parentCompany.atlassian.net/rest/api/3/field/", "$($customField.id)", "/context/", $contextID, "/option" -join""
    # Update the custom field option
    try {
        $response = Invoke-RestMethod -Uri $requestURI  -Headers $jiraHeader -Method Post -Body $body
        Write-Host "Custom field '$customFieldName' updated successfully to '$newValue'."
    } catch {
        throw "Failed to update custom field: $customFieldName. Error: $_"
    }
    return $response
}
SignatureBlock

