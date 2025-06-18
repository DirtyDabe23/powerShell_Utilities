$user1 = Get-AzureADUser -objectID $user1.objectID
Set-AzureADUser -ObjectId $user1.ObjectID -mobile "7178188834"

$properties = [Collections.Generic.Dictionary[[String],[String]]]::new()
$properties.Add("Mobile", [NullString]::Value)
Set-AzureADUser -ObjectId $user1.objectID -ExtensionProperty $properties
$user1 = Get-AzureADUser -objectID $user1.objectID
$user1 | Format-List
# SIG # Begin signature block#Script Signature# SIG # End signature block




