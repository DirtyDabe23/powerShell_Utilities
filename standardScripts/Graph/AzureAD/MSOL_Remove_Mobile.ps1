Connect-MSOLService
# Get all users in Azure AD
$users = Get-MSOLUser -All

# Loop through each user and remove their mobile phone number
foreach ($user in $users) 
{
    if($user.office -like "*Location*")
        {
        Set-MSOLUser -ObjectId $user.objectID -Mobile "$null" -ErrorAction SilentlyContinue
        Write-Host $user.DisplayName " phone number has been removed"  
        }
    Else
        {
        Write-Host $user.DisplayName " is not in the Location MD"
        }
}


foreach ($user in $users) 
{
    if($user.office -like "*parentCompany East*")
        {
        Set-MSOLUser -ObjectId $user.objectID -Mobile "$null" -ErrorAction SilentlyContinue
        Write-Host $user.DisplayName " phone number has been removed"  
        }
    Else
        {
        Write-Host $user.DisplayName " is not in the parentCompany East"
        }
}
SignatureBlock

