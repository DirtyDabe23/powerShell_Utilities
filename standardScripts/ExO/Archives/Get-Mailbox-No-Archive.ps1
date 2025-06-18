# Get mailboxes with ArchiveStatus of None
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.ArchiveStatus -eq "None"}

# Create an array to store mailbox details
$mailboxDetails = @()

# Iterate through each mailbox and retrieve required details
foreach ($mailbox in $mailboxes) {


    #Token and required information to connect to Jira's API
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
    #connect to graph
    Connect-MGGraph -AccessToken $token

    $displayName = $mailbox.DisplayName
    $userPrincipalName = $mailbox.UserPrincipalName
    $officeLocation = (Get-MGUser -userID $userPrincipalName).OfficeLocation

    # Create a custom object with the desired details
    $mailboxObject = [PSCustomObject]@{
        DisplayName = $displayName
        UserPrincipalName = $userPrincipalName
        OfficeLocation = $officeLocation
    }

    # Add the object to the array
    $mailboxDetails += $mailboxObject
    Disconnect-MgGraph
}

# Export mailbox details to a CSV file
$mailboxDetails | Export-Csv -Path "C:\tempMailboxDetails.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block





