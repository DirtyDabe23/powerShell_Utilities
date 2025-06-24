#The following requires running Connect-MGGraph without certificate based authentication. This is likely due to permissions around the app requiring expansion
$managedDevice = Get-MgDeviceManagementManagedDevice -filter "devicename eq 'Laptop-1117'" | Select-Object *
$inTuneDeviceID = $managedDevice.ID
(Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/beta/deviceManagement/managedDevices/$InTuneDeviceID/users).value.userPrincipalName
SignatureBlock

