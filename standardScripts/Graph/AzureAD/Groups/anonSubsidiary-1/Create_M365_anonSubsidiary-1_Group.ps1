#Prior to creating these groups, a connection must be made to Microsoft Graph and Exchange Online NOT with CBA, it must be run under my user account.

$EmailAddr = "BidAssignment@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - BidAssignment"
$groupDescrip = "BidAssignment"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner



$EmailAddr = "ProductImprovement@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - Product Improvement"
$groupDescrip = "anonSubsidiary-1ProductImprovement"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner



$EmailAddr = "Visitor@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - Visitor"
$groupDescrip = "anonSubsidiary-1Visitor"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner



$EmailAddr = "Management@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - Management"
$groupDescrip = "anonSubsidiary-1Management"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "BidAssignment@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - BidAssignment"
$groupDescrip = "BidAssignment"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner


$EmailAddr = "Asktheexpert@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - Ask The Expert"
$groupDescrip = "anonSubsidiary-1AskTheExpert"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "emergency@anonSubsidiary-1.com"
$groupName = "anonSubsidiary-1 - Emergency"
$groupDescrip = "Emergency Notification"
$groupOwner = "cbickerstaff@anonSubsidiary-1.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "procurement@uniqueParentCompanydc.com"
$groupName = "unique-Company-Name-5 - Procurement"
$groupDescrip = "unique-Company-Name-5 - Procurement"
$groupOwner = "$userName@uniqueParentCompany.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "AM.Orders@uniqueParentCompanydc.com"
$groupName = "unique-Company-Name-5 - AM Orders"
$groupDescrip = "unique-Company-Name-5 - AM Orders"
$groupOwner = "$userName@uniqueParentCompany.com"

New-DistributionGroup -DisplayName $groupName -PrimarySmtpAddress $emailAddr -Description $groupDescrip -Name $groupName -ManagedBy $groupOwner -MemberJoinRestriction Closed -MemberDepartRestriction Closed 
# SIG # Begin signature block#Script Signature# SIG # End signature block








