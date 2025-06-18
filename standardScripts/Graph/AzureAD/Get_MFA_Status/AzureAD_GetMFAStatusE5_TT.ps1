# Retrieve all MSOL users with "SPE_E5" license assigned
$users = Get-MsolUser -All | Where-Object { ($_.Licenses.AccountSKUID -like "*SPE_E5*") -and ($_.office -eq "unique-Office-Location-0") }

# Iterate through each user and get Office and MFA status
$userStatus = @()

foreach ($user in $users) {
    $mfaStatus = $user.StrongAuthenticationRequirements.State
    if ([string]::IsNullOrEmpty($mfaStatus)) {
        $mfaStatus = "Not Configured"
    }

    $userStatus += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        OfficeStatus = $user.Office
        MFAStatus = $mfaStatus
        UserType = $user.Usertype
    }
}

# Export the results to CSV
$userStatus | Sort-Object -property "UserPrincipalName" |  Export-Csv -Path "C:\Temp\0717_MFAStatusByOfficeE5.csv" -NoTypeInformation -Force

Write-Host "CSV export completed. File saved at C:\Temp\0630_MFAStatusByOfficeE5.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block






