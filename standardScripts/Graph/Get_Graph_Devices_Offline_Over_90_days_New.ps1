$notSeenFor90 = Get-MGDeviceManagementMAnagedDevice -all | Where-Object {($_.LastSyncDateTime -le $((Get-Date).AddDays(-90)))} | Select-Object DeviceName , OperatingSystem , Manufacturer , Model , UserDisplayName, UserPrincipalName


SignatureBlock

