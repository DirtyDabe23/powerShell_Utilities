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

#Get a Token Specifically for making CRUD Requests
$tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
# Extract the Access Token
$baseToken = ($tokenRequest.content | convertfrom-json).access_token
$graphAPIHeader = @{
    "Authorization" = "Bearer $baseToken"
    "Content-Type" = "application/JSON"
    grant_type    = "client_credentials"
}

$topLevelSite = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/root" -Method Get
$response = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/root/sites" -Method Get -ResponseHeadersVariable $header
$subSites = @()
$subSites += $response.value 
while($response.'@odata.nextLink'){
    $response = Invoke-GraphRequest -Uri $response.'@odata.nextLink'
    $subSites += $response.value
}
ForEach ($subSite in $subSites){
    $listResponse  = Invoke-GraphRequest -Method Get -Uri "/v1.0/sites/$($subsite.ID)/lists"
    $lists = $listResponse.Value | ConvertTo-Json -Depth 10 | convertFrom-JSON -Depth 10    
    
    ForEach ($list in $lists){
        $

    }

}

# SIG # Begin signature block#Script Signature# SIG # End signature block







