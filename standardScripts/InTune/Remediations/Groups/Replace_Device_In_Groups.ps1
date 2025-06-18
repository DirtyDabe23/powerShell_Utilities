
$oldDevice = Read-Host -Prompt "Enter the device hostname that is being replaced"
$newDevice = Read-Host -Prompt "Enter the new device hostname that is replacing the old device"


$oldDeviceGraph = get-MgBetaDevice -search "DisplayName:$oldDevice" -consistencylevel:eventual
$newDeviceGraph = get-MgBetaDevice -search "DisplayName:$newDevice" -consistencylevel:eventual
$groups = Get-MgDeviceMemberOf -DeviceID $oldDeviceGraph.id 

ForEach ($group in $groups)
    {
    $currentGroup = Get-MGBetaGroup -GroupId $group.ID
    If ($currentGroup.GroupType -like "*Dynamic*")
    {
        $null
    }
    else 
    {
        New-MgGroupMember -GroupID $group.ID -DirectoryObjectId $newDeviceGraph.ID
    } 
    }
# SIG # Begin signature block#Script Signature# SIG # End signature block




