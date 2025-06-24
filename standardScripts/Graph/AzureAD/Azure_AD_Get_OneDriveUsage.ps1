# Connect to Microsoft Graph API
Connect-Graph

# Retrieve all users with UPN ending in @Domain.extension1
$parentCompanyUsers = Get-MgUser -Filter "UserPrincipalName endswith '@Domain.extension1'"

# Initialize an array to store the user data
$userData = @()

# Loop through each user and retrieve OneDrive storage size used
foreach ($user in $parentCompanyUsers) {
    $OneDriveUsage = Get-MgDriveUsage -UserId $user.Id
    $userObj = [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        StorageUsed = $OneDriveUsage.Used / 1MB
    }
    $userData += $userObj
}

# Export the data to a CSV file
$userData | Export-Csv -Path "C:\onedrive-usage.csv" -NoTypeInformation
SignatureBlock

