#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId = $tenantIDString

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$graphAppClientId = $appIDString
 
 
# Construct the body to be used in Invoke-WebRequest
$graphAuthBody = @{
    client_id     = $graphAppClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = Read-Host -Prompt "Enter the client secret" -MaskInput
    grant_type    = "client_credentials"
}
 
# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
#connect to graph
Connect-MGGraph -AccessToken $graphSecureToken

#connect to Exchange Online
$exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

#Connection to the Jira API after getting the token from the Key Vault
$jiraVaultName = 'jiraAPIKeyKey'
$jiraAPIKeyKeyVersion = "2020-06-01"
$jiraResource = "https://vault.azure.net"
$jiraEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$jiraResource,$jiraAPIKeyKeyVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $jiraWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($jiraWWWAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($jiraWWWAuthHeader -split "Basic realm=")[1]
    }
}
$jiraSecret = Get-Content -Raw $jiraSecretFile
$jiraResponse = Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($jiraResponse)
{
    $jiraToken = (ConvertFrom-Json -InputObject $jiraResponse.Content).access_token
}

$jiraRetrSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($jiraVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}



#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$TicketNum = Read-Host -Prompt "Enter the Ticket Number (Ex: GHD-2157)"
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $headers
$NewForm = ConvertTo-Json $Form
$NewForm2 = ConvertFrom-Json $NewForm
$uData = $NewForm2.fields

Write-Output $uData

#Authentication via KeyVault To Graph:
$graphVaultName = '$graphSecretName'
$graphVaultAPIVersion = "2020-06-01"
$graphVaultResource = "https://vault.azure.net"
$graphVaultEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$graphVaultResource,$graphVaultAPIVersion
$graphSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $graphVaultEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $graphWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($graphWWWAuthHeader -match "Basic realm=.+")
    {
        $graphSecretFile = ($graphWWWAuthHeader -split "Basic realm=")[1]
    }
}
$graphSecret = Get-Content -Raw $graphSecretFile
$graphResponse = Invoke-WebRequest -Method GET -Uri $graphVaultEndpoint -Headers @{Metadata='True'; Authorization="Basic $graphSecret"} -UseBasicParsing
if ($graphResponse)
{
    $graphToken = (ConvertFrom-Json -InputObject $graphResponse.Content).access_token
}

$retrGraphSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($graphVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $graphToken"}).value

#secureGraph
#The Tenant ID from App Registrations
$graphTenantId = $tenantIDString

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$graphClientID = $appIDString
 
 
# Construct the body to be used in Invoke-WebRequest
$graphBody = @{
    client_id     = $graphClientID
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $retrGraphSecret
    grant_type    = "client_credentials"
}
 
# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphBody -UseBasicParsing
# Extract the Access Token
$secureGraphToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
#connect to graph
Connect-MGGraph -AccessToken $secureGraphToken -NoWelcome


#Authentication via KeyVault To Graph API:
$graphVaultName = '$graphSecretName'
$graphVaultAPIVersion = "2020-06-01"
$graphVaultResource = "https://vault.azure.net"
$graphVaultEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$graphVaultResource,$graphVaultAPIVersion
$graphSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $graphVaultEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $graphWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($graphWWWAuthHeader -match "Basic realm=.+")
    {
        $graphSecretFile = ($graphWWWAuthHeader -split "Basic realm=")[1]
    }
}
$graphSecret = Get-Content -Raw $graphSecretFile
$graphResponse = Invoke-WebRequest -Method GET -Uri $graphVaultEndpoint -Headers @{Metadata='True'; Authorization="Basic $graphSecret"} -UseBasicParsing
if ($graphResponse)
{
    $graphToken = (ConvertFrom-Json -InputObject $graphResponse.Content).access_token
}

$retrGraphSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($graphVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $graphToken"}).value

#secureGraph
#The Tenant ID from App Registrations
$graphTenantId = $tenantIDString

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$graphClientID = $appIDString

If ($null -eq $retrGraphSecret)
{
    $retrGraphSecret = Read-Host -Prompt "Enter the Graph API Secret" -MaskInput
}
 
# Construct the body to be used in Invoke-WebRequest for the Authentication Token.
$graphAPIBody = @{
    client_id     = $graphClientID
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $retrGraphSecret
    grant_type    = "client_credentials"
}
 
# Get Authentication Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAPIBody -UseBasicParsing
# Extract the Access Token
$baseToken = ($tokenRequest.content | convertfrom-json).access_token

$graphAPIHeader = @{
    "Authorization" = "Bearer $baseToken"
    "ConsistencyLevel" = "eventual"
}
$aadUsers = Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,signInActivity,companyName,onPremisesSyncEnabled&$filter=companyName ne null and userType eq ''Member'' and NOT(companyName eq ''Not Affiliated'') and accountEnabled eq true and NOT(department eq ''Executive'')&$count=true' -Headers $graphAPIHeader -Method Get -ContentType "application/json"
Write-Output $aadusers.value



#Device42 Authencation:
#Auth To Device42 via KeyVault
#Connection to the Jira API after getting the token from the Key Vault
$d42VaultName = 'Device42API'
$d42APIVersion = "2020-06-01"
$d42Resource = "https://vault.azure.net"
$d42Endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$d42Resource,$d42APIVersion
$d42SecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $d42Endpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($wwwAuthHeader -match "Basic realm=.+")
    {
        $d42SecretFile = ($wwwAuthHeader -split "Basic realm=")[1]
    }
}
$d42Secret = Get-Content -Raw $d42SecretFile
$d42Response = Invoke-WebRequest -Method GET -Uri $d42Endpoint -Headers @{Metadata='True'; Authorization="Basic $d42Secret"} -UseBasicParsing
if ($d42Response)
{
    $d42Token = (ConvertFrom-Json -InputObject $d42Response.Content).access_token
}

$d42retrSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($d42VaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $d42Token"}).value
If ($null -eq $d42retrSecret)
{
    $d42retrSecret = Read-Host "Enter the Device42 API Secret" -MaskInput
}
#This pulls all the end users
$d42apiURL = 'https://itam.uniqueParentCompany.com/api/1.0/endusers/'

# Convert the username and password to a Base64 string for Basic Authentication
$d42base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("GIT_API:$d42retrSecret")))

$d42Headers = @{
    "Authorization" = "Basic $d42base64AuthInfo"
    "Content-Type" = "application/json"
}

$device42EndUsers = (Invoke-RestMethod -Uri $d42apiURL -Method Get -Headers $d42Headers).values
Write-Output $device42EndUsers

#Connection to the Connection API after getting the token from the Key Vault
$connectionVaultName = 'ConnectionAPI'
$connectionAPIVersion = "2020-06-01"
$connectionResource = "https://vault.azure.net"
$connectionEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$connectionResource,$connectionAPIVersion
$connectionSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $connectionEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $connectionWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($connectionWWWAuthHeader -match "Basic realm=.+")
    {
        $connectionSecretFile = ($connectionWWWAuthHeader -split "Basic realm=")[1]
    }
}
$connectionSecret = Get-Content -Raw $connectionSecretFile
$connectionResponse = Invoke-WebRequest -Method GET -Uri $connectionEndpoint -Headers @{Metadata='True'; Authorization="Basic $connectionSecret"} -UseBasicParsing
if ($connectionResponse)
{
    $connectionToken = (ConvertFrom-Json -InputObject $connectionResponse.Content).access_token
}

$connectionRetrSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($connectionVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $connectionToken"}).value

#Connection via the API or by Read-Host 
If ($null -eq $connectionRetrSecret)
{
    $connectionRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Connection


$connectionAuthURI = "https://api.webqa.moredirect.com/service/rest/auth/oauth2?grant_type=PASSWORD&password=$connectionRetrSecret&username=GIT-CYOPS-Technical%40uniqueParentCompany.com"

# Get Authentication Token
$connectionToken = (Invoke-Restmethod -uri $connectionAuthURI).access_token


# Create headers using the Bearer token for authorization
$connectionHeader = @{
    "Authorization" = "Bearer $connectionToken"  # Bearer token for OAuth2
    "Accept"        = "*/*"  # Adding Accept header for expected response format
}

# Perform GET request to the assets endpoint
$shipmentPages = @()
$shipments = Invoke-RestMethod -Uri "https://api.webqa.moredirect.com/service/rest/listing/shipments" -Headers $connectionHeader -Method Get



$shipmentPages += $shipments._embedded.entities
$nextPage = $shipments._links.next.href
$shipments = Invoke-RestMethod -Uri $nextPage -Headers $connectionHeader -Method Get

$shipmentPages | Select-Object -Property 'OrderDate','Address', 'City', 'State', 'Zip','CompanyName'
# SIG # Begin signature block#Script Signature# SIG # End signature block












