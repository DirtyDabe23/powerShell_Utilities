#################################################################################Actual Process Starts Here###############################################################
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
$secret = Get-Content -Raw $secretFile
$response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'; Authorization="Basic $secret"} -UseBasicParsing
if ($response)
{
    $token = (ConvertFrom-Json -InputObject $response.Content).access_token
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
#connect to Graph
Connect-MGGraph -AccessToken $secureToken -NoWelcome


#FileShare to export the CSV 
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "offlinefor$($daysNoLogon)days.csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$fileName
[int]$daysNoLogon = 90
$command = {
Get-ADCOmputer -filter * -Properties * | Where-Object {($_.LastLogonDate -le (Get-Date).AddDays(-$Using:daysNoLogon)) -and ($_.OperatingSystem -notlike "*Server*") -and ($_.OperatingSystem -ne $null)} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "LastLogonDate"
}

$offline90DaysComputers = Invoke-Command -ComputerName PREFIX-VS-DC01 -ScriptBlock $command

$offline90DaysComputers | Export-CSV -Path $exportPath

$fileContent = Get-Content -Path $exportPath -Raw

# Convert the file content to Base64
$attachmentContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fileContent))


$messageContent = @"
Please review the attachment for a list of unique-Office-Location-0 Domain Joined Computers that have not been seen in over 90 days.
For those devices which are known to have been decommed, please follow the standard Device Removal Process.
"@
$messageContent

# JSON Payload Construction
$params = @{
    message = @{
        subject = "unique-Office-Location-0: Devices Offline for 90+ Days"
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
                name = (Split-Path -Path $exportPath -Leaf)
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










