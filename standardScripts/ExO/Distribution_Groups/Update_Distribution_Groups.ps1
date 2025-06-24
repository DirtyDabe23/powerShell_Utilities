$IL_Employees = Import-CSV -Path "C:\Temp\IL_Employees.csv"
Update-DistributionGroupMember -Identity "IllinoisHealthCompliance@Domain.extension1" -Members $IL_Employees.emailaddress  -Confirm:$false

$EE_Employees = Import-CSV -Path "C:\Temp\EE_Employees.csv"
Update-DistributionGroupMember -Identity "GlobalHealthCompliance@Domain.extension1" -Members $EE_Employees.emailaddress  -Confirm:$false
SignatureBlock

