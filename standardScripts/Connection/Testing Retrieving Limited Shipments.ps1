# Define URI for OAuth2 Authentication
$connectionAuthURI = "https://api.webqa.moredirect.com/service/rest/auth/oauth2"

# Define parameters for the authentication request
$connectionAuthParams = @{
    "grant_type" = "password"
    "username"   = "GIT-CYOPS-Technical@uniqueParentCompany.com"
    "password"   = $connectionRetrSecret
}

# Get Authentication Token
$connectionResponse = Invoke-RestMethod -Uri $connectionAuthURI -Method Post -Body $connectionAuthParams -ContentType "application/x-www-form-urlencoded"
$connectionToken = $connectionResponse.access_token

# Create headers using the Bearer token for authorization
$connectionHeader = @{
    "Authorization" = "Bearer $connectionToken"
    "Content-Type"  = "application/json"
    "Accept"        = "application/json"
}

# Base URI for shipments
$shipmentsURI = "https://api.webqa.moredirect.com/service/rest/listing/shipments"

# Create JSON body with OrderID filter
$jsonBody = @{
    "OrderID" = 62897306  # Use the correct JSON structure as required by the API
} | ConvertTo-Json

# Perform POST request to the shipments endpoint with JSON body
$response = Invoke-RestMethod -Uri $shipmentsURI -Headers $connectionHeader -Method Post -Body $jsonBody

# Output the response to see the filtered shipments
Write-Output "Filtered Shipments: $response"
# SIG # Begin signature block#Script Signature# SIG # End signature block




