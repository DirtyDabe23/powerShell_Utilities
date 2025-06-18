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
    if($user.PhysicalDeliveryOfficeName -like "*unique-Office-Location-0*")
        {
        Set-AzureADUser -ObjectId $user.objectID -ExtensionProperty $properties -ErrorAction SilentlyContinue
        Write-Host $user.DisplayName " phone number has been removed"  
        }
    Else
        {
        Write-Host $user.DisplayName " is not in the unique-Office-Location-0"
        }
}

# Disconnect from Azure AD

# SIG # Begin signature block#Script Signature# SIG # End signature block






