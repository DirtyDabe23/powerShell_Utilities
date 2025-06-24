#The Tenant ID from App Registrations
$tenantId = "graphTenantID"

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$clientId = "graphAppID"
 

 
#The Client ID from certificates and secrets section
$clientSecret = 'ySH8Q~KHrho5lfthXYpJoYKRfexYuINnaGpzpcu9'
 
 
# Construct the body to be used in Invoke-WebRequest
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
 
# Get Authentication Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
 
# Extract the Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token

Connect-MGGraph -AccessToken $token
SignatureBlock

