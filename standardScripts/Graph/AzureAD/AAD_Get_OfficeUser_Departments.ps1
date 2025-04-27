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


$Users = Get-Mailbox -resultsize unlimited | Where-Object {($_.CustomAttribute1 -eq "Office") -and ($_.Office -eq "unique-Office-Location-0")}

# Initialize an array to store user data
$userData = @()


# Loop through each user to retrieve their license information
foreach ($user in $Users) 
{
    $mgUser = Get-MgBetaUser -UserId $user.primarySMTPAddress
      $userData += [PSCustomObject]@{
        DisplayName       = $mgUser.DisplayName
        UserPrincipalName = $mgUser.UserPrincipalName
        Department        = $mgUser.Department
        }
    
}

# Export the user data to a CSV file
$userData | Export-Csv -Path "C:\Temp\OfficeUsers.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block







