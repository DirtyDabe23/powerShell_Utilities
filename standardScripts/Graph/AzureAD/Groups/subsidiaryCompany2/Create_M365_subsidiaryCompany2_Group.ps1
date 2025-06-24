#Prior to creating these groups, a connection must be made to Microsoft Graph and Exchange Online NOT with CBA, it must be run under my user account.

$EmailAddr = "BidAssignment@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - BidAssignment"
$groupDescrip = "BidAssignment"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner



$EmailAddr = "ProductImprovement@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - Product Improvement"
$groupDescrip = "subsidiaryCompany2ProductImprovement"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner



$EmailAddr = "Visitor@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - Visitor"
$groupDescrip = "subsidiaryCompany2Visitor"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner



$EmailAddr = "Management@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - Management"
$groupDescrip = "subsidiaryCompany2Management"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "BidAssignment@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - BidAssignment"
$groupDescrip = "BidAssignment"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner


$EmailAddr = "Asktheexpert@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - Ask The Expert"
$groupDescrip = "subsidiaryCompany2AskTheExpert"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "emergency@subsidiaryCompany2.com"
$groupName = "subsidiaryCompany2 - Emergency"
$groupDescrip = "Emergency Notification"
$groupOwner = "cbickerstaff@subsidiaryCompany2.com"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "procurement@parentCompanydc.com"
$groupName = "parentCompany Dry Cooling, Inc. - Procurement"
$groupDescrip = "parentCompany Dry Cooling, Inc. - Procurement"
$groupOwner = "david.drosdick@Domain.extension1"

New-UnifiedGroup -displayName $groupName -primarysmtpaddress $emailAddr -Notes $groupDescrip -Owner $groupOwner

$EmailAddr = "AM.Orders@parentCompanydc.com"
$groupName = "parentCompany Dry Cooling, Inc. - AM Orders"
$groupDescrip = "parentCompany Dry Cooling, Inc. - AM Orders"
$groupOwner = "david.drosdick@Domain.extension1"

New-DistributionGroup -DisplayName $groupName -PrimarySmtpAddress $emailAddr -Description $groupDescrip -Name $groupName -ManagedBy $groupOwner -MemberJoinRestriction Closed -MemberDepartRestriction Closed 
SignatureBlock

