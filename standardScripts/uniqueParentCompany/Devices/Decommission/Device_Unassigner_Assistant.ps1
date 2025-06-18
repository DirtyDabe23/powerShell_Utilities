#The following requires running Connect-MGGraph without certificate based authentication. This is likely due to permissions around the app requiring expansion
$searchDevice = Read-Host "Enter the hostname of the device to clear the primary user for"
$managedDevice = Get-MgDeviceManagementManagedDevice -filter "devicename eq '$searchDevice'" | Select-Object *
$inTuneDeviceID = $managedDevice.ID
$graphApiVersion = "beta"
$Resource = "deviceManagement/managedDevices('$IntuneDeviceId')/users/`$ref"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
Invoke-MgGraphRequest -Method DELETE $uri
# SIG # Begin signature block#Script Signature# SIG # End signature block



