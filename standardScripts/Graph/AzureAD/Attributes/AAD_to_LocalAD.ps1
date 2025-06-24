$locADUsers = Get-ADUser -filter * -SearchBase "ou=Employees,DC=parentCompany,DC=COM"

foreach ($locADUser in $locADUsers)
{
    if(Get-AzureADUser -SearchString $locADUser.SamAccountName)
    {
        Write-Host $locADUser.UserPrincipalName " exists in AzureAD"
        
    }
    Else
    {
      $null
    }
}
SignatureBlock

