$users = Import-CSV -path "C:\Users\david.drosdick\parentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP.csv"
Update-DistributionGroupMember -Identity "esop-only-distro@Domain.extension1" -Members $users.emailaddress  -Confirm:$false

$users = $null

$users = Import-CSV -path "C:\Users\david.drosdick\parentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\PSIP.csv"
Update-DistributionGroupMember -Identity "psip-only-distro@Domain.extension1" -Members $users.emailaddress  -Confirm:$false


$users = $null

$users = Import-CSV -path "C:\Users\david.drosdick\parentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP-PSIP.csv"
Update-DistributionGroupMember -Identity "esop-psip-distro@Domain.extension1" -Members $users.emailaddress  -Confirm:$false
SignatureBlock

