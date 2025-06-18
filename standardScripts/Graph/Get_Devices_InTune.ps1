$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+".MGDevices"+".csv"

Get-MGDevice -All -ConsistencyLevel:eventual | Where-Object {($_.OperatingSystem -eq "Windows")} | Export-CSV $filePath


$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+".MGDevices"+".csv"
Get-MgDeviceManagementManagedDevice -all | Where-Object {($_.OperatingSystem -eq "Windows")} | Export-CSV $filePath

# SIG # Begin signature block#Script Signature# SIG # End signature block



