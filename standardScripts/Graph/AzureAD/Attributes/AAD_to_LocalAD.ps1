$locADUsers = Get-ADUser -filter * -SearchBase "ou=Employees,DC=uniqueParentCompany,DC=COM"

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
# SIG # Begin signature block#Script Signature# SIG # End signature block





