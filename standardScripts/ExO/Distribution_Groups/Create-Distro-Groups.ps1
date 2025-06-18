#Prior to creating these groups, a connection must be made to Microsoft Graph and Exchange Online NOT with CBA, it must be run under my user account.
#This creates a mail enabled security group 
$EmailAddr = "procurement@uniqueParentCompanydc.com"
$groupName = "unique-Company-Name-5 - Procurement"
$groupDescrip = "unique-Company-Name-5 - Procurement"
$groupOwner = "$userName@uniqueParentCompany.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

#This creates a Standard Distribution Group with No Members
$EmailAddr = "AM.Invoice@uniqueParentCompanydc.com"
$groupName = "unique-Company-Name-5 - AM Invoice"
$groupDescrip = "unique-Company-Name-5 - AM Invoice"
$groupOwner = "$userName@uniqueParentCompany.com"

New-DistributionGroup -DisplayName $groupName -PrimarySmtpAddress $emailAddr -Description $groupDescrip -Name $groupName -ManagedBy $groupOwner -MemberJoinRestriction Closed -MemberDepartRestriction Closed 
#Adds the sendAs permission to the Trustee
Add-RecipientPermission $EmailAddr -AccessRights SendAs -Trustee "jared.miller@uniqueParentCompanydc.com" -Confirm:$false
Add-RecipientPermission $EmailAddr -AccessRights SendAs -Trustee "patrick.saussus@uniqueParentCompanydc.com" -Confirm:$false

# SIG # Begin signature block#Script Signature# SIG # End signature block






