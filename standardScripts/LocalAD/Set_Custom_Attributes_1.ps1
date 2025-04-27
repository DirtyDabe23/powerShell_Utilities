#Set Value
$self = Get-ADUser -identity $userName
Set-ADUser -Identity $self -add @{"extensionAttribute1"="Shop"}


#Change Value 
#Set Value
$self = Get-ADUser -identity $userName
Set-ADUser -Identity $self -replace @{"extensionAttribute1"="Office"}

#Clear the value:
Set-ADUser -Identity $self -Clear extensionAttribute1

#Get the specific users we're looking for:
Get-ADUSer -filter * -SearchBase "ou=Employees,DC=uniqueParentCompany,DC=COM" | Where-Object {($_.DistinguishedName -notlike "*OU=Shop*")} | Select-Object -Property UserPrincipalName | Sort-Object -Property UserPrincipalName


@{"extensionAttribute1"="Shop"}
# SIG # Begin signature block#Script Signature# SIG # End signature block





