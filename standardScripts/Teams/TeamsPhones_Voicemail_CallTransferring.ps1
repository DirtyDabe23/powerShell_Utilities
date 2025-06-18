Connect-MicrosoftTeams
$csvPath = "C:\Temp\anonSubsidiary-1PN.csv"
$users = Import-Csv $csvPath
$uniqueParentCompanyGreeting = "WORDS words"

# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
Write-Host "Updating Voicemail Setting for: $user.Username"
Set-CsOnlineVoicemailUserSettings -Identity $user.Username -CallAnswerRule VoicemailWithTransferOption -TransferTarget "3368242102" -DefaultGreetingPromptOverwrite "$uniqueParentCompanyGreeting" -WhatIf
Set-CsUserCallingSettings -Identity $User.Username -IsUnansweredEnabled $true -UnansweredTargetType Voicemail -UnansweredDelay 00:00:20 -WhatIf
}


# SIG # Begin signature block#Script Signature# SIG # End signature block





