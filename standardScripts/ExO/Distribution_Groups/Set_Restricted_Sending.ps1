Connect-ExchangeOnline
Get-DynamicDistributionGroup -identity 'AllIntlEmployees@Domain.extension1' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $False 
Get-DynamicDistributionGroup -identity 'AllNorthAmericaEmployees@Domain.extension1' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $False 

Start-Sleep -Seconds 3600
Connect-ExchangeOnline
Get-DynamicDistributionGroup -identity 'AllIntlEmployees@Domain.extension1' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $True -AcceptMessagesOnlyFrom "parentCompany@Domain.extension1","sstoll@Domain.extension1","kevin.williams@Domain.extension1","jarrod.stebick@Domain.extension1","git-helpdesk@Domain.extension1"
Get-DynamicDistributionGroup -identity 'AllNorthAmericaEmployees@Domain.extension1' | Set-DynamicDistributionGroup -RequireSenderAuthenticationEnabled $True -AcceptMessagesOnlyFrom "parentCompany@Domain.extension1","sstoll@Domain.extension1","kevin.williams@Domain.extension1","jarrod.stebick@Domain.extension1","git-helpdesk@Domain.extension1"

SignatureBlock

