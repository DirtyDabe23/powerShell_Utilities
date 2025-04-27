param(
    [string]$Key,
    [string]$connectionOrderNumber
)

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

$maxPages = $shipments.page.totalpages

$pageCounter = 1 

While ($pageCounter -le $maxPages)
{
    $shipmentPages += $shipments._embedded.entities
    $nextPage = $shipments._links.next.href
    $shipments = Invoke-RestMethod -Uri $nextPage -Headers $connectionHeader -Method Get 
    $pageCounter++

}

If ($null -eq $connectionOrderNumber)
{
    $connectionOrderNumber = Read-Host -Prompt "Enter the Order Number from Connection"
}


$matchingOrder = $shipmentPages | Where-Object {($_.orderNum -eq $connectionOrderNumber)}

# SIG # Begin signature block#Script Signature# SIG # End signature block





