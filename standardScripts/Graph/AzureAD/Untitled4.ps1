$users = Get-MsolUser -All | Where-Object { ($_.Licenses.AccountSKUID -like "*SPE_F1*") -and ($_.office -eq "parentCompany East") }
$users = $users | Sort-Object -property "UserPrincipalName"
SignatureBlock

