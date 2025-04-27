$invalidUsageLocationUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated") -and ($_.UsageLocation -eq $null)} | select-object -Property "OnPremisesSyncEnabled", "ID", "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "Manager", "BusinessPhones", "UsageLocation" | Sort-Object -Property DisplayName

# SIG # Begin signature block#Script Signature# SIG # End signature block



