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

$2023Users = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.CreatedDateTime -like "*2023*")}

# Initialize an array to store user data
$userData = @()

$highestLicenseCount = 0

# Loop through each user to retrieve their license information
foreach ($user in $2023Users) {
    $licensesInfo = $null
    $licensesInfo = Get-MgUserLicenseDetail -UserId $user.Id
    If($licensesInfo.count -eq 1)
    {
      $userData += [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        CompanyName       = $user.CompanyName
        OfficeLocation    = $user.OfficeLocation
        Department        = $user.Department
        Created           = $user.createddatetime
        LicenseInfo1      = $licensesInfo.SkuPartNumber
        LicenseInfo2      = $null
        LicenseInfo3      = $null
        LicenseInfo4      = $null
        LicenseInfo5      = $null
        LicenseInfo6      = $null
        LicenseInfo7      = $null
        LicenseInfo8      = $null
        LicenseInfo9      = $null
        LicenseInfo10     = $null

        }
    }
    Else
    {

    try 
    {
    $licenseInfo1 = $licensesInfo[0].SKuPartNumber
    }

    catch
    {
    $licenseInfo1 = $null
    }

    try 
    {
    $licenseInfo2 = $licensesInfo[1].SKuPartNumber
    }

    catch
    {
    $licenseInfo2 = $null
    }


    try 
    {
    $licenseInfo3 = $licensesInfo[2].SKuPartNumber
    }

    catch
    {
    $licenseInfo3 = $null
    }

    try 
    {
    $licenseInfo4 = $licensesInfo[3].SKuPartNumber 
    }

    catch
    {
    $licenseInfo4 = $null
    }

    try 
    {
    $licenseInfo5 = $licensesInfo[4].SKuPartNumber 
    }

    catch
    {
    $licenseInfo5 = $null
    }


    try 
    {
    $licenseInfo6 = $licensesInfo[5].SKuPartNumber 
    }

    catch
    {
    $licenseInfo6 = $null
    }
    
            try 
    {
    $licenseInfo7 = $licensesInfo[6].SKuPartNumber 
    }

    catch
    {
    $licenseInfo7 = $null
    }

    try 
    {
    $licenseInfo8 = $licensesInfo[7].SKuPartNumber 
    }

    catch
    {
    $licenseInfo8 = $null
    }


    try 
    {
    $licenseInfo9 = $licensesInfo[8].SKuPartNumber 
    }

    catch
    {
    $licenseInfo9 = $null
    }
    

    try 
    {
    $licenseInfo10 = $licensesInfo[9].SKuPartNumber 
    }

    catch
    {
    $licenseInfo10 = $null
    }


    $userData += [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        CompanyName       = $user.CompanyName
        OfficeLocation    = $user.OfficeLocation
        Department        = $user.Department
        Created           = $user.createddatetime
        LicenseInfo1      = $licenseInfo1
        LicenseInfo2      = $licenseInfo2
        LicenseInfo3      = $licenseInfo3
        LicenseInfo4      = $licenseInfo4
        LicenseInfo5      = $licenseInfo5
        LicenseInfo6      = $licenseInfo6
        LicenseInfo7      = $licenseInfo7
        LicenseInfo8      = $licenseInfo8
        LicenseInfo9      = $licenseInfo9
        LicenseInfo10     = $licenseInfo10

        }

    }
}

# Export the user data to a CSV file
$userData | Export-Csv -Path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\2023_Scripts\Azure_AD\Audits\Users_Created_By_Date_Licenses\Created_2023_UserLicenseInfo.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block









