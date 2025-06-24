$deviceUserAudit = @()
ForEach ($device in $win10Devices){
    $queryDevice = Get-MgDeviceManagementManagedDevice -Filter "DeviceName eq '$($device.d42DeviceName)'" -ErrorAction SilentlyContinue
    if ($queryDevice) {
        $deviceUser = Get-MgDeviceManagementManagedDeviceUser -ManagedDeviceId $queryDevice.Id -ErrorAction SilentlyContinue
        if ($deviceUser) {
            $deviceUserAudit += [PSCustomObject]@{
                DeviceName                          = $device.d42DeviceName
                UserPrincipalName                   = $deviceUser.UserPrincipalName
                UserDisplayName                     = $deviceUser.DisplayName
                UserOfficeLocation                  = $deviceUser.OfficeLocation
                DeviceManagementState               = $device.intuneStatus
                DeviceWin11Readiness                = $device.win11ready
                DeviceIncompatibilityReason         = $device.incompabilityReason
                DeviceCPUCount                      = $device.cpuCount
                DeviceTotalStorage                  = $device.cpuCoreCount
                DeviceThreadPerCoreCount            = $device.threadPerCore
                DeviceCPUSpeedGHz                   = $device.cpuSpeed
                DeviceTotalMemoryGB                 = $device.RAMSize
                DeviceOSName                        = $device.osName    
            }
        } else {
            $deviceUserAudit += [PSCustomObject]@{
                DeviceName = $device.d42DeviceName
                UserPrincipalName                   = "No user found"
                UserDisplayName                     = "No user found"
                UserOfficeLocation                  = "Derived from Device Discovery:" , " " ,"$($device.officeLocation)" -join ""
                DeviceManagementState               = $device.intuneStatus
                DeviceWin11Readiness                = $device.win11ready
                DeviceIncompatibilityReason         = $device.incompabilityReason
                DeviceCPUCount                      = $device.cpuCount
                DeviceTotalStorage                  = $device.cpuCoreCount
                DeviceThreadPerCoreCount            = $device.threadPerCore
                DeviceCPUSpeedGHz                   = $device.cpuSpeed
                DeviceTotalMemoryGB                 = $device.RAMSize
                DeviceOSName                        = $device.osName    
            }
        }
    } else {
            $deviceUserAudit += [PSCustomObject]@{
                DeviceName                          = $device.d42DeviceName
                UserPrincipalName                   = "No user found"
                UserDisplayName                     = "No user found"
                UserOfficeLocation                  = "Derived from Device Discovery:" , " " ,"$($device.officeLocation)" -join ""
                DeviceManagementState               = "Device Not In InTune"
                DeviceWin11Readiness                = $device.win11ready
                DeviceIncompatibilityReason         = $device.incompabilityReason
                DeviceCPUCount                      = $device.cpuCount
                DeviceTotalStorage                  = $device.cpuCoreCount
                DeviceThreadPerCoreCount            = $device.threadPerCore
                DeviceCPUSpeedGHz                   = $device.cpuSpeed
                DeviceTotalMemoryGB                 = $device.RAMSize
                DeviceOSName                        = $device.osName    
        }
    }
}
SignatureBlock

