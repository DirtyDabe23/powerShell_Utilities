# Set the parameters
$tenantId = $tenantIDString # The Tenant ID from App Registrations
$clientId = $appIDString # The Client ID from App Registrations
$clientSecret = $secret # The Client Secret from App Registrations
$userPrincipalName = "test.mctesterson@uniqueParentCompany.com" # The user's UPN whose mobile phone number is to be updated
$mobilePhoneNumber = "7178188834" # The new mobile phone number

# Construct the authentication URL
$authUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Construct the body of the request
$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
}

# Get the access token
$response = Invoke-RestMethod -Uri $authUrl -Method POST -Body $body
$accessToken = $response.access_token

# Set the headers
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type"  = "application/json"
}

# Get the user's object ID
$userUrl = "https://graph.microsoft.com/v1.0/users/$userPrincipalName"
$userResponse = Invoke-RestMethod -Uri $userUrl -Headers $headers -Method GET
$userObjectId = $userResponse.id

# Update the user's mobile phone number
$updateUrl = "https://graph.microsoft.com/v1.0/users/$userObjectId"
$updateBody = @{
    mobilePhone = $mobilePhoneNumber
} | ConvertTo-Json
Invoke-RestMethod -Uri $updateUrl -Headers $headers -Method PATCH -Body $updateBody
# SIG # Begin signature block#Script Signature# SIG # End signature block






