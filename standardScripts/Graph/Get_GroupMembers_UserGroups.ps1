Clear-Host 
Connect-MGGraph -NoWelcome
Write-Output "This script is for use ONLY for checking groups for user memberships. Groups with mixed memberships, or device groups, will not work."
$groupDisplayName = Read-Host "Enter the display name of the group you are looking for here"
$group = Get-MGGRoup -ConsistencyLevel eventual -Search "DisplayName:$GroupDisplayName"
$groupID = $group.id

#Get Users in the Group
$groupMembers = Get-MGGroupMember -groupid $groupID  -all -ConsistencyLevel eventual
$members = @()

ForEach ($ID in $groupMembers.ID)
{
        $groupUser  = Get-MGBetaUser -userid $ID
        
        
        $members +=[PSCustomObject]@{ 
        UserDisplayName = $groupUser.DisplayName
        UPN = $groupuser.UserPrincipalName
        Office = $groupuser.OfficeLocation
        Company = $groupuser.companyName
        
        }
}

$members | Sort-Object -Property @{Expression = "Office"; Descending = $False}, @{Expression = "Company"; Descending = $False} , @{Expression = "UserDisplayName"; Descending = $False}
# SIG # Begin signature block#Script Signature# SIG # End signature block



