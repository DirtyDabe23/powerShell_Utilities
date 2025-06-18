import-module Microsoft.Graph.Users.Actions

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


#Connect to Graph with the token.
Connect-MGGraph -AccessToken $token

#JSON Payload Construction
$params = @{
	message = @{
		subject = "Testing Email from API"
		body = @{
			contentType = "Text"
			content = "This is a test email from Microsoft Graph API to test how to send emails with formatting. Line Breaks with the standard give a banner alert. Trying Enter Hit enter FIVE times"
		}
		toRecipients = @(
			@{
				emailAddress = @{
					address = "tyler.bollinger@uniqueParentCompany.com"
				}
			}
		)
		ccRecipients = @(
			@{
				emailAddress = @{
					address = "kevin.williams@uniqueParentCompany.com"
				}
			}
		)
	}
	saveToSentItems = "true"
}

$userID = "3be04ec2-c2d1-4804-82ad-bf4c1afdaee8"

# A UPN can also be used as -UserId.
Send-MgUserMail -UserId "$userName@uniqueParentCompany.com" -BodyParameter $params
# SIG # Begin signature block#Script Signature# SIG # End signature block







