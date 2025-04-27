#The Tenant ID from App Registrations
$tenantId = $tenantIDString
# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$clientId = $appIDString
 
 
#The Client ID from certificates and secrets section
$clientSecret = $secret
 
 
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
$token


$uName = "test.mctesterson@uniqueParentCompany.com"
$uri = "https://graph.microsoft.com/v1.0/users/$uName"
 
$method = "GET"
 
# Run the Graph API query to retrieve users
$output = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop

#ConvertFrom-JSON -InputObject $output

$newID = ConvertFrom-JSON -InputObject $output


# Replace with the object ID or user principal name of the user you want to modify
$userId = $newID.ID

# Replace with the updated mobile phone number
$mobilePhone = "+17178188834"

# Construct the Graph API endpoint URL
$uri = "https://graph.microsoft.com/v1.0/users/$userId"

# Construct the request body
$body = @{
   mobilePhone = $mobilePhone
}| ConvertTo-Json

# Set the authorization header with the access token
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Send the PATCH request to update the user's mobile phone number
$response = Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body -Verbose


# SIG # Begin signature block#Script Signature# SIG # End signature block






