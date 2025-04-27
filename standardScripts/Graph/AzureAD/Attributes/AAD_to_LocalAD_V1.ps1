$ladAtrName = Read-Host -Prompt "Enter the name of the attribute to check in local AD"
$aadAtrName = Read-Host -Prompt "Enter the name of corresponding attribute in AAD"


$locADUsers = Get-ADUser -filter * -SearchBase "ou=Employees,DC=uniqueParentCompany,DC=COM" -Properties * | Sort-Object -Property UserPrincipalName

foreach ($locADUser in $locADUsers)
{

    try
        {
            $AADUser = Get-AzureADUser -objectID $locADUser.UserPrincipalName
            $i = $true
        }
    catch
        {
            $i = $false
        }

    if($i -eq $true)
    { 
        $AADUser = Get-AzureADUser -objectID $locADUser.UserPrincipalName


        if(($locADuser.$ladAtrName -ne $null) -and ($locADUser.$ladAtrName -ne $AADUser.$aadAtrName) -and ($AADUser.$aadAtrName -ne $null))
        {

            write-host "USER: " $locADUser.UserPrincipalName " ATTRIBUTE: $ladAtrName updating from " $locADUser.$ladAtrName " to " $AADUser.$aadAtrName
            $AADval = $AADUser.$aadAtrName.trim()

            	$params = @{
                Identity          = $locADUser
                $ladAtrName         = $AADVal 
                }
	            Set-ADUser @params
        }
        Elseif ($locADuser.$ladAtrName -eq $null)
        {
            Write-Host "USER: " $locADUser.UserPrincipalName " ATTRIBUTE: $ladAtrName is blank in local AD"
        }
        Elseif ($locADUser.$ladAtrName -eq $AADUser.$aadAtrName)
        {
            Write-Host "USER: " $locADUser.UserPrincipalName " ATTRIBUTE: $ladATRName in local AD is equal to $aadAtrName in AzureAD edits are not needed"
        }
        Elseif($AADUser.$aadAtrName -eq $null)
        {
            WRite-Host "USER: " $locADUser.UserPrincipalName " ATTRIBUTE: $aadATRName is blank in AzureAD, no edits will be performed"
        }
    }
    Else
    {
        Write-Host "USER: " $locADUser.UserPrincipalName " does not exist in AzureAD"
    }
    
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





