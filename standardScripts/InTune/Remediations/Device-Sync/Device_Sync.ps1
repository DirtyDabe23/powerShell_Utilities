    $deviceName = Read-Host "Enter the device name"
    $myDevice = Get-MgDeviceManagementManagedDevice -filter "devicename eq '$deviceName'"
    $priorSync = (Get-MgDeviceManagementManagedDevice -filter "devicename eq '$deviceName'").LastSyncDateTime.ToLocalTime()
    Write-Output "Last Sync was at: $priorSync"
    Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $myDevice.id
    $i = $true
    while($i)
    {
        $currentSync = (Get-MgDeviceManagementManagedDevice -filter "devicename eq '$deviceName'").LastSyncDateTime.ToLocalTime()
        if ($currentSync -eq $priorSync)
        {
            Write-Output "Waiting for Sync at: $(Get-Date)"
            Start-Sleep -Seconds 5
        }
        else {
            Write-Output "$deviceName synched at $currentSync"
            $i = $false
        }
    }
# SIG # Begin signature block#Script Signature# SIG # End signature block




