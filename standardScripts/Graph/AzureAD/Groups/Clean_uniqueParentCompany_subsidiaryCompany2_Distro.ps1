$users = Import-CSv -Path C:\Temp\subsidiaryCompany2DistroCleanup.csv
Foreach ($user in $users)
{
If ($user.PrimarySmtpAddress -match "uniqueParentCompanyMW.com")
{

Remove-DistributionGroupMember -Identity "uniqueParentCompany subsidiaryCompany2 Distro" -member $user.PrimarySmtpAddress -confirm:$false
}
}



SignatureBlock






