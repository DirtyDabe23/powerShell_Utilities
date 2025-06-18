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
Connect-MGGraph -AccessToken $secureToken -NoWelcome

# Retrieve all MSOL users with "SPE_E5" license assigned
$users = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.assignedlicenses.SKUID -contains "06ebc4ee-1bb5-47dd-8120-11324bc54e06")} | Sort-Object -property "UserPrincipalName"

# Iterate through each user and get Office and MFA status
$userStatus = @()

foreach ($user in $users) {

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
            Connect-MGGraph -AccessToken $secureToken -NoWelcome

    $mfaStatus = $user.StrongAuthenticationRequirements.State
    if ([string]::IsNullOrEmpty($mfaStatus)) {
        $mfaStatus = "Not Configured"
    }


    $uName = $user.UserPrincipalName
    $lastlogon = (Get-MgAuditLogSignIn -filter "startswith(userPrincipalName,'$uName')" -Top 1).createddatetime

    $userStatus += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        OfficeStatus = $user.Office
        MFAStatus = $mfaStatus
        UserType = $user.Usertype
        LastLogon = $lastlogon
    }
    WRite-Host "Last user assessed: " $user.UserPrincipalName
    #Start-Sleep -seconds 5
    Disconnect-MgGraph

}

# Export the results to CSV
$userStatus |  Export-Csv -Path "C:\Temp\2024_02_05_MFAStatusByOfficeE5.csv" -NoTypeInformation

Write-Host "CSV export completed. File saved at C:\Temp\MFAStatusByOffice.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block






