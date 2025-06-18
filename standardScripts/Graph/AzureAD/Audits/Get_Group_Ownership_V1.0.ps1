#This Script gets all Microsoft Graph Groups 
$allGroups = Get-MGGRoup -All

$Prompt = Read-Host -Prompt "Enter the UserName Here"

$user = Get-MGBetaUser -UserID $Prompt
$userID = $user.ID
$userPrincipalName = $user.UserPrincipalName

$allGroupsIDS = $allGroups.ID

$GroupOwner = @()

ForEach ($groupID in $allGroupsIDS)
{ 
    $groupOwnerID = Get-MGGroupOwner -GroupId $groupID
    if($groupOwnerID.ID -contains $userID)
    {
        $groupName = (Get-MGGroup -GroupID $groupID).DisplayName
        $GroupOwner += [PSCustomObject]@{
        GroupName = $groupName
        Owner = $userPrincipalName
        }

    }


}

$GroupOwner
# SIG # Begin signature block#Script Signature# SIG # End signature block




