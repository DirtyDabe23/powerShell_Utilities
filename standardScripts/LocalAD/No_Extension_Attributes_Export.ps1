$allUsers = Get-ADUser -filter * -Properties * 
$noExtensionAttributes = $allusers | Where-Object {($_.extensionAttribute1 -eq $null) -and ($_.Enabled -eq $true)}
$noExtensionAttributes = $noExtensionAttributes | Select-Object -Property "ObjectGUID","DisplayName","UserPrincipalName","Department","extensionattribute1" | sort-object -Property DisplayName
$noExtensionAttributes | export-csv -path C:\Temp\2023_12_15_NoExtensionAttributes.csv 

SignatureBlock

