# Connect to Azure AD
Connect-AzureAD

# Define the path to the CSV file
$csvFilePath = "C:\Temp\subsidiaryCompany1-shortName.csv"

# Import the CSV file
$guestUsers = Import-Csv $csvFilePath

# Loop through each row in the CSV file and create new guest users
foreach ($guestUser in $guestUsers) {

    # Define the properties of the new guest user
    $newGuestUser = @{
        InvitedUserDisplayName = $guestUser.DisplayName
        InvitedUserEmailAddress = $guestUser.trueEmail
        SendInvitationMessage = $False
        InvitedUserType = "Guest"
        InviteReDirectURL = "http://www.bing.com"
    }

    # Create the new guest user
    New-AzureADMSInvitation @newGuestUser
}
SignatureBlock

