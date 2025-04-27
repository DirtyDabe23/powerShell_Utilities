$externalCompuDataUsers =  Get-ADUser -SearchBase 'OU=CompuData - External Sage Users - Non-Synching,DC=uniqueParentCompany,DC=COM'-Filter *

ForEach ($user in $externalCompuDataUsers)
{
    $graphUser = Get-MGUser -ConsistencyLevel eventual -search "UserPrincipalName:$($User.samaccountname)"
    if ($graphUser.mail.count -ge 2)
    {
        $email = $graphUser.Mail[0]
    }
    Else
    {
        $email = $graphUser.mail
    }
    Set-ADuser -Identity $user -EmailAddress $email

}
# SIG # Begin signature block#Script Signature# SIG # End signature block




