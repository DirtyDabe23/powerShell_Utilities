# Connect to Azure AD
Connect-AzureAD

# Get all users in Azure AD
$users = Get-AzureADUser -All $true

# Loop through each user
foreach ($user in $users) {
  # Check if the user's office location is "parentCompany, Inc"
  if ($user.OfficeLocation -eq "parentCompany East") {
    # Set the user's business phone number to 4107562600
    $user.BusinessPhones = @("4107562600")
    Set-AzureADUser -ObjectId $user.ObjectId -BusinessPhones $user.BusinessPhones
  }
}

# Disconnect from Azure AD
Disconnect-AzureAD

SignatureBlock

