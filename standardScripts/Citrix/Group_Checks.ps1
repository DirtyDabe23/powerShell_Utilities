$host.ui.RawUI.WindowTitle = "Citrix Audit"
$citrixCompuData = Import-CSV -Path C:\Temp\Citrix.csv
 
Connect-MgGraph -NoWelcome
$AppToCheck = "Citrix"
$DetectedApps = Get-MgDeviceManagementDetectedApp -all | where-object {($_.Platform -eq "windows") -and ($_.DisplayName -like "*$AppToCheck*") } | sort-object -Property devicecount -Descending
$appObject = @();
$usersFormatted = @();
$usersNotInGroup = @();
$usersInGroup = @();


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

ForEach ($user in $appObject.deviceUser)
{
    If ($null -eq $user)
    {
        $null
    }
    ElseIf ($user -ne $null)
    {

        $usersFormatted+=[PSCustomObject]@{
            displayName = $user.split('@')[0]
        }
    }
}

$citrixDetectedUsers = $usersFormatted.DisplayName
$citrixCompuDataUsers = $citrixCompuData.'Associated User'

$usersNotInGroup = $citrixCompuDataUsers | Where {$citrixDetectedUsers -notcontains $_} | Sort

$usersInGroup = $citrixCompuDataUsers | Where {$citrixDetectedUsers -contains $_} | Sort
# SIG # Begin signature block#Script Signature# SIG # End signature block



