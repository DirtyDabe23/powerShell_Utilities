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
$secureToken = ($tokenRequest.content | convertfrom-json).access_token

# Create headers with the authorization token
$headers = @{
    "Authorization" = "Bearer $secureToken"
    "ConsistencyLevel" = "eventual"
}

$allPages = @()

$aadUsers = Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,signInActivity,companyName,onPremisesSyncEnabled,onPremisesExtensionAttributes,assignedLicenses&$filter=companyName ne null and userType eq ''Member'' and NOT(companyName eq ''Not Affiliated'') and accountEnabled eq true and NOT(department eq ''Executive'')&$count=true' -Headers $Headers -Method Get -ContentType "application/json"

$allPages += $aadUsers.value

if ($aadUsers.'@odata.nextLink') {
    do {
        $aadUsers = Invoke-RestMethod -Uri $aadUsers.'@odata.nextLink' -Headers $Headers -Method Get -ContentType "application/json"
        $allPages += $aadUsers.value
    } until (!$aadUsers.'@odata.nextLink')
}

$users = @()

foreach ($aadUser in $allPages) {
    $userObject = [PSCustomObject]@{
        'UserPrincipalName'              = $aadUser.userPrincipalName
        'DisplayName'                    = $aadUser.displayName
        'ID'                             = $aadUser.id
        'LastSignInDateTime'             = $aadUser.signInActivity.lastSignInDateTime 
        'LastSignInRequestID'            = $aadUser.signInActivity.lastSignInRequestId
        'LastNonInteractiveSignInDateTime'    = $aadUser.signInActivity.lastNonInteractiveSignInDateTime
        'LastNonInteractiveSignInRequestID'  = $aadUser.signInActivity.lastNonInteractiveSignInRequestId
        'OnPremSync'                      = $aaduser.onPremisesSyncEnabled
        'onPremisesExtensionAttributes' = $aaduser.onPremisesExtensionAttributes
    }
    $users += $userObject
}

$sixtyDaysAgo = (Get-Date).adddays(-60)

$LastSignInOver60DaysUsers = @()
#the following returns only users who have been inactive for over 60 days that do not have their extension attribute set.
$LastSignInOver60DaysUsers = $users | Where-Object {(($_.LastSignInDateTime -ge $sixtyDaysAgo) -and ($_.LastNonInteractiveSignInDateTime -ge $sixtyDaysAgo))  -and ($_.onPremisesExtensionAttributes.extensionAttribute15 -eq "Y")} | Sort-Object -property DisplayName

$aadUsers = $null
$users = $null
$allPages = $null


$synchingInactive = @()
$Enabled = @()

#disabling the users comes here
ForEach ($user in $LastSignInOver60DaysUsers)
{

#connect to Exchange Online
$exoCertThumb = "FE63624C5EE7EF5F9CC0ABEFB0EA3CC9390DC904"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"

Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG -showbanner:$false
 
# Get Authentication Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
 
# Extract the Access Token
$secureToken = ($tokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
#connect to graph
Connect-MGGraph -AccessToken $secureToken -NoWelcome


    Write-Host "Removing License For: $($user.userprincipalname)"
    $licenseInfo = Get-MGUserLicenseDetail -UserId $user.UserPrincipalName
    ForEach ($sku in $licenseInfo.skuID)
    {
    #Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses @{} -RemoveLicenses @($sku)
    }
    
    #Extension attributes can only be set on mailboxes, if a user does not have a license they are not part of this.
    If ($licenseInfo -ne $null)
    {
        Switch ($user.OnPremSync)
        {
            $true{"Unable to disable $($user.userprincipalname), this must be done on their local domain controller"
            $synchingInactive += $user}
            $null{"Disabling the user: $($user.userprincipalname)"
            #Update-MgUser -userid $user.UserPrincipalName -accountenabled:$false
            Set-Mailbox -identity $user.UserPrincipalName -customattribute15 $null
            $Enabled += $user}

        }
    }


}
#For users that ARE synching from Local AD and will need to be addressed directly.
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$attachmentPath ="C:\Temp\"+ $Date+".synchingInactiveUsers"+".csv"

$synchingInactive | export-csv -path $attachmentPath


# Read the content of the CSV file
$fileContent = Get-Content -Path $attachmentPath -Raw

# Convert the file content to Base64
$attachmentContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fileContent))

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Users - 60 days of no login, synching from Local AD, need disabled manually."
        body = @{
            contentType = "Text"
            content = "Please review the attachment for a list of Users with 60 days of no login. These users are synching from a Local AD and will need their accounts disabled manually."
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
                name = (Split-Path -Path $attachmentPath -Leaf)
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

#For users that are NOT synching from Local AD and have went through this process.
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$attachmentPath ="C:\Temp\"+ $Date+".newlyActiveUsers"+".csv"

$Enabled | export-csv -path $attachmentPath
# The path of the file attachment

# Read the content of the CSV file
$fileContent = Get-Content -Path $attachmentPath -Raw

# Convert the file content to Base64
$attachmentContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fileContent))

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Users - Logged in after inactivity."
        body = @{
            contentType = "Text"
            content = "Please review the attachment for a list of Users previously inactive who have logged in within 60 days. These users have had their extension attribute 15 updated to null."
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
                name = (Split-Path -Path $attachmentPath -Leaf)
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
# SIG # Begin signature block#Script Signature# SIG # End signature block









