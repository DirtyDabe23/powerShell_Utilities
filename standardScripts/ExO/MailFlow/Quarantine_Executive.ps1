    $StartTime = Get-Date 
    #THIS SCRIPT MUST BE RUN IN POWERSHELL 5.1, IT DOES NOT WORK IN POWERSHELL 7 FOR WHATEVER REASON

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
    Connect-MGGraph -AccessToken $secureToken -NoWelcome

    #connect to Exchange Online
    $exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
    $exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
    $exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
    Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG -showbanner:$false



    $users = Get-MGBetaUser -all -consistencylevel eventual | Where-object {($_.Department -eq "Executive")}
    $domains = Import-CSV -Path C:\Temp\RepDomains.csv

    $max = $users.count 
    $counter = 1 

    ForEach ($user in $users)
    {
    Write-Host "User #$counter out of $max"

        Connect-MGGraph -AccessToken $secureToken -NoWelcome
		
        Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG -showbanner:$false


        $trustedQuarantine = @();
        $userUPN = $user.userprincipalname 
        $userQuarantines = Get-QuarantineMessage -RecipientAddress $userUPN -ReleaseStatus NotReleased
    
        ForEach ($userQuarantine in $userQuarantines)
        {
        $senderAddr = $userQuarantine.senderaddress.split('@')[1]

        If ($senderAddr -in $domains.domain )
                                        {
        $trustedQuarantine +=[PSCustomObject]@{ 
        Received = $userQuarantine.receivedTime
        Sender = $userQuarantine.SenderAddress
        Subject = $userQuarantine.Subject
        }


        
        }
        Else
                    {
        $null
        }
 
        }

    if($trustedQuarantine.count -eq 0)
        {
Write-Host "No Email to send"
    }

    Else 
                                                                                                                                                                                {
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$attachmentPath ="C:\Temp\"+ $Date+"."+$userUPN.split('@')[0]+".csv"

$trustedQuarantine | export-csv -path $attachmentPath
$emailBody = $trustedQuarantine | Out-String
# The path of the file attachment

# Convert the file to Base64
$attachmentContent = [System.Convert]::ToBase64String((Get-Content -Path $attachmentPath -Encoding Byte))

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Quarantined Emails Matching Trusted Senders"
        body = @{
            contentType = "Text"
            content = "Please review the attachment for a list of quarantined emails from trusted senders. Emails can have their releases requested at https://security.microsoft.com/quarantine $emailBody"
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "$userUPN"
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

Write-Host "I would have sent an email here but we're just testing"
# A UPN can also be used as -UserId.
#Send-MgUserMail -UserId $userID -BodyParameter $params
    }
    #Disconnect-MgGraph
    #Disconnect-ExchangeOnline -confirm:$false    
    $counter += 1        
    }
    $endTime = Get-Date 

# SIG # Begin signature block#Script Signature# SIG # End signature block







