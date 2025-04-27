$dispName = Read-Host "Enter the display name of the device"
$device = Get-MGBetaDevice -Filter "DisplayName eq '$dispName'"
$id = $device.deviceID
$mgDeviceManagedDevice = Get-MGDeviceManagementManagedDevice -filter "AzureADDeviceID eq '$id'"
Get-MGDeviceManagementManagedDeviceUser -ManagedDeviceID $mgDeviceManagedDevice.ID 
# SIG # Begin signature block#Script Signature# SIG # End signature block




