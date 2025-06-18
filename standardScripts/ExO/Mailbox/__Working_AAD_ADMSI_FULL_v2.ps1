# Connect to Azure AD
Connect-AzureAD

# Define the path to the CSV file
$csvFilePath = "C:\Temp\anonSubsidiary-1.csv"

# Import the CSV file
$guestUsers = Import-Csv $csvFilePath

# Loop through each row in the CSV file and create new guest users
foreach ($guestUser in $guestUsers) {
if($guestUser.accountCreated -eq "N")
{
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
Else
    {  Write-Host "Already Done"}
}

$time = Get-Date
Write-Host "Starting Sleep for 10 minutes at: $time"
Start-Sleep -Seconds "30"

# Import the CSV file
$csvFilePath = "C:\Temp\Location_Directory.csv"
$users = Import-Csv $csvFilePath

# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
    # Get the user's object ID
    $objID = (Get-AzureADUser -SearchString $user.DisplayName).objectID

    # Set the Azure AD properties for the user based on the CSV entry
    Set-AzureADUser -ObjectId $objID `
                    -Company $user.Company `
                    -TelephoneNumber $user.Phone `
                    -ShowInAddressList $true

                  
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





