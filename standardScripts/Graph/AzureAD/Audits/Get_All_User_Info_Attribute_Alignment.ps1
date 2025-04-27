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

$users = Get-MGBetaUser -All -ConsistencyLevel eventual
$cleanupUsers = $users | where-object {($_.Mail -like "*@anonSubsidiary-1.com")}
$userData = @()


# Loop through each user to retrieve their license information
foreach ($user in $cleanupUsers) 
{
    
    $businessPhone = $user.businessphones[0]
    Try{
    $userManagerID = Get-MGUserManager -userID $user.UserPrincipalName -erroraction stop
    $userManager = (Get-MGBetaUser -userID $userManagerID.ID).displayName
    }
    catch{
    $userManager = $null 
    }

    try{
    $userMailbox = Get-Mailbox -Identity $user.UserPrincipalName -erroraction stop
    $customAttr1 = $userMailbox.customattribute1
    $customAttr2 = $userMailbox.customattribute2

    }

    catch{
    $customAttr1 = $null
    $customAttr2 = $null 
    }

      $userData += [PSCustomObject]@{
        GivenName         = $user.GivenName
        Surname           = $user.Surname
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        Title             = $user.JobTitle
        Department        = $user.Department
        OfficeLocation    = $user.OfficeLocation
        CompanyName       = $user.CompanyName
        BusinessPhone     = $businessPhone
        Manager           = $userManager
        'Shop or Office'  = $customAttr1
        'First Responder' = $customAttr2 


        }
    
}

# Export the user data to a CSV file
$userData | Export-Csv -path C:\Temp\2024_01_17_anonSubsidiary-1.csv
# SIG # Begin signature block#Script Signature# SIG # End signature block








