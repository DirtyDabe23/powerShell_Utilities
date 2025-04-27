$property1 = [Collections.Generic.Dictionary[[String],[String]]]::new()
$property1.Add("streetAddress", [NullString]::Value)



# Connect to Azure AD
Connect-AzureAD


# Get all users in Azure AD
$users = Get-AzureADUser -All $true

# Loop through each user and remove their street address
foreach ($user in $users) 
{
        Set-AzureADUser -ObjectId $user.objectID -ExtensionProperty $property1 -ErrorAction SilentlyContinue
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



