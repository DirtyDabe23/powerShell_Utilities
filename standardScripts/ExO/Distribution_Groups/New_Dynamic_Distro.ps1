$filter = "(Office -eq 'unique-Office-Location-0')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Location Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllLocationEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Location Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 



$filter = "(Office -like 'uniqueParentCompany Alcoil*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Alcoil Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllAlcoilEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Alcoil Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "(Office -like 'unique-Office-Location-3*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Iowa Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIowaEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Iowa Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -like 'uniqueParentCompany Dry Cooling*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Dry Cooling Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllDryCoolingEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Dry Cooling Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "(Office -eq 'uniqueParentCompany Asia Pacific')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Asia Pacific Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllAsiaPacificEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Asia Pacific Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Company-Name-3')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Australia Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllAustraliaEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Australia Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "(Office -eq 'unique-Company-Name-7')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All unique-Company-Name-7 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyEuropeBVBAEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Company-Name-7 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Company-Name-11')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Company-Name-11 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyLMPEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Company-Name-11 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Office-Location-2')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Office-Location-2 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyMidwestEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Office-Location-2 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Office-Location-27')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Office-Location-27 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyanonSubsidiary-1Employees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Office-Location-27 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -like 'uniqueParentCompany Select*')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All uniqueParentCompany Select Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanySelectEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All uniqueParentCompany Select Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Office-Location-1')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Office-Location-1 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyWestEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Office-Location-1 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Office-Location-1')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Office-Location-1 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyWestEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Office-Location-1 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((Office -eq 'uniqueParentCompany-Brazil') -or (Office -eq 'anonSubsidiary-1-BRAZIL'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All uniqueParentCompany Brazil Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyBrazilEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All uniqueParentCompany Brazil Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((Office -like 'Refrigeration Vessels*') -or (Office -eq anonSubsidiary-1'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All uniqueParentCompany anonSubsidiary-1 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyanonSubsidiary-1Employees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All uniqueParentCompany anonSubsidiary-1 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 



$filter = "(Office -like 'anonSubsidiary-1*')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All anonSubsidiary-1 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllanonSubsidiary-1Employees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All anonSubsidiary-1 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((Office -like 'Tower Components*') -or (Office -eq 'anonSubsidiary-1'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All uniqueParentCompany anonSubsidiary-1 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyanonSubsidiary-1Employees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All uniqueParentCompany anonSubsidiary-1 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 



$filter = "((Office -like 'uniqueParentCompany-Denmark*') -or (Office -eq 'Denmark'))  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All uniqueParentCompany Denmark Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyDenmarkEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All uniqueParentCompany Denmark Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -like 'unique-Office-Location-3*')  -and (RecipientType -eq 'UserMailbox')"

New-DynamicDistributionGroup -Name "All Iowa Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIowaEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Iowa Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((CompanyName -notlike 'uniqueParentCompany Select*') -and (Office -notlike 'uniqueParentCompany Select'))  -and (RecipientType -eq 'UserMailbox') -and (UsageLocation -eq 'United States'))"

New-DynamicDistributionGroup -Name "All Iowa Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIowaEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Iowa Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((user.usagelocation -eq 'US') -or (user.usagelocation -eq 'CA')) -and (user.assignedPlans -any (assignedPlan.servicePlanId -eq 'eec0eb4f-6444-4f95-aba0-50c24d67f998' -and assignedPlan.capabilityStatus -eq 'Enabled'))"
New-DynamicDistributionGroup -Name "All NA E5 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllNAE5Employees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All NA E5 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Office -eq 'unique-Company-Name-10')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Company-Name-10 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyIowaSales&EngineeringEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Company-Name-10 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(Company -eq 'unique-Company-Name-0')  -and (RecipientType -eq 'UserMailbox')"
New-DynamicDistributionGroup -Name "All unique-Company-Name-10 Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AlluniqueParentCompanyIowaSales&EngineeringEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All unique-Company-Name-10 Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "(((Company -eq 'unique-Company-Name-0')  -or (Company -eq 'unique-Company-Name-5') -or (Company -eq 'unique-Company-Name-18') -or (Company -eq 'unique-Company-Name-20' -or (Company -eq 'unique-Company-Name-21')) -and (RecipientType -eq 'UserMailbox')"
#New-DynamicDistributionGroup -Name "All ESOP Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllESOPEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All ESOP Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((((((((UsageLocation -eq 'United States') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'anonSubsidiary-1-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'anonSubsidiary-1 China')) -and (-not(Office -eq 'anonSubsidiary-1 Asia Pacific')) -and (-not(Office -like 'unique-Office-Location-1'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All US Employees Sans Madera" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllUSNonMaderaEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All US Employees Sans Madera" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com","jeff.poczekaj@uniqueParentCompany.COM" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((((((((UsageLocation -eq 'Italy') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'anonSubsidiary-1-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'anonSubsidiary-1 China')) -and (-not(Office -eq 'anonSubsidiary-1 Asia Pacific')) -and (-not(Office -like 'unique-Office-Location-1'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All Italy Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllItalyEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Italy Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com","Lynda.Bohager@uniqueParentCompany.com","Jarrod.Stebick@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 

$filter = "((((((((UsageLocation -eq 'Germany') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'anonSubsidiary-1-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'anonSubsidiary-1 China')) -and (-not(Office -eq 'anonSubsidiary-1 Asia Pacific')) -and (-not(Office -like 'unique-Office-Location-1'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All Germany Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllGermanyEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All Germany Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com","Lynda.Bohager@uniqueParentCompany.com","Jarrod.Stebick@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 






Set-DynamicDistributionGroup -Identity "All ESOP Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -ConditionalCompany "unique-Company-Name-0","unique-Company-Name-5","unique-Company-Name-18","unique-Company-Name-20","unique-Company-Name-21" -ForceMembershipRefresh 



$filter = "((((((((((((((((((((((((((UsageLocation -ne 'US') -or (UsageLocation -ne 'CA'))) -and (Company -ne 'Not Affiliated'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')))) -and (-not(Name -like 'CAS_{*')))) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')))) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All International Employees" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllIntlEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All International Employees" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 


$filter = "((((((((UsageLocation -eq 'United States') -and (-not(Company -eq 'Not Affiliated')))) -and (-not(office -eq 'Denmark'))) -and (-not(company -eq '')) -and (-not(office -eq '')) -and (-not(Office -eq 'anonSubsidiary-1-Brazil')) -and (-not(Office -eq 'Shanghai')) -and (-not(Office -eq 'anonSubsidiary-1 China')) -and (-not(Office -eq 'anonSubsidiary-1 Asia Pacific')) -and (-not(Office -like 'unique-Office-Location-1'))) -and (RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
New-DynamicDistributionGroup -Name "All US Employees Sans Madera" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress "AllUSNonMaderaEmployees@uniqueParentCompany.com"
Set-DynamicDistributionGroup -Identity "All US Employees Sans Madera" -AcceptMessagesOnlyFrom "Kevin.Williams@uniqueParentCompany.com","GIT-Helpdesk@uniqueParentCompany.com","jeff.poczekaj@uniqueParentCompany.COM" -HiddenFromAddressListsEnabled $true -ManagedBy "Kevin.Williams@uniqueParentCompany.com" -RecipientFilter $filter -ForceMembershipRefresh 
# SIG # Begin signature block#Script Signature# SIG # End signature block
























