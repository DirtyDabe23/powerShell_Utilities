$distroIdentity = Read-Host "Enter the Dynamic Distribution Group Identity"
$dynamicDistro = Get-DynamicDistributionGroup -Identity $distroIdentity | select *
$dynamicDistro | Select * | More
Write-Output "The Recipient Filter is as Follows:`n`n"
$dynamicDistro.RecipientFilter
Write-Output "`n`n-Press Any Key To Proceed-`n`n"
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
Write-Output "`n`n`nRetrieving Members`n`n`n"
$distroGroupMembers = Get-DynamicDistributionGroupMember -Identity $dynamicDistro.Identity -ResultSize Unlimited
$distroGroupMembers | sort Company , Office , LastName | select DisplayName , PrimarySMTPAddress , Office , Company , UsageLocation | format-table -AutoSize | more

# SIG # Begin signature block#Script Signature# SIG # End signature block



