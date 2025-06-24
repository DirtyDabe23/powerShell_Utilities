$users = Import-CSv -Path C:\Temp\subsidiaryCompany2DistroCleanup.csv
Foreach ($user in $users)
{
If ($user.PrimarySmtpAddress -match "parentCompanyMW.com")
{

Remove-DistributionGroupMember -Identity "parentCompany subsidiaryCompany2 Distro" -member $user.PrimarySmtpAddress -confirm:$false
}
}



SignatureBlock

