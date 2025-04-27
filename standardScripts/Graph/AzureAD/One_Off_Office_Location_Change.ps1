Clear-Host
$anonSubsidiary-1AP = 'unique-Company-Name-16'
$uniqueParentCompanyBeijing = 'uniqueParentCompany (Beijing) Refrigeration Equipment Co., Ltd.'
$uniqueParentCompanyShang = 'unique-Office-Location-9'
$uniqueParentCompanyJiaxing = 'unique-Office-Location-18'

$switchCase = Read-Host -Prompt "1: $anonSubsidiary-1AP `n2: $uniqueParentCompanyBeijing `n3: $uniqueParentCompanyShang `n4: $uniqueParentCompanyJiaxing`nSelect what company you would like to map"



switch ($switchCase)
{
    1{$officeLoc = $anonSubsidiary-1AP}
    2{$officeLoc = $uniqueParentCompanyBeijing}
    3{$officeLoc = $uniqueParentCompanyShang}
    4{$officeLoc = $uniqueParentCompanyJiaxing}

}


$id = Read-Host -Prompt "Enter the User ID Here"
Get-MgBetaUser -userid $id | select-object -property DisplayName , OfficeLocation
Write-Host "`n"
Update-MGBetaUser -userid $id -officeLocation $officeLoc
Get-MgBetaUser -userid $id | select-object -property DisplayName , OfficeLocation

# SIG # Begin signature block#Script Signature# SIG # End signature block









