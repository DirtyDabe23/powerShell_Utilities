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
    if($user.office -like "*unique-Office-Location-0*")
        {
        Set-MSOLUser -ObjectId $user.objectID -Mobile "$null" -ErrorAction SilentlyContinue
        Write-Host $user.DisplayName " phone number has been removed"  
        }
    Else
        {
        Write-Host $user.DisplayName " is not in the unique-Office-Location-0"
        }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





