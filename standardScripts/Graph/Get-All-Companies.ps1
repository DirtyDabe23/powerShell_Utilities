$companies = Get-MgBetaUser -all -ConsistencyLevel eventual `
| Where-Object {($_.UserType -eq 'MEmber') -and ($_.AccountEnabled -eq $True)} `
| Select-Object -Property CompanyName -unique
$host.ui.rawui.readkey("noEcho,IncludeKeyDown") | out-Null
$includedCompanies = $companies | where {($_.CompanyNAme -ne "") -and ($_.CompanyNAme -ne "Not Affiliated") -and ($_.CompanyName -ne $null)}
$sortedCompanies = $includedCompanies | sort -Property CompanyName
clear-Host
$sortedCompanies
Write-Output 'Use $sortedCompanies to get this list'
Write-Output "`n`n`n-Press Any Key To Proceed-"

$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
# SIG # Begin signature block#Script Signature# SIG # End signature block




