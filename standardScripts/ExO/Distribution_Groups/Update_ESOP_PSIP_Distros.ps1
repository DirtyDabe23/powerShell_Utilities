$users = Import-CSV -path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP.csv"
Update-DistributionGroupMember -Identity "esop-only-distro@uniqueParentCompany.com" -Members $users.emailaddress  -Confirm:$false

$users = $null

$users = Import-CSV -path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\PSIP.csv"
Update-DistributionGroupMember -Identity "psip-only-distro@uniqueParentCompany.com" -Members $users.emailaddress  -Confirm:$false


$users = $null

$users = Import-CSV -path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP-PSIP.csv"
Update-DistributionGroupMember -Identity "esop-psip-distro@uniqueParentCompany.com" -Members $users.emailaddress  -Confirm:$false
# SIG # Begin signature block#Script Signature# SIG # End signature block





