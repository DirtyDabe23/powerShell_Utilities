# Define the office location and group names
$officeLocation = "unique-Office-Location-0"
$alphaTestGroup = "___GIT_Alpha_TestGroup"
$betaTestGroup = "___GIT_Beta_TestGroup"

# Get all Azure AD users
$allUsers = Get-AzureADUser -All $true

# Create an empty array to store the user principal names
$userPrincipalNames = @()

# Iterate through each user
foreach ($user in $allUsers) {
    # Get the user's physical delivery office location
    $userLocation = $user.OfficeLocation

    # Check if the user is already a member of the test groups
    $memberOfAlphaTestGroup = $user | Get-AzureADUserMembership | Where-Object {$_.DisplayName -eq $alphaTestGroup}
    $memberOfBetaTestGroup = $user | Get-AzureADUserMembership | Where-Object {$_.DisplayName -eq $betaTestGroup}

    # Check if the user meets the conditions
    if ($userLocation -eq $officeLocation -and !$memberOfAlphaTestGroup -and !$memberOfBetaTestGroup) {
        # Add the user principal name to the array
        $userPrincipalNames += $user.UserPrincipalName
    }
}

# Display the user principal names
Write-Host "Users who meet the conditions:"
$userPrincipalNames
# SIG # Begin signature block#Script Signature# SIG # End signature block






