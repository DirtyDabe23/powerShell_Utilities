# Set the credentials to connect to Azure AD
$credential = Get-Credential

# Connect to Azure AD
Connect-AzureAD -Credential $credential

# Define the path to the CSV file
$csvFilePath = "C:\Temp\REPS_TEST.csv"

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

# SIG # Begin signature block#Script Signature# SIG # End signature block



