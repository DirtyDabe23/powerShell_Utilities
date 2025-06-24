$filter = "(Office -eq 'parentCompany East')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Location Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllLocationEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Location Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 



$filter = "(Office -like 'parentCompany Alcoil*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Alcoil Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllAlcoilEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Alcoil Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "(Office -like 'parentCompany Iowa*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Iowa Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIowaEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Iowa Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -like 'parentCompany Dry Cooling*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Dry Cooling Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllDryCoolingEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Dry Cooling Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "(Office -eq 'parentCompany Asia Pacific')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Asia Pacific Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllAsiaPacificEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Asia Pacific Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'parentCompany Australia (Pty.) Ltd.')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Australia Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllAustraliaEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Australia Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "(Office -eq 'parentCompany Europe BVBA')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All parentCompany Europe BVBA Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyEuropeBVBAEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Europe BVBA Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'parentCompany LMP')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany LMP Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyLMPEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany LMP Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'parentCompany Midwest')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Midwest Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyMidwestEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Midwest Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'parentCompany Newton')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Newton Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyNewtonEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Newton Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -like 'parentCompany Select*')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Select Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanySelectEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Select Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'Location2')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All Location2 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyWestEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Location2 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'Location2')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All Location2 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyWestEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Location2 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((Office -eq 'parentCompany-Brazil') -or (Office -eq 'FANTR-BRAZIL'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Brazil Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyBrazilEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Brazil Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((Office -like 'Refrigeration Vessels*') -or (Office -eq subsidiaryCompany1-shortName'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany subsidiaryCompany1-shortName Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanysubsidiaryCompany1-shortNameEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany subsidiaryCompany1-shortName Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 



$filter = "(Office -like 'subsidiaryCompany2*')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All subsidiaryCompany2 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllsubsidiaryCompany2Employees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All subsidiaryCompany2 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((Office -like 'Tower Components*') -or (Office -eq 'subsidiaryCompany4-shortName'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany subsidiaryCompany4-shortName Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanysubsidiaryCompany4-shortNameEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany subsidiaryCompany4-shortName Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 



$filter = "((Office -like 'parentCompany-Denmark*') -or (Office -eq 'Denmark'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Denmark Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyDenmarkEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Denmark Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -like 'parentCompany Iowa*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Iowa Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIowaEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Iowa Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((CompanyName -notlike 'parentCompany Select*') -and (Office -notlike 'parentCompany Select'))  -and (RecipientType -eq 'UserMailbox') -and (UsageLocation -eq 'United States'))"

New-DynamicDistributionGroup -Name "All Iowa Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIowaEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Iowa Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((user.usagelocation -eq 'US') -or (user.usagelocation -eq 'CA')) -and (user.assignedPlans -any (assignedPlan.servicePlanId -eq 'eec0eb4f-6444-4f95-aba0-50c24d67f998' -and assignedPlan.capabilityStatus -eq 'Enabled'))"
New-DynamicDistributionGroup -Name "All NA E5 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllNAE5Employees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All NA E5 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'parentCompany Iowa Sales & Engineering')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Iowa Sales & Engineering Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyIowaSales&EngineeringEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Iowa Sales & Engineering Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Company -eq 'parentCompany, Inc.')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All parentCompany Iowa Sales & Engineering Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllparentCompanyIowaSales&EngineeringEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All parentCompany Iowa Sales & Engineering Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(((Company -eq 'parentCompany, Inc.')  -or (Company -eq 'parentCompany Dry Cooling, Inc.') -or (Company -eq 'subsidiaryCompany2, Inc.') -or (Company -eq 'subsidiaryCompany1' -or (Company -eq 'subsidiaryCompany4')) -and (RecipientType -eq 'UserMailbox')"
#New-DynamicDistributionGroup -Name "All ESOP Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllESOPEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All ESOP Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((((((((UsageLocation -eq 'United States') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'FANTR-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'subsidiaryCompany2 China')) -and (-not(Office -eq 'subsidiaryCompany2 Asia Pacific')) -and (-not(Office -like 'Location2'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All US Employees Sans Madera" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllUSNonMaderaEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All US Employees Sans Madera" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1","jeff.poczekaj@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((((((((UsageLocation -eq 'Italy') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'FANTR-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'subsidiaryCompany2 China')) -and (-not(Office -eq 'subsidiaryCompany2 Asia Pacific')) -and (-not(Office -like 'Location2'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All Italy Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllItalyEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Italy Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1","Lynda.Bohager@Domain.extension1","Jarrod.Stebick@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((((((((UsageLocation -eq 'Germany') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'FANTR-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'subsidiaryCompany2 China')) -and (-not(Office -eq 'subsidiaryCompany2 Asia Pacific')) -and (-not(Office -like 'Location2'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All Germany Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllGermanyEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All Germany Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1","Lynda.Bohager@Domain.extension1","Jarrod.Stebick@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 






Set-DynamicDistributionGroup -Identity "All ESOP Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -ConditionalCompany "parentCompany, Inc.","parentCompany Dry Cooling, Inc.","subsidiaryCompany2, Inc.","subsidiaryCompany1","subsidiaryCompany4" -ForceMembershipRefresh 



$filter = "((((((((((((((((((((((((((UsageLocation -ne 'US') -or (UsageLocation -ne 'CA'))) -and (Company -ne 'Not Affiliated'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')))) -and (-not(Name -like 'CAS_{*')))) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')))) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All International Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIntlEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All International Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((((((((UsageLocation -eq 'United States') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'FANTR-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'subsidiaryCompany2 China')) -and (-not(Office -eq 'subsidiaryCompany2 Asia Pacific')) -and (-not(Office -like 'Location2'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All US Employees Sans Madera" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllUSNonMaderaEmployees@Domain.extension1"
Set-DynamicDistributionGroup -Identity "All US Employees Sans Madera" -AcceptMessagesOnlyFrom "Kevin.Williams@Domain.extension1","GIT-Helpdesk@Domain.extension1","jeff.poczekaj@Domain.extension1" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@Domain.extension1" -RecipientFilter $filter -ForceMembershipRefresh 
SignatureBlock

