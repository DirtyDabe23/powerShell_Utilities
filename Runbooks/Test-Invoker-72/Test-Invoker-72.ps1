Import-module Az.Accounts
Import-Module Az.KeyVault
Import-Module Microsoft.Graph.Users
#onPremConnection and Data Review
try {
    # Read from Azure Key Vault using managed identity
    connect-azaccount -subscription 'azSubsription' -Identity | out-null
    
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
try{
    #Connect to: Graph / Via: Secret
    #The Tenant ID from App Registrations
    $graphTenantId = "graphTenantID"

    # Construct the authentication URL
    $graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
    
    #The Client ID from App Registrations
    $graphAppClientId = "graphAppID"
    
    $graphRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "GraphAPIKey" -AsPlainText
    
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
Write-Output "Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop

$userObject = Get-MGBetaUser -userid 'david.drosdick@Domain.extension1' -property *
Write-Output "$($Env:Temp)"
$csv = $userObject | Export-CSV -path $env:Temp\UserObject.csv
Import-CSV -path $env:Temp\UserObject.csv


SignatureBlock

