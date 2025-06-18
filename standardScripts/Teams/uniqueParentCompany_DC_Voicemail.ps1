Connect-AzureAD
Connect-ExchangeOnline
Connect-AzureAD
Connect-MSGraph
Connect-MicrosoftTeams
$users = Get-MGBetaUser -consistencylevel eventual -count userCount -filter "endsWith(UserPrincipalName, '@uniqueParentCompanydc.com')" 
$users | Export-CSV -Path C:\Temp\2023_08_18_uniqueParentCompanyDCUsers.csv


# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
Write-Host "Updating Voicemail Setting for: $($user.UserPrincipalName)"
Set-CsOnlineVoicemailUserSettings -Identity $user.UserPrincipalName -CallAnswerRule VoicemailWithTransferOption -TransferTarget "9083792665"
Set-CsUserCallingSettings -Identity $User.UserPrincipalName -IsUnansweredEnabled $true -UnansweredTargetType Voicemail -UnansweredDelay 00:00:20
}


# SIG # Begin signature block#Script Signature# SIG # End signature block




