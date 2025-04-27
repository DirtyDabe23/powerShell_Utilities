Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.OfficeLocation -eq "unique-Company-Name-20") -or ($_.OfficeLocation -eq "unique-Company-Name-18") -or ($_.OfficeLocation -eq "unique-Company-Name-5") -or ($_.OfficeLocation -eq "unique-Company-Name-21") -or ($_.OfficeLocation -eq "unique-Company-Name-2") -or ($_.OfficeLocation -eq "unique-Company-Name-10") -or ($_.OfficeLocation -eq "unique-Office-Location-21") -and ($_.CompanyName -ne "Not Affiliated") } | select-object -property displayname, userprincipalname, officelocation | sort-object -Property "OfficeLocation","DisplayName"  | Export-CSV -Path C:\Temp\2024_04_24_RequestedUsers.csv -force
# SIG # Begin signature block#Script Signature# SIG # End signature block










