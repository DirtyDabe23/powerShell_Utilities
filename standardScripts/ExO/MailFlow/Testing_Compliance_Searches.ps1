$userEmails =@('mbrocato@subsidiaryCompany2.com','sshisler@subsidiaryCompany2.com','dmiller@subsidiaryCompany2.com')
$newComplianceSearches = [Collections.Generic.List[object]]::new()
ForEach ($userEmail in $userEmails){
$Mailbox = Get-Mailbox -identity $userEmail | select-object *
$createdSearch = New-ComplianceSearch -name "$($mailbox.guid)-Review"  -exchangelocation ".$($mailbox.PrimarySmtpAddress)" -ContentMatchQuery 'subject:("17002210" OR "17-5310")' -AllowNotFoundExchangeLocationsEnabled $true -IncludeUserAppContent $true -IncludeOrgContent $true
$newComplianceSearches.add($createdSearch)
$startedSearch = $createdSearch | Start-ComplianceSearch
$newComplianceSearches.Add($startedSearch)
}

SignatureBlock

