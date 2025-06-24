$properties = [Collections.Generic.Dictionary[[String],[String]]]::new()
$properties.Add("Mobile", [NullString]::Value)
# Connect to Azure AD
Connect-AzureAD


# Get all users in Azure AD
$users = Get-AzureADUser -All $true

# Loop through each user and remove their mobile phone number
foreach ($user in $users) 
{
    if($user.PhysicalDeliveryOfficeName -like "*Location*")
        {
        Set-AzureADUser -ObjectId $user.objectID -ExtensionProperty $properties -ErrorAction SilentlyContinue
        Write-Host $user.DisplayName " phone number has been removed"  
        }
    Else
        {
        Write-Host $user.DisplayName " is not in the Location MD"
        }
}


foreach ($user in $users) 
{
    if($user.PhysicalDeliveryOfficeName -like "*parentCompany East*")
        {
        Set-AzureADUser -ObjectId $user.objectID -ExtensionProperty $properties -ErrorAction SilentlyContinue
        Write-Host $user.DisplayName " phone number has been removed"  
        }
    Else
        {
        Write-Host $user.DisplayName " is not in the parentCompany East"
        }
}

# Disconnect from Azure AD

SignatureBlock

