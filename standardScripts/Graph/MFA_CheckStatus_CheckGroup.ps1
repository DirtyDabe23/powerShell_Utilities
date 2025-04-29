$mfaGroupMembers = Get-MgGroupMember -GroupId "Group10" -All -ConsistencyLevel eventual
$users = Get-MsolUser -All

$usersNoMFA = @()
$usersNotInGroup = @()
$usersInGroupAlready = @()

forEach ($user in $users)
{
    if ($user.StrongAuthenticationRequirements.state -eq $null) 
    {
    Write-Host "$($user.displayname) does not have MFA configured or enabled."
    $usersNoMFA += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName = $user.displayName
        Office = $user.Office
    }
    }
    else
    {
        if ($user.objectID.guid -in $mfaGroupMembers.id)
        {
        WRite-Host "$($user.displayName) is already in the group"
        $usersInGroupAlready += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName = $user.displayName
        Office = $user.Office
        }
        }
        Else
        {
        Write-Host "$($user.displayName) is being added to the group"
        $usersNotInGroup += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName = $user.displayName
        Office = $user.Office
        }
        }

    }

}

$usersNoMFA | Export-CSV -Path "C:\Temp\2024_03_26_UsersNoMFA.csv"
$usersNotInGroup | Export-CSV -Path "C:\Temp\2024_03_26_UsersNotInGroup.csv"
$usersInGroupAlready | Export-CSV -Path "C:\Temp\2024_03_26_UsersInGroup.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block




