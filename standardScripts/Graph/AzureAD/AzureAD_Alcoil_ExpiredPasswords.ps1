# Get users with specified criteria
$users = Get-MSOLUser -all | Where-Object {($_.UserPrincipalName -like "*@Domain.extension4") -and ($_.passwordneverexpires -eq $false) -and (($_.LastPasswordChangeTimeStamp).AddDays(90) -lt (Get-Date))}

# Export UPNs to CSV
$csvPath = "C:\Temp\AlcoilExpiredPasswords_MSOL_DisplayName_Stamped.csv"
$users | Select-Object DisplayName , UserPrincipalName , LastPasswordChangeTimeStamp | Export-Csv -Path $csvPath -NoTypeInformation

# Disconnect from Azure AD

Write-Host "User principal names and time stamps exported to $csvPath"
SignatureBlock

