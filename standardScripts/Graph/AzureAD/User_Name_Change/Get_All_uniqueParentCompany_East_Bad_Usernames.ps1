$Users = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.OfficeLocation -eq "unique-Office-Location-0") -and ($_.CompanyName -NE 'Not Affiliated')} 
$usersToFix  = @()

ForEach ($user in $users)
{
    $userUPNSuffix = $user.UserPrincipalName.split("@")[1]
    $compliantUPN = $user.GivenName + "." + $user.Surname +"@"+$userUPNSuffix

    if ($compliantUPN -ne $user.UserPrincipalName)
    {
        Write-Output "$($user.DisplayName) requires a name modification"
        $usersToFix += [PSCustomObject]@{
            user = $user.displayName
            currentUPN = $user.UserPrincipalName
            newUPN = $compliantUPN
            synching = $user.OnPremisesSyncEnabled
            onPremSAM = $user.OnPremisesSamAccountName
        }
    }

    
}

Write-Output "The variable to use for the data is `$userstoFix"
# SIG # Begin signature block#Script Signature# SIG # End signature block




