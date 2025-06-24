Clear-Host
$subsidiaryCompany2AP = 'subsidiaryCompany2 (Shanghai) Cooling Tower Co., Ltd.'
$parentCompanyBeijing = 'parentCompany (Beijing) Refrigeration Equipment Co., Ltd.'
$parentCompanyShang = 'parentCompany (Shanghai) Refrigeration Equipment Co., Ltd.'
$parentCompanyJiaxing = 'parentCompany Air Cooling Systems (Jiaxing) Co., Ltd.'

$switchCase = Read-Host -Prompt "1: $subsidiaryCompany2AP `n2: $parentCompanyBeijing `n3: $parentCompanyShang `n4: $parentCompanyJiaxing`nSelect what company you would like to map"



switch ($switchCase)
{
    1{$officeLoc = $subsidiaryCompany2AP}
    2{$officeLoc = $parentCompanyBeijing}
    3{$officeLoc = $parentCompanyShang}
    4{$officeLoc = $parentCompanyJiaxing}

}


$id = Read-Host -Prompt "Enter the User ID Here"
Get-MgBetaUser -userid $id | select-object -property DisplayName , OfficeLocation
Write-Host "`n"
Update-MGBetaUser -userid $id -officeLocation $officeLoc
Get-MgBetaUser -userid $id | select-object -property DisplayName , OfficeLocation

SignatureBlock

