#Parameters
$tenantId = $tenantIDString
$clientId = $appIDString
$clientSecret = $secret
$authURL = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"


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

$uri = "https://graph.microsoft.com/v1.0/users"

$csvPath = Read-Host  "Enter the full path to the CSV Here"
$users = Import-Csv $csvPath

foreach ($user in $users) {


$userBody = @{
    accountEnabled = $true
    city = "Seattle"
    country = "United States"
    department = "Sales & Marketing"
    displayName = "Melissa Darrow"
    givenName = "Melissa"
    jobTitle =  "Marketing Director"
    mailNickname = "MelissaD"
    passwordProfile = @{
        password = "uniqueParentCompany123!"
        forceChangePasswordNextSignIn = $true
    }
    officeLocation = "131/1105"
    postalCode = "98052"
    preferredLanguage = "en-US"
    state = "WA"
    streetAddress = "9256 Towne Center Dr., Suite 400"
    surname = "Darrow"
    mobilePhone = "+1 206 555 0110"
    usageLocation = "US"
    userPrincipalName = "MelissaD@{domain}"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $userBody -Verbose
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






