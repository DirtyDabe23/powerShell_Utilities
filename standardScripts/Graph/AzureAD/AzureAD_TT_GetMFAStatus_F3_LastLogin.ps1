# Retrieve all MSOL users with "SPE_E5" license assigned
$users = Get-MsolUser -All | Where-Object { ($_.Licenses.AccountSKUID -like "*SPE_F1*") -and ($_.office -eq "unique-Office-Location-0") }
$users = $users | Sort-Object -property "UserPrincipalName"

# Iterate through each user and get Office and MFA status
$userStatus = @()

foreach ($user in $users) {
    $mfaStatus = $user.StrongAuthenticationRequirements.State
    if ([string]::IsNullOrEmpty($mfaStatus)) {
        $mfaStatus = "Not Configured"
    }
    $uName = $user.UserPrincipalName
    $lastlogon = (Get-AzureADAuditSignInLogs -Filter "startsWith(userPrincipalName, '$uName')" -top 1).createddatetime

    $userStatus += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        OfficeStatus = $user.Office
        MFAStatus = $mfaStatus
        UserType = $user.Usertype
        LastLogon = $lastlogon
    }
    WRite-Host "Last user assessed: " $user.UserPrincipalName
    Start-Sleep -seconds 5
}

# Export the results to CSV
$userStatus |  Export-Csv -Path "C:\Temp\MFAStatusByOfficeF3.csv" -NoTypeInformation

Write-Host "CSV export completed. File saved at C:\Temp\MFAStatusByOffice.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block




