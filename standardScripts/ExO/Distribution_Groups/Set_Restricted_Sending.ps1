Connect-ExchangeOnline
Get-DynamicDistributionGroup -identity 'AllIntlEmployees@uniqueParentCompany.com' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $False 
Get-DynamicDistributionGroup -identity 'AllNorthAmericaEmployees@uniqueParentCompany.com' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $False 

Start-Sleep -Seconds 3600
Connect-ExchangeOnline
Get-DynamicDistributionGroup -identity 'AllIntlEmployees@uniqueParentCompany.com' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $True -AcceptMessagesOnlyFrom "uniqueParentCompany@uniqueParentCompany.com","sstoll@uniqueParentCompany.com","kevin.williams@uniqueParentCompany.com","jarrod.stebick@uniqueParentCompany.com","git-helpdesk@uniqueParentCompany.com"
Get-DynamicDistributionGroup -identity 'AllNorthAmericaEmployees@uniqueParentCompany.com' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $True -AcceptMessagesOnlyFrom "uniqueParentCompany@uniqueParentCompany.com","sstoll@uniqueParentCompany.com","kevin.williams@uniqueParentCompany.com","jarrod.stebick@uniqueParentCompany.com","git-helpdesk@uniqueParentCompany.com"

# SIG # Begin signature block#Script Signature# SIG # End signature block




