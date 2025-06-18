$Users = Import-CSV -Path C:\Temp\NMWMFA.csv 
ForEach ($user in $Users)
{
  Write-Host "Adding $($user.DisplayName) to the MFA Enabled Group"
  New-MGGroupMember -GroupID "Group10" -DirectoryObjectId $user.ID
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




