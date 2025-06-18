$IL_Employees = Import-CSV -Path "C:\Temp\IL_Employees.csv"
Update-DistributionGroupMember -Identity "IllinoisHealthComplteamMemberce@uniqueParentCompany.com" -Members $IL_Employees.emailaddress  -Confirm:$false

$EE_Employees = Import-CSV -Path "C:\Temp\EE_Employees.csv"
Update-DistributionGroupMember -Identity "GlobalHealthComplteamMemberce@uniqueParentCompany.com" -Members $EE_Employees.emailaddress  -Confirm:$false
# SIG # Begin signature block#Script Signature# SIG # End signature block





