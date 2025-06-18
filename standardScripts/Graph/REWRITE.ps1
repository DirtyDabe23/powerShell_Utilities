#Parameters
$tenantId = $tenantIDString
$clientId = $appIDString
$clientSecret = $secret
$authURL = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$uName = "test.mctesterson@uniqueParentCompany.com"
$mobilePhone = "7178188834"
 
 
# Construct the body to be used in Invoke-WebRequest
$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
}
 
# Get Authentication Token
$tokenRequest = Invoke-RestMethod -Uri $authURL -Method POST -Body $body
# Extract the Access Token
$accessToken = $tokenRequest.access_token


#Set the Header
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

#Get the User's ObjectID
$userUrl = "https://graph.microsoft.com/v1.0/users/$uName"
$userResponse = Invoke-RestMethod -URI $userUrl -Headers $headers -Method GET
$uObjID = $userResponse.id


# Construct the Graph API endpoint URL
$uri2 = "https://graph.microsoft.com/v1.0/users/$uObjID"

# Construct the request body
$body = @{
   mobilePhone = $mobilePhone
}| ConvertTo-Json


# Send the PATCH request to update the user's mobile phone number
Invoke-RestMethod -Uri $uri2 -Headers $headers -Method PATCH -Body $body


# SIG # Begin signature block#Script Signature# SIG # End signature block






