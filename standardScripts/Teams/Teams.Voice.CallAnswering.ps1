Connect-MicrosoftTeams
$csvPath = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\VOIP\unique-Office-Location-1\TeamsPhones.csv"
$users = Import-Csv $csvPath
$phoneNumber = "5596732207"

# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
#Testing a configuration change.
Set-CsOnlineVoicemailUserSettings -Identity $user.UserPrincipalName -CallAnswerRule VoicemailWithTransferOption -TransferTarget $phoneNumber
Set-CsUserCallingSettings -Identity $user.Username -IsUnansweredEnabled $true -UnansweredTargetType Voicemail -UnansweredDelay 00:00:20
Write-Host "Updating Voicemail Setting for:" $user.Username
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






