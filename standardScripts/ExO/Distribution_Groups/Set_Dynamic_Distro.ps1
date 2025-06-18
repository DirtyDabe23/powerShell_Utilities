Set-DynamicDistributionGroup -Identity "All South America Employees" -recipientfilter "(UsageLocation -eq 'BR')  -and (RecipientType -eq 'UserMailbox')"
Set-DynamicDistributionGroup -Identity "All Europe Employees" -recipientfilter "((UsageLocation -eq 'BE') -or (UsageLocation -eq 'DE') -or (UsageLocation -eq 'DK') -or (UsageLocation -eq 'IT') -or (UsageLocation -eq 'GB'))  -and (RecipientType -eq 'UserMailbox')"
Set-DynamicDistributionGroup -Identity "All Africa Employees" -recipientfilter "((UsageLocation -eq 'AE') -or (UsageLocation -eq 'ZA'))  -and (RecipientType -eq 'UserMailbox')"
Set-DynamicDistributionGroup -Identity "All Asia Employees" -recipientfilter "(UsageLocation -eq 'CN')  -and (RecipientType -eq 'UserMailbox')"


Set-DynamicDistributionGroup -Identity "All South America Employees" -ForceMembershipRefresh
Set-DynamicDistributionGroup -Identity "All Europe Employees" -ForceMembershipRefresh
Set-DynamicDistributionGroup -Identity "All Africa Employees" -ForceMembershipRefresh
Set-DynamicDistributionGroup -Identity "All Asia Employees" -ForceMembershipRefresh
# SIG # Begin signature block#Script Signature# SIG # End signature block



