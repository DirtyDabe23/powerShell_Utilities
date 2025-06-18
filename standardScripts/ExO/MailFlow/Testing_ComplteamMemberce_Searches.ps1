$userEmails =@('mbrocato@anonSubsidiary-1.com','sshisler@anonSubsidiary-1.com','dmiller@anonSubsidiary-1.com')
$newComplteamMemberceSearches = [Collections.Generic.List[object]]::new()
ForEach ($userEmail in $userEmails){
$Mailbox = Get-Mailbox -identity $userEmail | select-object *
$createdSearch = New-ComplteamMemberceSearch -name "$($mailbox.guid)-Review"  -exchangelocation ".$($mailbox.PrimarySmtpAddress)" -ContentMatchQuery 'subject:("17002210" OR "17-5310")' -AllowNotFoundExchangeLocationsEnabled $true -IncludeUserAppContent $true -IncludeOrgContent $true
$newComplteamMemberceSearches.add($createdSearch)
$startedSearch = $createdSearch | Start-ComplteamMemberceSearch
$newComplteamMemberceSearches.Add($startedSearch)
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





