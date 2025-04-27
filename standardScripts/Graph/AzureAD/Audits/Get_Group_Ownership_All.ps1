#This Script gets all Microsoft Graph Groups 
$allGroups = Get-MGGRoup -All



$allGroupsIDS = $allGroups.ID

$GroupOwner = @()

ForEach ($groupID in $allGroupsIDS)
{ 
    $groupOwnerIDS = Get-MGGroupOwner -GroupId $groupID
        $groupName = (Get-MGGroup -GroupID $groupID).DisplayName

        ForEach ($groupOwnerID in $groupOwnerIDs)
        {
        $userPrincipalName = (Get-MGUSer -userid $groupOwnerID.ID).UserPrincipalName
        $GroupOwner += [PSCustomObject]@{
        GroupName = $groupName
        Owner = $userPrincipalName
        }
        }

}




$GroupOwner
# SIG # Begin signature block#Script Signature# SIG # End signature block




