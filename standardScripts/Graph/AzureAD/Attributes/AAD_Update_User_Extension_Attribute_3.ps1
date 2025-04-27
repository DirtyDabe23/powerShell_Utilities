$userLog = @()
$users = Import-Csv -Path C:\Temp\AdobeAcrobatStandardUsers.csv


ForEach ($user in $users)
{
    try{
    $userData = Get-MGBetaUser -userid $user.UserNAme | select *  -erroraction Stop
    $userLog += [PSCustomObject]@{
        UPN = $userData.UserPrincipalName
        Synching = $userData.OnPremisesSyncEnabled
    }
    }
    Catch{
        $userLog += [PSCustomObject]@{
            UPN = $user.UserName
            Synching = "Failed to Retrieve"
        }

    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




