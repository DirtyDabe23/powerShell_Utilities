#This specifies the value that you would want to set for the extension Attributes of the users 
$extAttr1 = "Office"


#This specifies what OUs to check
$search = "OU=Evpco Users,DC=uniqueParentCompany,DC=mn"
#OU=Users,OU=Office,OU=End Users,OU=AD-Midwest,DC=greenup,DC=uniqueParentCompany,DC=com

#This returns the displayname and ExtensionAttributes of the users of the indiciated OUs 
Get-ADUser -Filter * -SearchBase $search  -Properties * | Select-Object -Property DisplayName, ExtensionAttribute1

#The following command searches the specified OU's and returns all users that are contained there, it returns only users with null extension attributes
$users = Get-ADUser -Filter * -SearchBase $search  -Properties * | Where-object {($_.ExtensionAttribute1 -eq $null)}



$users | set-aduser -add @{"extensionAttribute1"=$extAttr1}


Get-ADUser -Filter * -SearchBase $search  -Properties * | Select-Object -Property DisplayName, ExtensionAttribute1
# SIG # Begin signature block#Script Signature# SIG # End signature block





