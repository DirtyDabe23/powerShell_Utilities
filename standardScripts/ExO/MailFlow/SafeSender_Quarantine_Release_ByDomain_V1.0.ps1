$StartTime = Get-Date 
#THIS SCRIPT MUST BE RUN IN POWERSHELL 5.1, IT DOES NOT WORK IN POWERSHELL 7 FOR WHATEVER REASON

$apiVersion = "2020-06-01"
$resource = "https://vault.azure.net"
$endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$resource,$apiVersion
$secretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($wwwAuthHeader -match "Basic realm=.+")
    {
        $secretFile = ($wwwAuthHeader -split "Basic realm=")[1]
    }
}
Write-Host "Secret file path: " $secretFile`n
$secret = Get-Content -Raw $secretFile
$response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'; Authorization="Basic $secret"} -UseBasicParsing
if ($response)
{
    $token = (ConvertFrom-Json -InputObject $response.Content).access_token
    Write-Host "Access token: " $token
}

$retrSecret = (Invoke-RestMethod -Uri 'https://PREFIX-vault.vault.azure.net/secrets/$graphSecretName?api-version=2016-10-01' -Method GET -Headers @{Authorization="Bearer $token"}).value

#secureGraph
#The Tenant ID from App Registrations
$tenantId = $tenantIDString

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$clientId = $appIDString


# Construct the body to be used in Invoke-WebRequest
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $retrSecret
    grant_type    = "client_credentials"
}

# Get Authentication Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Extract the Access Token
$secureToken = ($tokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
#connect to graph
Connect-MGGraph -AccessToken $secureToken


#connect to Exchange Online
$exoCertThumb = "FE63624C5EE7EF5F9CC0ABEFB0EA3CC9390DC904"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
    
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

$sqlcn = New-Object System.Data.SqlClient.SqlConnection
$sqlcn.ConnectionString = "Server=PREFIX-sql-qa1\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
$sqlcn.Open()
$sqlcmd=$sqlcn.CreateCommand()
$query="select * from dbo.Domains"
$sqlcmd.CommandText = $query
$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
$data = New-Object System.Data.DataSet
$adp.Fill($data) | Out-Null
$domains = $data.Tables
$sqlcn.close()


$pagecount = 1
$pages = $true
$quarantinelist = @()
while ($pages){
$quarantinedmessages = Get-QuarantineMessage -domain $domains.domain -releasestatus "notreleased" -pagesize 1000  -Page $pagecount
$quarantinedmessages | Release-QuarantineMessage -releasetoall -allowsender -reportfalsepositive -actionType "Release" -whatif
if (($quarantinedmessages | measure).count -lt 1000 )
    {
    $pages = $false
    }
$pagecount++
}


$endtime = Get-Date 

$netTime = $endtime - $StartTime

Write-Output "Time taken for [Quarantine Evaluation] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block








