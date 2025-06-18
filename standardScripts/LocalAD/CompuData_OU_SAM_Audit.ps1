$compuDataOUUsers = Get-ADUser -filter * -searchbase "OU=CompuData - External Sage Users - Non-Synching,DC=uniqueParentCompany,DC=COM" -properties * | select-object -Property DisplayName, UserPrincipalName, SAMAccountName, GivenName, Surname | sort-object -property surname 
ForEach ($user in $compuDataOUUsers)
{
    $newSAMPre = $user.UserPrincipalName
    $mailNN = $newSamPre.split("@")[0]
    $mailNN = $mailNN.trim()

    If ($mailNN.length -ge 20)
    {
        Write-Output "$($User.users) acctSAMName is too long. Dropping Down."
        $acctSAMName = $mailNN.substring(0,20)
    }
    Else
    {
        Write-Output "$($User.users) acctSAMName is complteamMembert."
        $acctSAMName = $mailNN
    }


    Set-ADUser $user.SAMAccountName -SamAccountName $acctSAMName
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





