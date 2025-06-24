#Token and required information to connect to Jira's API
#The Tenant ID from App Registrations
$tenantId = "graphTenantID"

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$clientId = "graphAppID"
 

 
#The Client ID from certificates and secrets section
$clientSecret = 'GraphAPI'
 
 
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
#connect to graph
Connect-MGGraph -AccessToken $token

$Text = ‘david.drosdick@Domain.extension1:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$EncodedText

#Set the Header
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}



#How to get all new user onboarding requests
$pendingRequests = Invoke-RestMethod -Method get -uri 'https://parentCompany.atlassian.net/rest/api/2/search?jql=summary%20~%20"Bulk%20Manager%20Change"' -Headers $headers
$pendingRequests.issues.key
SignatureBlock

