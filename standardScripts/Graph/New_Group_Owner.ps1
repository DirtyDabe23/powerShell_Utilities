Connect-ExchangeOnline
Connect-MsolService

$groups = Get-UnifiedGroup | Where-Object {$_.RecipientTypeDetails -match "Group|DistributionList|DynamicDistributionGroup|MailEnabledSecurityGroup"}
foreach ($group in $groups) {
    Add-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -Links "$userName@uniqueParentCompany.com" -WhatIf
}
foreach ($group in $groups) {
    Add-UnifiedGroupLinks -Identity $group.Identity -LinkType Owners -Links "$userName@uniqueParentCompany.com" -WhatIf
}


$group1 = "Test_Group1"
$gID = (Get-MGgroup -ConsistencyLevel Eventual -search "DisplayName:$group1").ID
$uID = (Get-MgUser -Search "DisplayName:David Drosdick" -ConsistencyLevel eventual).Id

New-MgGroupMember -GroupId $gID -DirectoryObjectId $uID



$groupId = "Test_Group1"
$userId = "$userName@uniqueParentCompany.com" # Replace with the ID or UPN of the user you want to add

# Create the JSON payload for adding the user to the group
$body = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId"
} | ConvertTo-Json


# Add the user to the group
$uri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/\$ref"
Invoke-MgGraphRequest -Method POST -URI $uri -Content $body






#version 2
$groupId = "Test_Group1"
$userId = "Brandon.Ulsh@uniqueParentCompany.com" # Replace with the ID or UPN of the user you want to add

# Create the JSON payload for adding the user to the group
$body = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId"
} | ConvertTo-Json

# Create headers with content type
$headers = @{
    "Content-Type" = "application/json"
}

# Add the user to the group
$uri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/\$ref"
Invoke-MgGraphRequest -Method POST -URI $uri -Content $body -Headers $headers

Write-Output "User added to group successfully."

#version 3
$groupId = "Test_Group1"
$userId = "$userName@uniqueParentCompany.com" # Replace with the ID or UPN of the user you want to add

# Create the JSON payload for adding the user to the group
$body = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId"
} | ConvertTo-Json

# Create headers with content type
$headers = @{
    "Content-Type" = "application/json"
}

# Add the user to the group
$uri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/\$ref"
Invoke-MgGraphRequest -Method POST -URI $uri -Content $body -Headers $headers

Write-Output "User added to group successfully."



#version 4

$groupId = "Test_Group1"
$userId = "$userName@uniqueParentCompany.com" # Replace with the ID or UPN of the user you want to add

# Create the JSON payload for adding the user to the group
$body = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId"
} | ConvertTo-Json

# Create headers with content type
$headers = @{
    "Content-Type" = "application/json"
}

# Add the user to the group
$uri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/\$ref"
Invoke-MgGraphRequest -Method POST -URI $uri -Content $body -Headers $headers

Write-Output "User added to group successfully."

# SIG # Begin signature block#Script Signature# SIG # End signature block





