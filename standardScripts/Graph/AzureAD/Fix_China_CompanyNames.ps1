Clear-Host
Connect-MGGraph -NoWelcome
$users = Get-MGBetaUser -all -consistencylevel eventual

$filteredUsers = $users | Where-Object {(($_.Country -eq 'China') -or ($_.UsageLocation -eq 'CN')) -and ($_.CompanyName -ne 'Not Affiliated') -and ($_.CompanyName -ne 'unique-Company-Name-17') -and ($_.UserType -eq 'Member') -and ($_.AccountEnabled -eq $true)} | Select-Object -Property ID, DisplayName , OfficeLocation , CompanyName , Country , UsageLocation, OnPremisesSyncEnabled

ForEach ($user in $filteredUsers.id)
{
    Update-MGBetaUser -userid $user -CompanyName "unique-Company-Name-13" -UsageLocation "CN" -Country "China"
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





