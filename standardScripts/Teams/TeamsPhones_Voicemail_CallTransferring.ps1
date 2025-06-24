Connect-MicrosoftTeams
$csvPath = "C:\Temp\subsidiaryCompany4-shortNamePN.csv"
$users = Import-Csv $csvPath
$parentCompanyGreeting = "WORDS words"

# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
Write-Host "Updating Voicemail Setting for: $user.Username"
Set-CsOnlineVoicemailUserSettings -Identity $user.Username -CallAnswerRule VoicemailWithTransferOption -TransferTarget "3368242102" -DefaultGreetingPromptOverwrite "$parentCompanyGreeting" -WhatIf
Set-CsUserCallingSettings -Identity $User.Username -IsUnansweredEnabled $true -UnansweredTargetType Voicemail -UnansweredDelay 00:00:20 -WhatIf
}


SignatureBlock

