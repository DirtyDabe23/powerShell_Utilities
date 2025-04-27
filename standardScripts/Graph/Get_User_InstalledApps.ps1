Connect-MgGraph -NoWelcome
$userToCheck = Read-Host -Prompt "Enter the User Principal Name for the user you want to audit for application installs and their respective devices"
$DetectedApps = Get-MgDeviceManagementDetectedApp -all | where-object {($_.Platform -eq "windows")} | sort-object -Property devicecount -Descending
$appObject = @();

ForEach ($detectedApp in $DetectedApps)
{
    Write-Host "Assessing: $($detectedApp.DisplayName)"
    $devices = Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId $detectedApp.ID  -All | Where-Object {($_.EmailAddress -eq $userToCheck)} |Select-Object -property "ID","DeviceName","EmailAddress"
    ForEach ($device in $devices)
    {
        $appObject += [PSCustomObject]@{
        userChecked       = $userToCheck
        appName           = $detectedApp.DisplayName
        appID             = $detectedApp.Id
        appVersion        = $detectedApp.Version
        deviceID          = $device.Id
        deviceDisplayName = $device.DeviceName  
        }    
    }
}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+"."+$userToCheck+".csv"

$appObject = $appObject | Sort-Object -Property @{Expression = "appName"; Descending = $False} , @{Expression = "appVersion"; Descending = $true} , @{Expression = "deviceDisplayName"; Descending = $False}
$appObject | format-table -AutoSize
$appObject | Export-CSV -path $filePath
Write-Host "Your CSV Output is located in $filepath"

# SIG # Begin signature block#Script Signature# SIG # End signature block



