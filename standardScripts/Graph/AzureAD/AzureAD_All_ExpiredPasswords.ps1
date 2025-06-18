# Get users with specified criteria
$users = Get-MSOLUser -all | Where-Object {($_.passwordneverexpires -eq $false) -and (($_.LastPasswordChangeTimeStamp).AddDays(90) -lt (Get-Date))}

# Export UPNs to CSV
$csvPath = "C:\Temp\AllUsers_ExpiredPasswords_MSOL_DisplayName_Stamped.csv"
$users | Select-Object DisplayName , UserPrincipalName , LastPasswordChangeTimeStamp | sort-object -Property userprincipalname | Export-Csv -Path $csvPath -NoTypeInformation

# Disconnect from Azure AD

Write-Host "User principal names and time stamps exported to $csvPath"
# SIG # Begin signature block#Script Signature# SIG # End signature block



