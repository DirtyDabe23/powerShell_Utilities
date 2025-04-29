#Connection to the Jira API after getting the token from the Key Vault
Param(
    [Parameter(Mandatory = $true)]
    [string] $ghdKey,
    [Parameter(Mandatory = $true)]
    [PSCustomObject] $parentD42,
    [Parameter(Mandatory = $true)]
    [PSCustomObject] $subtasks  
)

Write-Output "Key is: $ghdKey `n`n`n"
Write-Output "Parent Device42 is: $parentD42 `n`n`n`n"
Write-Output "Subtasks are: $subtasks `n`n`n`n"

try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}


#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeaders = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}


# Remove curly braces
$trimmedString = $parentD42.Trim('{}')

# Split the string into key-value pairs
$keyValuePairs = $trimmedString -split ',\s*'

# Create a hashtable to store the key-value pairs
$hashtable = @{}

# Loop through each pair and split them into key and value
foreach ($pair in $keyValuePairs) {
    $key, $value = $pair -split '='
    $hashtable[$key] = $value
}

# Manually construct the PSCustomObject in the correct order
$parentD42Proper = [PSCustomObject]@{
    originId = $hashtable['originId']
    value = $hashtable['value']
    serializedOrigin = $hashtable['serializedOrigin']
    appKey = $hashtable['appKey']
}

$inputString = $subtasks

# Split the string into individual values
$values = $inputString -split ',\s*'

# Create an array of PSCustomObjects
$newSubTasks = foreach ($value in $values) {
    [PSCustomObject]@{
        Key = $value
    }
}

# Output the array of PSCustomObjects
$newSubTasks




ForEach ($subTask in $newSubTasks)
{

    $subTaskKey = $subTask.Key


$payload = @{
    "update" = @{
        "customfield_10792" = @(
        @{"set" =  @($parentD42Proper)})

    }
}



$jsonPayload = $payload | ConvertTo-Json -Depth 10

# Log payload for debugging
Write-Output "Payload (JSON): $jsonPayload"



# Make the PUT request
$response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$subTaskKey" -Method Put -Body $jsonPayload -Headers $jiraHeaders



}
# SIG # Begin signature block#Script Signature# SIG # End signature block









