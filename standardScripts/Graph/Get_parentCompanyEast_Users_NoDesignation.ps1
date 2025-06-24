$allUsers = Get-MgBetaUser -All -ConsistencyLevel eventual | Select-Object -Property *
$employees = $allUsers | where {($_.CompanyName -ne 'Not Affiliated') -and ($_.UserType -eq 'Member') -and ($_.AccountEnabled -eq $true)}
$parentCompanyEastEmployees = $employees | where {($_.OfficeLocation -eq 'parentCompany East')}
$parentCompanyEastEmployeesNoDesig = $parentCompanyEastEmployees | where {($_.OnPremisesExtensionAttributes.ExtensionAttribute1 -ne 'Office') -and ($_.OnPremisesExtensionAttributes.ExtensionAttribute1 -ne 'Shop')}
SignatureBlock

