Clear-Host
Connect-MGGraph -NoWelcome
$users = Get-MGBetaUser -all -consistencylevel eventual

$filteredUsers = $users | Where-Object {(($_.Country -eq 'China') -or ($_.UsageLocation -eq 'CN')) -and ($_.CompanyName -ne 'Not Affiliated') -and ($_.CompanyName -ne 'subsidiaryCompany2 Asia Pacific Sdn Bhd') -and ($_.UserType -eq 'Member') -and ($_.AccountEnabled -eq $true)} | Select-Object -Property ID, DisplayName , OfficeLocation , CompanyName , Country , UsageLocation, OnPremisesSyncEnabled

ForEach ($user in $filteredUsers.id)
{
    Update-MGBetaUser -userid $user -CompanyName "parentCompany Refrigeration Equipment Co., Ltd" -UsageLocation "CN" -Country "China"
}

SignatureBlock

