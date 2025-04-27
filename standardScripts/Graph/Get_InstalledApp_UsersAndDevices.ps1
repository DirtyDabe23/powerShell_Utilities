Connect-MgGraph -NoWelcome
$AppToCheck = Read-Host -Prompt "Enter the displayname for the application you are looking for. It will return partial matches."
$DetectedApps = Get-MgDeviceManagementDetectedApp -all | where-object {($_.Platform -eq "windows") -and ($_.DisplayName -like "*$AppToCheck*") } | sort-object -Property devicecount -Descending
$appObject = @();

ForEach ($detectedApp in $DetectedApps)
{
    Write-Host "Assessing: $($detectedApp.DisplayName)"
    $devices = Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId $detectedApp.ID  -All | Select-Object -property "ID","DeviceName","EmailAddress"
    ForEach ($device in $devices)
    {
    try {
        $OfficeLocation = (Get-MGBetaUser -userid $device.emailaddress -erroraction Stop ).OfficeLocation  
    }
    catch {
        $OfficeLocation = "Unknown"
    }
    
    
        $appObject += [PSCustomObject]@{
        appName           = $detectedApp.DisplayName
        appID             = $detectedApp.Id
        appVersion        = $detectedApp.Version
        appDeviceCount    = $detectedApp.DeviceCount
        deviceID          = $device.Id
        deviceDisplayName = $device.DeviceName
        deviceUser        = $device.EmailAddress
        deviceUserOffice  = $OfficeLocation   
        }    
    }
}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+"."+$AppToCheck+".csv"

$appObject = $appObject | Sort-Object -Property @{Expression = "appVersion"; Descending = $True}, @{Expression = "appDeviceCount"; Descending = $True} , @{Expression = "deviceUser"; Descending = $False} , @{Expression = "deviceDisplayName"; Descending = $False}
$appObject | format-table -AutoSize
$appObject | Export-CSV -path $filePath
Write-Host "Your CSV Output is located in $filepath"



# SIG # Begin signature block#Script Signature# SIG # End signature block



