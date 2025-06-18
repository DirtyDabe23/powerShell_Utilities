#connect to Exchange Online
$exoCertThumb = "5A72B9E49079A6999A440A5438D2CBBABC482DDA"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"

Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG -ShowBanner:$false

$apiVersion = "2020-06-01"
$resource = "https://vault.azure.net"
$endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$resource,$apiVersion
$secretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($wwwAuthHeader -match "Basic realm=.+")
    {
        $secretFile = ($wwwAuthHeader -split "Basic realm=")[1]
    }
}
Write-Host "Secret file path: " $secretFile`n
$secret = Get-Content -Raw $secretFile
$response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'; Authorization="Basic $secret"} -UseBasicParsing
if ($response)
{
    $token = (ConvertFrom-Json -InputObject $response.Content).access_token
    Write-Host "Access token: " $token
}

$retrSecret = (Invoke-RestMethod -Uri 'https://PREFIX-vault.vault.azure.net/secrets/$graphSecretName?api-version=2016-10-01' -Method GET -Headers @{Authorization="Bearer $token"}).value

#secureGraph
#The Tenant ID from App Registrations
$tenantId = $tenantIDString

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$clientId = $appIDString


# Construct the body to be used in Invoke-WebRequest
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $retrSecret
    grant_type    = "client_credentials"
}

# Get Authentication Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Extract the Access Token
$secureToken = ($tokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
#connect to graph
Connect-MGGraph -AccessToken $secureToken -NoWelcome

$validOfficeLocations = "unique-Office-Location-0" , "unique-Office-Location-1", "unique-Office-Location-2" , "unique-Office-Location-3" , "unique-Company-Name-20","unique-Company-Name-7","unique-Office-Location-6","unique-Office-Location-7","uniqueParentCompany (Beijing) Refrigeration Equipment Co., Ltd.","unique-Office-Location-9","unique-Company-Name-3","unique-Company-Name-18","unique-Company-Name-5","unique-Company-Name-21","unique-Office-Location-27","unique-Company-Name-6","unique-Company-Name-4","unique-Office-Location-16","unique-Company-Name-2","unique-Office-Location-18","unique-Company-Name-10","unique-Company-Name-11","unique-Office-Location-21","unique-Company-Name-8","unique-Company-Name-17","unique-Company-Name-16" , "unique-Company-Name-14" , "unique-Company-Name-12"
$invalidOfficeLocationUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated") -and ($_.OfficeLocation -notin $validofficeLocations)} | select-object -Property "OnPremisesSyncEnabled", "ID", "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "Manager", "BusinessPhones", "UsageLocation" | Sort-Object -Property DisplayName

$userObject = @();

If ($null -eq $invalidOfficeLocationUsers)
{

$messageContent = @"
All users have a valid Company Name! Go Team!"

"@
$messageContent

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Users - Invalid Company Names"
        body = @{
            contentType = "Text"
            content = "$messageContent"
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "GIT-Helpdesk@uniqueParentCompany.com"
                }
            }
        )
        ccRecipients = @(
			@{
				emailAddress = @{
					address = "$userName@uniqueParentCompany.com"
				}
			}
		)
    }
    saveToSentItems = "true"
}
$userID = "3be04ec2-c2d1-4804-82ad-bf4c1afdaee8"

#Write-Host "I would have sent an email here but we're just testing"
# A UPN can also be used as -UserId.
Send-MgUserMail -UserId $userID -BodyParameter $params
exit 0
}
else
{ 

ForEach ($invalidOfficeLocationUser in $invalidOfficeLocationUsers)
{
    try
    {
        $managerID = Get-MGBetaUserManager -userid $invalidOfficeLocationUser.Id -ErrorAction Stop
        $manager = Get-MGBetaUser -userid $managerID.ID -ErrorAction Stop
        If ($manager.id -notin $invalidofficelocationusers.id)
        {
            $ComplteamMembert = $True
        }
        Else 
        {
            $ComplteamMembert = $False
        }
        $userObject += [PSCustomObject]@{
            SynchingLocal               = $invalidOfficeLocationUser.OnPremisesSyncEnabled
            ID                          = $invalidOfficeLocationUser.ID
            DisplayName                 = $invalidOfficeLocationUser.DisplayName
            UserPrincipalName           = $invalidOfficeLocationUser.UserPrincipalName
            CompanyName                 = $invalidOfficeLocationUser.CompanyName
            Country                     = $invalidOfficeLocationUser.Country
            UsageLocation               = $invalidOfficeLocationUser.UsageLocation
            OfficeLocation              = $invalidOfficeLocationUser.OfficeLocation
            BusinessPhones              = $invalidOfficeLocationUser.BusinessPhones[0]
            ManagerDisplayName          = $manager.DisplayName
            ManagerID                   = $manager.ID
            ManagerUserPrincipalName    = $manager.UserPrincipalName 
            ManagerOfficeLocation       = $manager.OfficeLocation
            ManagerComplteamMembert            = $ComplteamMembert
            }   
    
    }
    catch
    {
         
        $userObject += [PSCustomObject]@{
            SynchingLocal               = $invalidOfficeLocationUser.OnPremisesSyncEnabled
            ID                          = $invalidOfficeLocationUser.ID
            DisplayName                 = $invalidOfficeLocationUser.DisplayName
            UserPrincipalName           = $invalidOfficeLocationUser.UserPrincipalName
            CompanyName                 = $invalidOfficeLocationUser.CompanyName
            Country                     = $invalidOfficeLocationUser.Country
            UsageLocation               = $invalidOfficeLocationUser.UsageLocation
            OfficeLocation              = $invalidOfficeLocationUser.OfficeLocation
            BusinessPhones              = $invalidOfficeLocationUser.BusinessPhones[0]
            ManagerDisplayName          = "No Manager"
            ManagerID                   = "No Manager"
            ManagerUserPrincipalName    = "No Manager"
            ManagerOfficeLocation       = "No Manager"
            ManagerComplteamMembert            = "No Manager"
    }


    }    
}
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+".InvalidOfficeLocationUsers"+".csv"
$userObject | Export-CSV $filePath

$userObject | Export-CSV -Path $filePath
# Read the content of the CSV file
$fileContent = Get-Content -Path $filePath -Raw

# Convert the file content to Base64
$attachmentContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fileContent))

ForEach ($validOfficeLocation in $validOfficeLocations)
{
    $validOfficeLocations = $validOfficeLocations -ne $validOfficeLocation
    $validOfficeLocations += $validOfficeLocation+"`n"
}
$messageContent = @"
Please review the attachment for a list of Users with incorrect Office Names in Microsoft Graph. 
If they are not synching, they are handled in Entra AD. 
If they are synching, they must be resolved on their Local Domain Controller. 
Valid Office Names are: $validOfficeLocations

"@
$messageContent

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Users - Invalid Office Names"
        body = @{
            contentType = "Text"
            content = "$messageContent"
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "GIT-Helpdesk@uniqueParentCompany.com"
                }
            }
        )
        ccRecipients = @(
			@{
				emailAddress = @{
					address = "$userName@uniqueParentCompany.com"
				}
			}
		)
        attachments = @(
            @{
                "@odata.type" = "#microsoft.graph.fileAttachment"
                name = (Split-Path -Path $filePath -Leaf)
                contentBytes = $attachmentContent
            }
        )
    }
    saveToSentItems = "true"
}
$userID = "3be04ec2-c2d1-4804-82ad-bf4c1afdaee8"

#Write-Host "I would have sent an email here but we're just testing"
# A UPN can also be used as -UserId.
Send-MgUserMail -UserId $userID -BodyParameter $params

}
# SIG # Begin signature block#Script Signature# SIG # End signature block






































