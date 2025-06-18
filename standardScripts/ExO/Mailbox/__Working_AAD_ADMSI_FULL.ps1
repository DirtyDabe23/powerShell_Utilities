# Set the credentials to connect to Azure AD
$credential = Get-Credential

# Connect to Azure AD
Connect-AzureAD -Credential $credential

# Define the path to the CSV file
$csvFilePath = "C:\Temp\REPS_TEST3.csv"

# Import the CSV file
$guestUsers = Import-Csv $csvFilePath

# Loop through each row in the CSV file and create new guest users
foreach ($guestUser in $guestUsers) {
    # Define the properties of the new guest user
    $newGuestUser = @{
        InvitedUserDisplayName = $guestUser.DisplayName
        InvitedUserEmailAddress = $guestUser.PrimarySMTPAddress
        SendInvitationMessage = $False
        InvitedUserType = "Guest"
        InviteReDirectURL = "http://www.bing.com"
    }

    # Create the new guest user
    New-AzureADMSInvitation @newGuestUser
}

$time = Get-Date
Write-Host "Starting Sleep for 10 minutes at: $time"
Start-Sleep -Seconds "600"

# Import the CSV file
$csvPath = "C:\Temp\REPS_TEST3.csv"
$users = Import-Csv $csvPath

# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
    # Get the user's object ID
    $objID = (Get-AzureADUser -SearchString $user.DisplayName).objectID
    $newTitle = $user.title + " " + $user.Company

    # Set the Azure AD properties for the user based on the CSV entry
    Set-AzureADUser -ObjectId $objID `
                    -Mobile $user.MobilePhone `
                    -Company $user.Company `
                    -TelephoneNumber $user.Phone `
                    -JobTitle $newTitle
                    -ShowInAddressList $true

                  
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




