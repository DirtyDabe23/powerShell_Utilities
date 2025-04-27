$users = Import-CSv -Path C:\Temp\EvapTechDistroCleanup.csv
Foreach ($user in $users)
{
If ($user.PrimarySmtpAddress -match "uniqueParentCompanyMW.com")
{

Remove-DistributionGroupMember -Identity "uniqueParentCompany Evaptech Distro" -member $user.PrimarySmtpAddress -confirm:$false
}
}



# SIG # Begin signature block#Script Signature# SIG # End signature block




