$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
Import-module Az.Accounts
Import-Module Az.KeyVault
#Connect to ExchangeOnline and Azure with the Managed Identity
Connect-ExchangeOnline -ManagedIdentity -Organization parentCompany.onmicrosoft.com
Connect-AzAccount -subscription 'azSubsription' -Identity

#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId      = "graphTenantID"

# Construct the authentication URL
$graphURI           = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$graphAppClientId   = "graphAppID"

$graphRetrSecret    = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "GraphAPIKey" -AsPlainText

# Construct the body to be used in Invoke-WebRequest
$graphAuthBody      = @{
    client_id       = $graphAppClientId
    scope           = "https://graph.microsoft.com/.default"
    client_secret   =  $graphRetrSecret
    grant_type      = "client_credentials"
}

# Get Authentication Token
$graphTokenRequest  = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken   = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
$now                = Get-Date -Format "HH:mm"
Write-Output "[$now] | Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop


#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText
#Jira
$jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}
#Retrieve the Company Name Values
$Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $jiraHeader

$fieldName = "Office Location and Department"

$foundField = $fields | Where-Object {($_.Name -eq $fieldName)}


If ($foundField -ne $null)
{
    $reviewingField = $fields | Where-Object {($_.Name -eq $fieldName)}

    $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $jiraHeader


    $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $jiraHeader

    $reviewedFieldValues = @()

    If ($reviewingFieldValues.Total -ge 100)
    {
        $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

        for ($count = 0; $count -lt $reviewingFieldValues.Total; $count += 100) 
        {
            $uri = $uriTemplate -f $count
            $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $jiraHeader
            ForEach ($fieldValue in $fieldValues.values)
            {
                $reviewedFieldValues += [PSCustomObject]@{
                    FieldName   = $fieldName
                    ID          = $fieldValue.ID
                    Value       = $fieldValue.Value
                    OptionID    = $fieldValue.optionID
                    Disabled    = $fieldValue.Disabled
                }
            }
        }

    }
    else 
    {
        $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option"
        $fieldValues = Invoke-RestMethod -Method Get -Uri $uriTemplate -Headers $jiraHeader
        ForEach ($fieldValue in $fieldValues.values)
            {
                $reviewedFieldValues+= [PSCustomObject]@{
                    FieldName   = $fieldName
                    ID          = $fieldValue.ID
                    Value       = $fieldValue.Value
                    OptionID    = $fieldValue.optionID
                    Disabled    = $fieldValue.Disabled
                }
            }
    }    
}
else
{
    Write-Output "Field Name not found"
}

$validOfficeLocations = ($reviewedFieldValues | Where-Object {($_.OptionID -eq $null)}).value
#$validOfficeLocations = "parentCompany East" , "Location2", "parentCompany Midwest" , "parentCompany Iowa" , "subsidiaryCompany1","parentCompany Europe BVBA","parentCompany (Milano) Europe, S.r.l.","parentCompany (Sondrio) Europe, S.r.l.","parentCompany (Beijing) Refrigeration Equipment Co., Ltd.","parentCompany (Shanghai) Refrigeration Equipment Co., Ltd.","parentCompany Australia (Pty.) Ltd.","subsidiaryCompany2, Inc.","parentCompany Dry Cooling, Inc.","subsidiaryCompany4","parentCompany Newton","parentCompany Europe A/S","parentCompany Brasil","subsidiaryCompany3","parentCompany Alcoil, Inc.","parentCompany Air Cooling Systems (Jiaxing) Co., Ltd.","parentCompany Iowa Sales & Engineering","parentCompany LMP","parentCompany Select Tech","parentCompany Europe GmbH","subsidiaryCompany2 Asia Pacific Sdn Bhd","subsidiaryCompany2 (Shanghai) Cooling Tower Co., Ltd." , "parentCompany S.A. (Pty.) Ltd." , "parentCompany Middle East DMCC"
$invalidOfficeLocationUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated") -and ($_.OfficeLocation -notin $validofficeLocations)} | select-object -Property "OnPremisesSyncEnabled", "ID", "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "Manager", "BusinessPhones", "UsageLocation" | Sort-Object -Property DisplayName

$userObject = @();

If ($null -eq $invalidOfficeLocationUsers)
{

$messageContent = @"
All users have a valid Office Name! Go Team!

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
                    address = "GIT-Helpdesk@Domain.extension1"
                }
            }
        )
        ccRecipients = @(
			@{
				emailAddress = @{
					address = "david.drosdick@Domain.extension1"
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
            $Compliant = $True
        }
        Else 
        {
            $Compliant = $False
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
            ManagerCompliant            = $Compliant
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
            ManagerCompliant            = "No Manager"
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
                    address = "GIT-Helpdesk@Domain.extension1"
                }
            }
        )
        ccRecipients = @(
			@{
				emailAddress = @{
					address = "david.drosdick@Domain.extension1"
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
SignatureBlock

