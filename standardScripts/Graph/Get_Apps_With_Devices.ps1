$DetectedApps = Get-MgDeviceManagementDetectedApp -all | where-object {($_.Platform -eq "windows")} | sort-object -Property DisplayName

ForEach ($detectedApp in $DetectedApps)
{
    Write-Host "Assessing: $($detectedapp.DisplayName)"
    $appObject = @();
    $devices = Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId $detectedApp.ID  -All | Select-Object -property "ID","DeviceName","EmailAddress"
    ForEach ($device in $devices)
    {
        $appObject += [PSCustomObject]@{
        appName           = $detectedapp.DisplayName
        deviceID          = $device.Id
        deviceDisplayName = $device.DeviceName
        deviceUser        = $device.EmailAddress   
        }    
    }
    $appObject | export-csv -path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Documentation\InTune\App_Reports\$($detectedapp.DisplayName)-$($detectedapp.id).csv" -Force
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





