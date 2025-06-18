$groups = Get-MgBetaGroup -all -consistencylevel $eventual | sort -Property displayName


$groupData = @()

ForEach ($group in $groups)
{
    $members = Get-MGBetaGroupMember -GroupID $group.Id | select additionalproperties -ExpandProperty additionalproperties
    $memberTypes = $members.'@odata.type' | select -Unique 

    If ($memberTypes.count -eq 1)
    {
        
        $memberType = $memberTypes.split('.')[2]
        $memberTypeLength = $memberType.length
        $memberTypeLength = $memberTypeLength - 1
        $memberType = $MemberType.SubString(0,1).ToUpper() + $MemberType.SubString(1,$memberTypeLength)
    }
    elseIf ($memberTypes.count -lt 1)
    {
        $memberType = "Empty"
    }
    Else{
        $memberType = "Mixed"
    }

    $groupData += [PSCustomObject]@{
        ID          =   $group.ID 
        groupName   =   $group.DisplayName
        memberType  =   $memberType
        synching    =   $group.OnPremisesSyncEnabled
        onPremSID   =   $group.OnPremisesSecurityIdentifier
    }

}

$newGroupInfo = @()

ForEach ($group in $groupData)
{
    switch ($group.memberType) {
        "User"{$tarType = " UC - "}
        "Device"{$tarType = " CC - "}
        "Empty"{$tarType = " No Members - "}
        "Mixed"{$tarType = " CC & UC - "}
        
    }
    switch ($group.synching) {
        "True" { $source = "Local"}        
        Default {$source = "Graph"}
    }
    $location = "unique-Company-Name-6:"

    $newName = $location + $tarType + $group.groupName
    $newGroupInfo += [PSCustomObject]@{
        ID                  =   $group.ID 
        currentGroupName    =   $group.GroupName
        memberType          =   $group.memberType
        newGroupName        =   $newName
        localOrCloud        =   $source
        localID             =   $group.OnPremSID
    }

}

$groups = Import-CSV -Path C:\Temp\DenmarkGroups.csv

$localGroups = $groups | Where-Object {($_.localOrCloud -eq "Local")}

ForEach ($group in $localgroups)
{
    Set-ADGroup -identity $group.localID -DisplayName $group.newGroupName 

}
# SIG # Begin signature block#Script Signature# SIG # End signature block




