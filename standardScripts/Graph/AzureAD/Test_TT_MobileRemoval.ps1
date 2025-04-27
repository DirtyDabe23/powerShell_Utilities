#Connect-AzureAD
$properties = [Collections.Generic.Dictionary[[String],[String]]]::new()
$properties.Add("Mobile", [NullString]::Value)

$user1 = Get-AzureADUser -SearchString "Test McTesterson"


if($user1.PhysicalDeliveryOfficeName -like "*Taneytown*")
    {
    Set-AzureADUser -ObjectId $user1.objectID -ExtensionProperty $properties -ErrorAction SilentlyContinue
    Write-Host $user1.DisplayName " phone number has been removed"  
    }
Else
    {
    Write-Host "User is not in the Taneytown MD"
    }


# Disconnect from Azure AD

# SIG # Begin signature block#Script Signature# SIG # End signature block






