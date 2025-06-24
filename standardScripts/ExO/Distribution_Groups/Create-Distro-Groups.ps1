#Prior to creating these groups, a connection must be made to Microsoft Graph and Exchange Online NOT with CBA, it must be run under my user account.
#This creates a mail enabled security group 
$EmailAddr = "procurement@parentCompanydc.com"
$groupName = "parentCompany Dry Cooling, Inc. - Procurement"
$groupDescrip = "parentCompany Dry Cooling, Inc. - Procurement"
$groupOwner = "david.drosdick@Domain.extension1"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

#This creates a Standard Distribution Group with No Members
$EmailAddr = "AM.Invoice@parentCompanydc.com"
$groupName = "parentCompany Dry Cooling, Inc. - AM Invoice"
$groupDescrip = "parentCompany Dry Cooling, Inc. - AM Invoice"
$groupOwner = "david.drosdick@Domain.extension1"

New-DistributionGroup -DisplayName $groupName -PrimarySmtpAddress $emailAddr -Description $groupDescrip -Name $groupName -ManagedBy $groupOwner -MemberJoinRestriction Closed -MemberDepartRestriction Closed 
#Adds the sendAs permission to the Trustee
Add-RecipientPermission $EmailAddr -AccessRights SendAs -Trustee "jared.miller@parentCompanydc.com" -Confirm:$false
Add-RecipientPermission $EmailAddr -AccessRights SendAs -Trustee "patrick.saussus@parentCompanydc.com" -Confirm:$false

SignatureBlock

