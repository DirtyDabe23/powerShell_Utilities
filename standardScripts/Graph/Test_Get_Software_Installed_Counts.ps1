$DetectedApps = Get-MgDeviceManagementDetectedApp -all | where-object {($_.Platform -eq "windows")}

$DeviceAppDetect = $DetectedApps | ForEach-Object {

$Output = New-Object psobject

$Output | Add-Member -MemberType NoteProperty -Name DetectedAppId -Value $_.Id

$Output | Add-Member -MemberType NoteProperty -Name DisplayName -Value $_.DisplayName

$Output | Add-Member -MemberType NoteProperty -Name DeviceName -Value $Device.DeviceName

$output

}

$DeviceAppDetect | Select-Object -Property DetectedAppId, DisplayName -ExpandProperty DeviceName | Select-Object DetectedAppId, DisplayName, @{Name="DeviceName";Expression={$_}} | `
Select-Object * | Export-csv -NoTypeInformation C:\temp\Deviceapp.csv
# SIG # Begin signature block#Script Signature# SIG # End signature block



