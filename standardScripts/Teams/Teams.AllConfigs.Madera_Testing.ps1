Connect-MicrosoftTeams
$csvPath = "C:\Users\david.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\VOIP\Location2\TeamsPhones_testing.csv"
$users = Import-Csv $csvPath
$phoneNumber = "4107562600"


# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
$parentCompanyGreeting = "You have reached the voicemail of $($user.'Display Name').  Please leave a message at the tone.  When finished recording simply hang up to deliver the message or press 0 for more options."
Write-Host "Updating Voicemail Setting for:" $user.'Display Name'
Write-Host "Voicemail message for user is: $parentCompanyGreeting`n"    
#Testing a configuration change.
Set-CsOnlineVoicemailUserSettings -Identity $user.UserPrincipalName -CallAnswerRule VoicemailWithTransferOption -TransferTarget $phoneNumber -DefaultGreetingPromptOverwrite "$parentCompanyGreeting" 
Set-CsUserCallingSettings -Identity $user.UserPrincipalName -IsUnansweredEnabled $true -UnansweredTargetType Voicemail -UnansweredDelay 00:00:20 
}
SignatureBlock

