param(
    [string]$Reporter,
    [string]$Description,
    [string]$Key
)

# Example usage of the parameters
Write-Output "The Reporter is: $Reporter"
Write-Output "The Key is: $Key"
Write-Output "The description is: `n`n$Description`n`n`n"

Connect-MGGraph -Identity -NoWelcome


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
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}


# Fetch user information
Try{
    $user = Get-MGBetaUser -userid $Reporter -erroraction Stop
    }
    Catch{
        $regex = "[a-zA-Z][a-z0-9!#\$%&'*+/=?^_`{|}~-]*(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        $match = $description | Select-String -Pattern $regex
        If ($null -eq $match)
        {
            $searchUser = "smtp:"+$reporter
            $user = Get-MGBetaUser -search "proxyAddresses:$searchUser" -ConsistencyLevel eventual
        }
        Elseif ($null -ne $match)
        {
            $reporterExtracted = $match.matches.value
            $user = Get-MGBetaUser -userid $reporterExtracted
        }
    }
    
    If ($null -eq $user)
    {
        Write-Output "User is null, unable to review or add an affected location"
        Exit 1
    }
    
    If ($null -eq $user.officeLocation)
    {
        Write-Output "User Office Location is null, unable to review or add an affected location"
        Exit 1
    }
    
    Write-Output "User is $($user.UserPrincipalName) and their Office Location is $($user.OfficeLocation)"

# Define a mapping from location names to OptionIDs
$locationMapping = @{
    "unique-Office-Location-0" = "12034"
    "unique-Office-Location-1" = "12035"
    "unique-Office-Location-2" = "12036"
    "unique-Office-Location-3" = "12037"
    "unique-Company-Name-20" = "12038"
    "unique-Company-Name-7" = "12039"
    "unique-Office-Location-6" = "12040"
    "unique-Office-Location-7" = "12041"
    "uniqueParentCompany (Beijing) Refrigeration Equipment Co., Ltd." = "12042"
    "unique-Office-Location-9" = "12043"
    "unique-Company-Name-3" = "12044"
    "unique-Company-Name-18" = "12045"
    "unique-Company-Name-5" = "12046"
    "unique-Company-Name-21" = "12047"
    "unique-Company-Name-6" = "12048"
    "unique-Company-Name-4" = "12049"
    "unique-Office-Location-16" = "12050"
    "unique-Company-Name-2" = "12051"
    "unique-Office-Location-18" = "12052"
    "unique-Company-Name-10" = "12053"
    "unique-Company-Name-11" = "12054"
    "unique-Office-Location-21" = "12055"
    "unique-Company-Name-8" = "12056"
    "unique-Company-Name-17" = "12057"
    "unique-Company-Name-16" = "12058"
    "unique-Company-Name-12" = "12059"
    "unique-Company-Name-14" = "12060"
    "unique-Office-Location-27" = "12061"
}

# Get user office locations as Jira option objects
$userLocation = @()  # Start with an empty array
foreach ($location in $user.OfficeLocation) {
    if ($locationMapping.ContainsKey($location)) {
        $userLocation += @{ "id" = $locationMapping[$location] }
    } else {
        Write-Warning "Location '$location' not found in mapping."
    }
}

# Debugging output to check user location
Write-Output "User Location: $userLocation"
$userLocation | ForEach-Object { Write-Output "Location ID: $($_.id)" }

# Ensure userLocation is an array, even if it contains only one item
if ($userLocation.Count -eq 1) {
    $userLocation = @($userLocation)
}

# Define the payload ensuring userLocation is an array of objects with IDs
$payload = @{
    "update" = @{
        "customfield_10923" = @(
            @{
                "set" = @($userLocation)  # Explicitly cast as an array
            }
        )
    }
}

# Debugging output for payload before JSON conversion
Write-Output "Payload (Hashtable): $payload"
$payload.update.customfield_10923[0].set | ForEach-Object { Write-Output "Set ID: $($_.id)" }

# Convert the payload to JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 10

# Log payload for debugging
Write-Output "Payload (JSON): $jsonPayload"

# Make the PUT request
try {
    $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key" -Method Put -Body $jsonPayload -Headers $headers
    Write-Output "Response: $response"
} catch {
    Write-Error "Failed to update issue: $_"
    Write-Output "Payload: $jsonPayload"
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



































