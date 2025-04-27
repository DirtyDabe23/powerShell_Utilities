 $users = Import-CSV -Path C:\Temp\F3MFA.csv
 $groupID = (Get-AzureADGroup -SearchString "MFA Enabled").objectid

 ForEach ($user in $users)
 {
    $userID = (Get-AzureADUser -ObjectId $user.userprincipalname).objectID
    $displayNAme = $user.userprincipalname
    Write-Host "Adding $displayName to MFA Enabled"
    Add-AzureADGroupMember -ObjectId $groupID -RefObjectId $userID
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



