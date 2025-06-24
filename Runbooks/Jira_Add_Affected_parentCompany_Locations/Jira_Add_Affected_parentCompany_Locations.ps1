param(
    [string]$Reporter,
    [string]$Description,
    [string]$jiraTicket
)
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Example usage of the parameters
Write-Output "The Reporter is: $Reporter"
Write-Output "The Key is: $jiraTicket"
Write-Output "The description is: `n`n$Description`n`n`n"
Import-Module -Name "Microsoft.Graph.Authentication"
Import-module Az.Accounts
Import-Module Az.KeyVault




try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $connection | Out-Null
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}

try{
    $retrGraphSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "GraphAPIKey" -AsPlainText
    $retrGraphSecret | Out-Null
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}

#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId = "graphTenantID"

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$graphAppClientId = "graphAppID"
 
$graphRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "GraphAPIKey" -AsPlainText
 
# Construct the body to be used in Invoke-WebRequest
$graphAuthBody = @{
    client_id     = $graphAppClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret =  $graphRetrSecret
    grant_type    = "client_credentials"
}
 
# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
#connect to graph

Connect-MGGraph -AccessToken $graphSecureToken


#Jira
$jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
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
            try{
            Write-Output "No Match for $reporter. Reviewing the ticket details for a user to match to a location"
            $user = Get-MGBetaUser -userid $reporterExtracted -erroraction Stop
            }
            catch{
            # Get Authentication Token
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAPIBody -UseBasicParsing
            # Extract the Access Token
            $baseToken = ($tokenRequest.content | convertfrom-json).access_token
            $graphAPIHeader = @{
                "Authorization" = "Bearer $baseToken"
                "ConsistencyLevel" = "eventual"
            }
            $user = (Invoke-RestMethod -uri "https://graph.microsoft.com/v1.0/users?`$filter=proxyAddresses/any(x:x eq 'smtp:$reporterExtracted') OR proxyAddresses/any(x:x eq 'SMTP:$reporterExtracted')" -Headers $graphAPIHeader -Method Get -ContentType 'application/json').value
            }
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
    "parentCompany East" = "12034"
    "Location2" = "12035"
    "parentCompany Midwest" = "12036"
    "parentCompany Iowa" = "12037"
    "subsidiaryCompany1" = "12038"
    "parentCompany Europe BVBA" = "12039"
    "parentCompany (Milano) Europe, S.r.l." = "12040"
    "parentCompany (Sondrio) Europe, S.r.l." = "12041"
    "parentCompany (Beijing) Refrigeration Equipment Co., Ltd." = "12042"
    "parentCompany (Shanghai) Refrigeration Equipment Co., Ltd." = "12043"
    "parentCompany Australia (Pty.) Ltd." = "12044"
    "subsidiaryCompany2, Inc." = "12045"
    "parentCompany Dry Cooling, Inc." = "12046"
    "subsidiaryCompany4" = "12047"
    "parentCompany Europe A/S" = "12048"
    "parentCompany Brasil" = "12049"
    "subsidiaryCompany3" = "12050"
    "parentCompany Alcoil, Inc." = "12051"
    "parentCompany Air Cooling Systems (Jiaxing) Co., Ltd." = "12052"
    "parentCompany Iowa Sales & Engineering" = "12053"
    "parentCompany LMP" = "12054"
    "parentCompany Select Tech" = "12055"
    "parentCompany Europe GmbH" = "12056"
    "subsidiaryCompany2 Asia Pacific Sdn Bhd" = "12057"
    "subsidiaryCompany2 (Shanghai) Cooling Tower Co., Ltd." = "12058"
    "parentCompany Middle East DMCC" = "12059"
    "parentCompany S.A. (Pty.) Ltd." = "12060"
    "parentCompany Newton" = "12061"
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
    $response = Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket" -Method Put -Body $jsonPayload -Headers $headers
    Write-Output "Response: $response"
} catch {
    Write-Error "Failed to update issue: $_"
    Write-Output "Payload: $jsonPayload"
}
SignatureBlock

