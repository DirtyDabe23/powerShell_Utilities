#secureGraph
#The Tenant ID from App Registrations
$tenantId = $tenantIDString

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$clientId = $appIDString
 

 
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
$secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
#connect to graph
Connect-MGGraph -AccessToken $secureToken

#connect to Exchange Online
$exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG


# Prompt for the top-level manager's User Principal Name
$topLevelManagerUPN = Read-Host "Enter the User Principal Name of the top-level manager"

# Get the top-level manager's ID
$topLevelManagerId = (Get-MgUser -Filter "userPrincipalName eq '$topLevelManagerUPN'" -Select Id).Id

# Initialize an array to store the results
$results = @()

# Loop to recursively get direct reports
$managerIds = @($topLevelManagerId)

while ($managerIds.Count -gt 0) {
    $managerId = $managerIds[0]
    $managerIds = $managerIds -ne $managerId

    $directReports = Get-MgUserDirectReport -UserId $managerId

    foreach ($report in $directReports) {
        $user = Get-MgUser -UserId $report.id -Select Id,UserPrincipalName,JobTitle,DisplayName
        $manager = Get-MgUser -UserId $managerId -Select DisplayName

        $results += [PSCustomObject]@{
            'Manager'                 = $manager.DisplayName
            'ReportDisplayName'       = $user.DisplayName
            'ReportJobTitle'          = $user.JobTitle
            'ReportUserPrincipalName' = $user.UserPrincipalName
            'ReportUserID'            = $user.Id
            
        }

        # Add the current user's ID for further processing
        $managerIds += $user.Id
    }
}

# Display the results
$results | Format-Table -AutoSize
# SIG # Begin signature block#Script Signature# SIG # End signature block







