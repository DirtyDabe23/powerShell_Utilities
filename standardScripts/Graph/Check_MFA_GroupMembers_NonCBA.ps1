Connect-MgGraph

Write-Host "Enter the Domain to check. Example = @uniqueParentCompany.com"
$Domain = Read-Host "Enter the Domain to check"

$users = Get-MGBetaUser -all -consistencylevel eventual | Where-object {($_.CompanyName -ne "Not Affiliated") -and ($_.UserPrincipalName -like "*$domain")}
Write-Host "Checking $($users.count) users for MFA Enabled Group Membership"

#GroupID is for MFA Enabled
$groupMembers = Get-MgGroupMember -groupid "Group10" -all -ConsistencyLevel eventual

$nonMembers = @();

ForEach ($user in $users)
{
    if ($groupMembers.id -notcontains $user.id)
    { 
        $nonMembers +=[PSCustomObject]@{ 
        UserDisplayName = $user.DisplayName
        UPN = $user.UserPrincipalName
        Office = $user.OfficeLocation
        Company = $user.companyName
        
        }
    }
    Else
    {
    $null
    }
}
Write-Host "Enter a path for your file. Example's are C:\Temp\2024_03_25_Export.csv, the full path and file extension are required"
$Path = Read-Host "Path"
$nonMembers | Export-CSV -Path $Path 
# SIG # Begin signature block#Script Signature# SIG # End signature block





