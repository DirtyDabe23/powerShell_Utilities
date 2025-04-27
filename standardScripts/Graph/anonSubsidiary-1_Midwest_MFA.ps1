$Users = Import-CSV -Path C:\Temp\NMWMFA.csv 
ForEach ($user in $Users)
{
  Write-Host "Adding $($user.DisplayName) to the MFA Enabled Group"
  New-MGGroupMember -GroupID "276cd6bd-7e8f-483b-9e33-6b6e364bdd50" -DirectoryObjectId $user.ID
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



