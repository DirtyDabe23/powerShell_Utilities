#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId = $tenantIDString

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$graphAppClientId = $appIDString
 
$graphRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText
 
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

#connect to Exchange Online via the Certificate
$exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG


#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "JiraAPI" -AsPlainText

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
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$TicketNum = Read-Host -Prompt "Enter the Ticket Number (Ex: GHD-2157)"
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 
Write-Output $Form

#Authentication via KeyVault To Graph API:
$retrGraphSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText

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


$d42retrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "Device42API" -AsPlainText 
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
$connectionRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "ConnectionAPI" -AsPlainText

#Connection via the API or by Read-Host 
If ($null -eq $connectionRetrSecret)
{
    $connectionRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Connection
#$connectionAuthURI = "https://api.webqa.moredirect.com/service/rest/auth/oauth2?grant_type=PASSWORD&password=$connectionRetrSecret&username=GIT-CYOPS-Technical%40uniqueParentCompany.com"

$connectionAuthURI = "https://api.moredirect.com/service/rest/auth/oauth2?grant_type=PASSWORD&password=$connectionRetrSecret&username=GIT-CYOPS-Technical%40uniqueParentCompany.com"
# Get Authentication Token
$connectionToken = (Invoke-Restmethod -uri $connectionAuthURI).access_token


# Create headers using the Bearer token for authorization
$connectionHeader = @{
    "Authorization" = "Bearer $connectionToken"  # Bearer token for OAuth2
    "Accept"        = "*/*"  # Adding Accept header for expected response format
}

# Perform GET request to the assets endpoint
$shipmentPages = @()
#$shipments = Invoke-RestMethod -Uri "https://api.webqa.moredirect.com/service/rest/listing/shipments" -Headers $connectionHeader -Method Get
$shipments = Invoke-RestMethod -Uri "https://api.moredirect.com/service/rest/listing/shipments" -Headers $connectionHeader -Method Get
$shipmentPages += $shipments._embedded.entities
$nextPage = $shipments._links.next.href
$shipments = Invoke-RestMethod -Uri $nextPage -Headers $connectionHeader -Method Get
$shipmentPages | Select-Object -Property 'OrderDate','Address', 'City', 'State', 'Zip','CompanyName'

# SIG # Begin signature block#Script Signature# SIG # End signature block










