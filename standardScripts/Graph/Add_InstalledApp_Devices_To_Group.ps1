Connect-MGGraph -NoWelcome
$groupToAdd = Read-Host -Prompt "Enter the displayname for the Group you want to add members to"
$groupMailNickName = $groupToAdd.replace(" ","")
$groupMailNickName = $groupMailNickName.replace(":","")
$groupMailNickName = $groupMailNickName.replace("-","")
Try
{
    $groupID = (Get-MGGroup -search "DisplayName:$groupToAdd" -ConsistencyLevel:eventual -erroraction Stop).Id 
}

Catch
{
    Write-Output "The Group is not yet made. Creating the Group now."
    New-Mggroup -displayName $groupToAdd -mailenabled:$false -MailNickName $groupMailNickName -securityenabled
    $groupID = (Get-MGGroup -search "DisplayName:$groupToAdd" -ConsistencyLevel:eventual).Id

}
$counter = 1

$failedDevices = @();

ForEach ($device in $appObject)
{
    try{
        $currTime = Get-Date -format "HH:mm"
        Write-Host "[$($currTime)] | $counter/$($appObject.count) | Adding: $($device.deviceDisplayName)"
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


Write-Output "The devices which were not added to the group as as follows:`n$failedDevices"
# SIG # Begin signature block#Script Signature# SIG # End signature block



