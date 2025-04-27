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
        $appObject += [PSCustomObject]@{
        appName           = $detectedApp.DisplayName
        appID             = $detectedApp.Id
        appVersion        = $detectedApp.Version
        appDeviceCount    = $detectedApp.DeviceCount
        deviceID          = $device.Id
        deviceDisplayName = $device.DeviceName
        deviceUser        = $device.EmailAddress   
        }    
    }
}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+"."+$AppToCheck+".csv"

$appObject = $appObject | Sort-Object -Property @{Expression = "appVersion"; Descending = $True}, @{Expression = "appDeviceCount"; Descending = $True} , @{Expression = "deviceUser"; Descending = $False} , @{Expression = "deviceDisplayName"; Descending = $False}
$appObject | format-table -AutoSize
$appObject | Export-CSV -path $filePath


$groupToAdd = "GLOBAL: CC - $appToCheck Devices" 
$groupMailNickName = $groupToAdd.replace(" ","")
$groupMailNickName = $groupMailNickName.replace(":","")
$groupMailNickName = $groupMailNickName.replace("-","")

$groupID = (Get-MGGroup -All -search "DisplayName:$groupToAdd" -ConsistencyLevel:eventual -erroraction Stop).Id 


If ($groupID -eq $null)
{
    Write-Output "The Group is not yet made. Creating the Group now."
    New-Mggroup -displayName $groupToAdd -mailenabled:$false -MailNickName $groupMailNickName -securityenabled
    While ($groupID -eq $null)
    {
        $groupID = (Get-MGGroup -All -search "DisplayName:$groupToAdd" -ConsistencyLevel:eventual).Id
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | Waiting for [$grouptoAdd] to become available."
    }
}


$counter = 1

$failedDevices = @();

ForEach ($device in $appObject)
{
    try{
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | $counter/$($appObject.count) | Adding: $($device.deviceDisplayName)"
        $IDs = (Get-MGDevice -Search "displayname:$($device.deviceDisplayName)" -ConsistencyLevel:eventual -erroraction stop).id 
        ForEach ($id in $IDs)
        {  
        New-MgGroupMember -groupID $groupID -DirectoryObjectId $ID -ErrorAction Stop
        }
    }
    catch{
        $failedDevices += [PSCustomObject]@{
            deviceDisplayName = $device.deviceDisplayName
            deviceUser        = $device.deviceUser
            deviceUserOffice  = $device.deviceUserOffice
            }    
    }
    $counter++
}


Write-Output "The devices which were not added to the group are as follows:`n$failedDevices"
# SIG # Begin signature block#Script Signature# SIG # End signature block



