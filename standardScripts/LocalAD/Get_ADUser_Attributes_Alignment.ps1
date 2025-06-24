$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$locName = (Get-ADDomain).name

$fileName = $Date+"."+$locName+".csv"

$allUsers = Get-ADUser -filter * -properties * | where-object {($_.enabled -eq $true)}
$allUsers | Select-Object -property "ObjectGUID" , "DisplayName","UserPrincipalName","Country","Company","Office","Officephone","Department","Title", "Manager" , "extensionattribute1" | sort-object -property DisplayName | Export-CSV -Path C:\Temp\$fileName
SignatureBlock

