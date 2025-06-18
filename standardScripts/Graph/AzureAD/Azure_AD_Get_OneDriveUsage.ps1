# Connect to Microsoft Graph API
Connect-Graph

# Retrieve all users with UPN ending in @uniqueParentCompany.com
$uniqueParentCompanyUsers = Get-MgUser -Filter "UserPrincipalName endswith '@uniqueParentCompany.com'"

# Initialize an array to store the user data
$userData = @()

# Loop through each user and retrieve OneDrive storage size used
foreach ($user in $uniqueParentCompanyUsers) {
    $OneDriveUsage = Get-MgDriveUsage -UserId $user.Id
    $userObj = [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        StorageUsed = $OneDriveUsage.Used / 1MB
    }
    $userData += $userObj
}

# Export the data to a CSV file
$userData | Export-Csv -Path "C:\onedrive-usage.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block




