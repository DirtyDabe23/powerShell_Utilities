$initialLocation = Get-Location
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
If (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID"){Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID" | Remove-Item -Force -Verbose}
If (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger"){Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger" | Remove-Item -Force -Verbose}
If(Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"){Get-Item "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"  | REmove-ITem -Force -Recurse}




#Remove the InTune Certificate
Set-Location "Cert:\LocalMachine\CA"
Get-ChildItem | Where {($_.subject -like 'CN=Microsoft Intune MDM Device CA')} | Remove-Item -Force -Verbose
dsregcmd /leave

Set-Location "HKCU:\Software\Microsoft\OneDrive\Accounts\

Set-Location $initialLocation
# SIG # Begin signature block#Script Signature# SIG # End signature block



