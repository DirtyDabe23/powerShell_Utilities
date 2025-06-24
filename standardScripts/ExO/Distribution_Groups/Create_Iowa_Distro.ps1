Connect-ExchangeOnline 

$users = Import-CSV -Path "C:\Temp\Iowa_Office_Distro.csv"

ForEach ($user in $users)
{
    Add-DistributionGroupMember -identity "parentCompanyIAOffice@parentCompanyia.com" -member $user.users
}
SignatureBlock

