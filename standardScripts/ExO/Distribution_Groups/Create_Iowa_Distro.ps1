Connect-ExchangeOnline 

$users = Import-CSV -Path "C:\Temp\Iowa_Office_Distro.csv"

ForEach ($user in $users)
{
    Add-DistributionGroupMember -identity "uniqueParentCompanyIAOffice@uniqueParentCompanyia.com" -member $user.users
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




