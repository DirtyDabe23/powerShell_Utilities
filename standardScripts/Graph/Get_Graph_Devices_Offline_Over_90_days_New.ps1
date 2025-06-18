$notSeenFor90 = Get-MGDeviceManagementMAnagedDevice -all | Where-Object {($_.LastSyncDateTime -le $((Get-Date).AddDays(-90)))} | Select-Object DeviceName , OperatingSystem , Manufacturer , Model , UserDisplayName, UserPrincipalName


# SIG # Begin signature block#Script Signature# SIG # End signature block



