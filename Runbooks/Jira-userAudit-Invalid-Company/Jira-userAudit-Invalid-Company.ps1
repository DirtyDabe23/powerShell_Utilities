$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
Import-module Az.Accounts
Import-Module Az.KeyVault
#Connect to ExchangeOnline and Azure with the Managed Identity
Connect-ExchangeOnline -ManagedIdentity -Organization uniqueParentCompany.onmicrosoft.com
Connect-AzAccount -subscription $subscriptionID -Identity

#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId      = $tenantIDString

# Construct the authentication URL
$graphURI           = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$graphAppClientId   = $appIDString

$graphRetrSecret    = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText

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
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "JiraAPI" -AsPlainText
#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}
#Retrieve the Company Name Values
$Fields = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field" -Headers $jiraHeader

$fieldName = "Company"

$foundField = $fields | Where-Object {($_.Name -eq $fieldName)}


If ($foundField -ne $null)
{
    $reviewingField = $fields | Where-Object {($_.Name -eq $fieldName)}

    $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $jiraHeader


    $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $jiraHeader

    $reviewedFieldValues = @()

    If ($reviewingFieldValues.Total -ge 100)
    {
        $uriTemplate = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

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
        $uriTemplate = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option"
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

$validCompanyNames = $reviewedFieldValues.value

#$validCompanyNames = "unique-Company-Name-0","unique-Company-Name-2","unique-Company-Name-5","unique-Company-Name-20","unique-Company-Name-18","unique-Company-Name-21","unique-Company-Name-13","unique-Company-Name-1","unique-Company-Name-19","unique-Company-Name-11","unique-Company-Name-15","unique-Company-Name-3","unique-Company-Name-8","unique-Company-Name-6","unique-Company-Name-10","unique-Company-Name-9","unique-Company-Name-7","unique-Company-Name-16","unique-Company-Name-17","unique-Company-Name-4" , "unique-Company-Name-12" , "unique-Company-Name-14"
$invalidCompanyNameUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated") -and ($_.CompanyName -notin $validCompanyNames)} | select-object -Property "OnPremisesSyncEnabled", "OnPremisesDistinguishedName" , "ID", "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "Manager", "BusinessPhones", "UsageLocation" | Sort-Object -Property DisplayName

$userObject = @();

If ($null -eq $invalidCompanyNameUsers)
{

$messageContent = @"
All users have a valid Company Name! Go Team!

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
ForEach ($invalidCompanyNameUser in $invalidCompanyNameUsers)
{
    try
    {
        $managerID = Get-MGBetaUserManager -userid $invalidCompanyNameUser.Id -ErrorAction Stop
        $manager = Get-MGBetaUser -userid $managerID.ID -ErrorAction Stop
        If ($manager.id -notin $invalidCompanyNameUsers.Id)
        {
            $ComplteamMembert = $True
        }
        Else 
        {
            $ComplteamMembert = $False
        }
        $userObject += [PSCustomObject]@{
            SynchingLocal               = $invalidCompanyNameUser.OnPremisesSyncEnabled
            ID                          = $invalidCompanyNameUser.ID
            DisplayName                 = $invalidCompanyNameUser.DisplayName
            UserPrincipalName           = $invalidCompanyNameUser.UserPrincipalName
            CompanyName                 = $invalidCompanyNameUser.CompanyName
            Country                     = $invalidCompanyNameUser.Country
            UsageLocation               = $invalidCompanyNameUser.UsageLocation
            OfficeLocation              = $invalidCompanyNameUser.OfficeLocation
            BusinessPhones              = $invalidCompanyNameUser.BusinessPhones[0]
            ManagerDisplayName          = $manager.DisplayName
            ManagerID                   = $manager.ID
            ManagerUserPrincipalName    = $manager.UserPrincipalName 
            ManagerCompanyName          = $manager.CompanyName
            ManagerOfficeLocation       = $manager.OfficeLocation
            ManagerComplteamMembert            = $ComplteamMembert
            }   
    
    }
    catch
    {
         
        $userObject += [PSCustomObject]@{
            SynchingLocal               = $invalidCompanyNameUser.OnPremisesSyncEnabled
            ID                          = $invalidCompanyNameUser.ID
            DisplayName                 = $invalidCompanyNameUser.DisplayName
            UserPrincipalName           = $invalidCompanyNameUser.UserPrincipalName
            CompanyName                 = $invalidCompanyNameUser.CompanyName
            Country                     = $invalidCompanyNameUser.Country
            UsageLocation               = $invalidCompanyNameUser.UsageLocation
            OfficeLocation              = $invalidCompanyNameUser.OfficeLocation
            BusinessPhones              = $invalidCompanyNameUser.BusinessPhones[0]
            ManagerDisplayName          = "No Manager"
            ManagerID                   = "No Manager"
            ManagerUserPrincipalName    = "No Manager"
            ManagerCompanyName          = "No Manager"
            ManagerOfficeLocation       = "No Manager"
            ManagerComplteamMembert            = "No Manager"
    }


    }    
}
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$filePath ="C:\Temp\"+ $Date+".InvalidCompanyUsers"+".csv"
$userObject | Export-CSV -Path $filePath
# Read the content of the CSV file
$fileContent = Get-Content -Path $filePath -Raw

# Convert the file content to Base64
$attachmentContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fileContent))

ForEach ($validCompanyName in $validCompanyNames)
{
    $validcompanyNames = $validcompanyNames -ne $validCompanyName
    $validCompanyNames += $validcompanyName+"`n"
}
$messageContent = @"
Please review the attachment for a list of Users with incorrect Company Names in Microsoft Graph. 
If they are not synching, they are handled in Entra AD. 
If they are synching, they must be resolved on their Local Domain Controller. 
Valid Company Names are:`n $validCompanyNames

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

































