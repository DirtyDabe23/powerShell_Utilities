#The Tenant ID from App Registrations
$tenantId = $tenantIDString

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$clientId = $appIDString
 

 
#The Client ID from certificates and secrets section
$clientSecret = "$retrGraphSecret"
 
 
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


#Connect to Graph with the token.
Connect-MGGraph -AccessToken $token


# The path of the file attachment
$attachmentPath = "C:\Temp\New Associate GIT Tips.docx"

# Convert the file to Base64
$attachmentContent = [System.Convert]::ToBase64String((Get-Content -Path $attachmentPath -Encoding Byte))

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Testing Email from API"
        body = @{
            contentType = "Text"
            content = "This is a test email, testing sending attachments"
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "tyler.bollinger@uniqueParentCompany.com"
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

# A UPN can also be used as -UserId.
Send-MgUserMail -UserId "$userName@uniqueParentCompany.com" -BodyParameter $params

# SIG # Begin signature block#Script Signature# SIG # End signature block







