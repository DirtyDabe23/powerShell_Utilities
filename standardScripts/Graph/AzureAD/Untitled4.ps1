$users = Get-MsolUser -All | Where-Object { ($_.Licenses.AccountSKUID -like "*SPE_F1*") -and ($_.office -eq "unique-Office-Location-0") }
$users = $users | Sort-Object -property "UserPrincipalName"
# SIG # Begin signature block#Script Signature# SIG # End signature block





