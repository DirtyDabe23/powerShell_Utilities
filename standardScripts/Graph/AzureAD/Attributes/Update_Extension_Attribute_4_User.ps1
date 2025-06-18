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
        Try{
            $mailbox = Get-Mailbox -identity $user.UserName -erroraction Stop
            $PulledUPN = $mailbox.UserPrincipalName
            $userData = Get-MGBetaUser -userid $pulledUPN | select *  -erroraction Stop
            $userLog += [PSCustomObject]@{
                UPN = $userData.UserPrincipalName
                Synching = $userData.OnPremisesSyncEnabled
                }
        }
        catch{
        $userLog += [PSCustomObject]@{
            UPN = $user.UserName
            Synching = "Failed to Retrieve"
            }
    }
    }
    
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




