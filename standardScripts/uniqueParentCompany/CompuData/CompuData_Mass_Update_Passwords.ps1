$externalCompuDataUsers =  Get-ADUser -SearchBase 'OU=CompuData - External Sage Users - Non-Synching,DC=uniqueParentCompany,DC=COM'-Filter *

$date = Get-Date
$DoW = $date.DayOfWeek.ToString()
$Month = (Get-date $date -format "MM").ToString()
$Day = (Get-date $date -format "dd").ToString()
$pw = $DoW+$Month+$Day+"!" | ConvertTo-SecureString -AsPlainText -Force

ForEach ($user in $externalCompuDataUsers)
{
    Write-Output "Setting: $($user.UserPrincipalName) password"
    Set-ADAccountPassword $user.SamAccountName -NewPassword $pw
    Write-Output "Setting: $($user.UserPrincipalName) password to change at next logon"
    Set-ADUser $user.SamAccountName -ChangePasswordAtLogon $true
}


# SIG # Begin signature block#Script Signature# SIG # End signature block




