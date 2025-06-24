#################################################################################Script Configuration################################################################################
Clear-Host 
$process = "New User Automation"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

#This WMI Query gets a ton of rich information about the endpoint
$computerInfo = Get-WMIObject -class Win32_ComputerSystem | select-object -Property *

#File Creation Objects
$shareLoc = "\\parentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "$($process).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$fileName

#Error Logging
$errorLogFull = @()
$errorLog = @()

#Log Timing For the Full Process Start
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] [$process] Starting"

#################################################################################API Connections#################################################################################

#Connection to the Jira API after getting the token from the Key Vault
$jiraVaultName = 'jiraAPIKey'
$jiraAPIKeyVersion = "2020-06-01"
$jiraResource = "https://vault.azure.net"
$jiraEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$jiraResource,$jiraAPIKeyVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $jiraWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($jiraWWWAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($jiraWWWAuthHeader -split "Basic realm=")[1]
    }
}
$jiraSecret = Get-Content -Raw $jiraSecretFile
$jiraResponse = Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($jiraResponse)
{
    $jiraToken = (ConvertFrom-Json -InputObject $jiraResponse.Content).access_token
}

$jiraRetrSecret = (Invoke-RestMethod -Uri "https://KeyVaultName.vault.azure.net/secrets/$($jiraVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}




#How to get all new user onboarding requests, this returns only issues with the summary of 'Onboard Request'
$pendingRequests = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/search?jql=project%20%3D%20GHD%20AND%20summary%20~%20%22Onboard%20Request%22%20AND%20status%20%3D%20%22Ready%20For%20Automation%22" -Headers $headers

#Looping through all onboarding requests.
foreach ($ticket in $pendingRequests.issues)
    {
        
        #If the ticket status is not 'Ready for Automation' it is not included in this process.
        if ($ticket.fields.status.name -ne "Ready for Automation")
        {
            $null
        }
        Else
        {
            #################################################################################Actual Process Starts Here###############################################################
            #connect to Exchange Online
            $exoCertThumb = "5A72B9E49079A6999A440A5438D2CBBABC482DDA"
            $exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
            $exoORG = "parentCompanyinc.onmicrosoft.com"
		
            Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

           #Authentication via KeyVault To Graph:
            $graphVaultName = 'GraphAPIKey'
            $graphVaultAPIVersion = "2020-06-01"
            $graphVaultResource = "https://vault.azure.net"
            $graphVaultEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$graphVaultResource,$graphVaultAPIVersion
            $graphSecretFile = ""
            try
            {
                Invoke-WebRequest -Method GET -Uri $graphVaultEndpoint -Headers @{Metadata='True'} -UseBasicParsing
            }
            catch
            {
                $graphWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
                if ($graphWWWAuthHeader -match "Basic realm=.+")
                {
                    $graphSecretFile = ($graphWWWAuthHeader -split "Basic realm=")[1]
                }
            }
            $graphSecret = Get-Content -Raw $graphSecretFile
            $graphResponse = Invoke-WebRequest -Method GET -Uri $graphVaultEndpoint -Headers @{Metadata='True'; Authorization="Basic $graphSecret"} -UseBasicParsing
            if ($graphResponse)
            {
                $graphToken = (ConvertFrom-Json -InputObject $graphResponse.Content).access_token
            }

            $retrGraphSecret = (Invoke-RestMethod -Uri "https://KeyVaultName.vault.azure.net/secrets/$($graphVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $graphToken"}).value

            #secureGraph
            #The Tenant ID from App Registrations
            $graphTenantId = "graphTenantID"

            # Construct the authentication URL
            $graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
            
            #The Client ID from App Registrations
            $graphClientID = "graphAppID"
            
            
            # Construct the body to be used in Invoke-WebRequest
            $graphBody = @{
                client_id     = $graphClientID
                scope         = "https://graph.microsoft.com/.default"
                client_secret = $retrGraphSecret
                grant_type    = "client_credentials"
            }
            
            # Get Authentication Token
            $graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphBody -UseBasicParsing
            # Extract the Access Token
            $secureGraphToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
            #connect to graph
            Connect-MGGraph -AccessToken $secureGraphToken -NoWelcome
            
            #The section below pulls all of the Jira fields into a variable, converting to and from JSON 
            Write-Output $ticket.key
            $key = $ticket.key 
            $Form = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key" -Headers $headers
            $NewForm = ConvertTo-Json $Form
            $NewForm2 = ConvertFrom-Json $NewForm
            $uData = $NewForm2.fields

            #CustomField_10787 is "New Departments" which is a select list (cascading) in Jira. 
            #$LocationHired is the first selectable value, the $DepartmentString is the second value, for departments at the hired location. 
            #The trim subexpressions are just to ensure that there are no trailing spaces.
            #Customfield_10738 is the Jira CustomField "Work Location", which assigns the user to Office or Shop. This is also used for License / Group Assignment
            $locationHired = $Form.fields.customfield_10787.value.Trim()
            $DepartmentString = $Form.fields.customfield_10787.child.value.Trim()
            $workLoc = $Form.fields.customfield_10738.value

            <#The large majority of customization and specific assignment is handled by the CSV. This includes if the user is going to be created in LAD with a sync into AAD, AAD at large
              What server they are created on, their UPN Suffix, Business Phone (the main phone for the location), CountryCode (ISO), Country, Usage Location, and what groups they
              need to be added into.

              IMPORTANT TO NOTE: CountryCode must be editted via NotePad to ensure that the correct leading 0 is added to Belgium, Australia, and Brasil. EXCEL will automatically remove 
              it, which will cause issues. In a future update, this will be accomodated via script
            #>
            $locationVariables = Import-Csv "C:\ScriptConfigs\New_User\New_Locations_Variables.csv"
            $userLocation = $locationVariables | Where-Object {$_.'Location Hired' -eq $locationHired}
            
            #Location derived information, these are set to individual variables to make the code easier to manage and to reduce fringe errors.
            $country = $userLocation.Country
            $businessPhone = $userLocation.'Business Phone'
            $upnSuffix = $userLocation.'UPN Suffix'
            $usageLoc = $userLocation.'Usage Location'
            $newUserOU = $userLocation.OU
            $createLAD = $userLocation.'Create LAD'
            $newUserServer = $userLocation.newUserServer
            $countryCode = $userLocation.countryCode

            #Groups vary if a user is in the office or the shop, based on this, an E5 license is applied for Office Users and F3 is applied for Shop users. 
            if ($workLoc -eq "Office") {
                $group1 = $userLocation.'Office Group 1'
                $group2 = $userLocation.'Office Group 2'
                $group3 = $userLocation.'Office Group 3'
                $license1 = "SPE_E5"
                $license2 = $null 
            } else {
                $group1 = $userLocation.'Shop Group 1'
                $group2 = $userLocation.'Shop Group 2'
                $group3 = $userLocation.'Shop Group 3'
                $license1 = "SPE_F1"
                $license2 = "POWER_BI_STANDARD"
            }

            <# This area is useful for troubleshooting. In the scheduled task version this is not pushed to any ticket. But when a manual run is initiated
            it displays some of the commonly configured options #> 
            Write-Output "Location hired is: $locationHired"
            Write-Output "Department is: $DepartmentString"
            Write-Output "Work Location is: $workLoc"
            Write-Output "Country is: $country"
            Write-Output "Usage Location is $usageLoc"
            Write-Output "UPN Suffix is: $upnSuffix"
            Write-Output "Business phone is: $businessPhone"
            Write-Output "Group 1 is: $group1"
            Write-Output "Group 2 is: $group2"
            Write-Output "Group 3 is: $group3"
            Write-Output "License 1 is: $license1"
            Write-Output "License 2 is: $license2"



            <#Sets the temporary password for new users. For example, January 31st 2024 is a Wednesday. A user created on this date's password will be set to Wednesday0131!
            The date used is their first day of work, which is the Jira Customfield "Start Date" 
            #>
            $date = $uData.customfield_10613
            $date = get-date $date

            $DoW = $date.DayOfWeek.ToString()
            $Month = (Get-date $date -format "MM").ToString()
            $Day = (Get-date $date -format "dd").ToString()
            $pw = $DoW+$Month+$Day+"!"


             $PasswordProfile = @{
    
                            Password = $pw
                              }




            #Standardizes and Sanitizes the User Information 
            $firstName = $uData.customfield_10768
            $firstName = $firstName.trim()

            #This is to handle last names with a space or hyphen
            If ($firstName -match " ")
                {
                    Write-Output "First Name is: $firstName"
	                Write-Output "This has a space"
                    $firstName = $firstName.split(" ")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+" "+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.Replace(" ","").Trim()
                    Write-Output "First Name for UPN is $firstNameUPN"
	            }
		
		
            ElseIf($firstName -match "-")
                {
	                Write-Output "This is hyphenated"
                    $firstName = $firstName.split("-")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+"-"+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.trim()
                    Write-Output "Last Name for UPN is $firstNameUPN"
	            }
            #If their First Name is not Hyphenated or does not contain a space, it does not get modified.
            Else
            {
            $firstNameUPN = $firstName
            }
		



            $lastName = $uData.customfield_10723
            $lastName = $lastName.trim()
            #This is to handle last names with a space or hyphen
            If ($lastName -match " ")
                {
                    Write-Output "Last Name is: $lastName"
	                Write-Output "This has a space"
                    $lastName = $lastName.split(" ")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+" "+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
	            }
		
		
            ElseIf($lastName -match "-")
                {
	                Write-Output "This is hyphenated"
                    $lastName = $lastName.split("-")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+"-"+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
	            }
            Else
            {
            $lastNameUPN = $lastName
            }
		


            #Proper casing for job title
            $jobtitle = $uData.customfield_10695.substring(0,1).toUpper()+$uData.customfield_10695.substring(1).toLower()
            $jobtitle = $jobtitle.trim()
            $TextInfo = (Get-Culture).TextInfo
            $jobtitle = $TextInfo.ToTitleCase($jobtitle)



            #Set their email address with proper casing
            $emailAddr = $firstNameUPN + "." +$lastNameUPN + $upnSuffix

            #Set their mail nickname with proper casing
            $mailNN = $firstnameUPN + "."+$lastNameUPN
            $mailNN = $mailNN.trim()

            #Set their displayname with proper casing 
            $displayName = $firstname + " " +$lastname
            $displayName = $displayName.trim()


#If the user UPN already exists, detect it here.
If (Get-MGUser -UserId $emailaddr -erroraction SilentlyContinue)
{
    Write-Output "Default Email Address Notation is in use. Email in use is $emailAddr"

    #if the middle initial field is NOT null
   if (!($null -eq $udata.customfield_10724))
   {
   #Pull the middle initial from the Jira field
   $middleInitial = $udata.customfield_10724
   
   #Generate a new UPN
   $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN + $upnSuffix
   
   #if their newly generated UPN is taken, it is detected here
   If (Get-MGUser -UserId $emailaddr -erroraction SilentlyContinue)
    {
        Write-Output "First, Middle, Last Address Notation is in use. Email in use is $emailAddr"
        #determine if they have a suffix filled out from Jira 
        if (!($null -eq $udata.customfield_10725))
        {
        #If the suffix is not null, and the username is not taken, bind it here.
        $nameSuffix = $udata.customfield_10725
        #Create another New UPN 
        $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN +$nameSuffix+ $upnSuffix

        #if the Username of FirstName.MiddleInitial.LastNameUPN.NameSuffix@domainsuffix.com is taken, give up, and update the Jira ticket to 'Needs Done manually' 
        If (Get-MGUser -UserId $emailaddr -erroraction SilentlyContinue)
            {
             Write-Output "First, Middle, Last Address Suffix Notation is in use. Email in use is $emailAddr"
                        $jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. UPN: $emailAddr is already in use."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue  
            }
        }
        else
        {
            $jsonPayload = @"
            {
            "update": {
                    "comment": [
                        {
                            "add": {
                                "body": "Automation Failed. UPN: $emailAddr is already in use."
                            }
                        }
                    ]
                },
            "transition": {
                "id": "981"
            }
        }
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue  
        }

    }


   }         
            
            

}

#If the user is to be created on the Local AD server, the following runs
if($createLAD -eq 'Y' -and $workLoc -eq "Office")
{

#If the user UPN already exists, detect it here.
If (Get-ADUser -Server $newUserServer -Filter "UserPrincipalName -eq '$($emailaddr)'" -erroraction SilentlyContinue)
{
    Write-Output "Default Email Address Notation is in use. Email in use is $emailAddr"

    #if the middle initial field is NOT null
   if (!($null -eq $udata.customfield_10724))
   {
   #Pull the middle initial from the Jira field
   $middleInitial = $udata.customfield_10724
   
   #Generate a new UPN
   $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN + $upnSuffix
    $mailNN = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN
    $mailNN = $mailNN.trim()
   
   #if their newly generated UPN is taken, it is detected here
   If (Get-ADUser -Server $newUserServer -Filter "UserPrincipalName -eq '$($emailaddr)'" -erroraction SilentlyContinue)
    {
        Write-Output "First, Middle, Last Address Notation is in use. Email in use is $emailAddr"
        #determine if they have a suffix filled out from Jira 
        if (!($null -eq $udata.customfield_10725))
        {
        #If the suffix is not null, and the username is not taken, bind it here.
        $nameSuffix = $udata.customfield_10725
        #Create another New UPN 
        $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN +$nameSuffix+ $upnSuffix

        #if the Username of FirstName.MiddleInitial.LastNameUPN.NameSuffix@domainsuffix.com is taken, give up, and update the Jira ticket to 'Needs Done manually' 
        If (Get-ADUser -Server $newUserServer -Filter "UserPrincipalName -eq '$($emailaddr)'" -erroraction SilentlyContinue)
            {
             Write-Output "First, Middle, Last Address Suffix Notation is in use. Email in use is $emailAddr"
                        $jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. UPN: $emailAddr is already in use."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue  
            }
        }
        else
        {
                                $jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. UPN: $emailAddr is already in use."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue  
        }

    }


   }         
            
            

}

Write-Output "Creating $emailAddr on Local AD"
$password = ConvertTo-SecureString -string "$pw" -AsPlainText -Force
$tempVar = $uData.customfield_10765
$ManagerdisplayName = $tempVar.displayName
$Manager = Get-ADUser -filter "CN -eq '$($ManagerdisplayName)'" -server $newUserServer

#SAM Account Names have a requirement to be sub 20 characters, otherwise it fails. 
If ($mailNN.length -gt 20)
{
$acctSAMName = $mailNN.substring(0,20)
}
Else
{
$acctSAMName = $mailNN
}

#Create the new user here 
Try {
New-ADUser -Enabled $true `
            -name $displayName `
            -Country $usageLoc `
            -DisplayName $displayName `
            -UserPrincipalName $emailAddr `
            -OfficePhone $businessPhone `
            -Company $uData.customfield_10756.value`
            -Title $jobtitle `
            -AccountPassword $password `
            -Department $DepartmentString `
            -GivenName $firstName `
            -Office $locationHired `
            -Manager $Manager `
            -Path $newUserOU `
            -Surname $lastName `
            -Server $newUserServer `
            -SamAccountName $acctSAMName -erroraction Stop
}
Catch
{
    $currTime = Get-Date -format "HH:mm"
    $errorLog += [PSCustomObject]@{
        processFailed                   = $procProcess
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] #gets the most recent error
        failedTargetStandardName        = $computerinfo.Name
        failedTargetDNSName             = $computerinfo.DNSHostName
        failedTargetUser                = $computerInfo.Username
        failedTargetWorkGroup           = $computerInfo.Workgroup
        failedTargetDomain              = $computerInfo.Domain
        failedTargetMemory              = $computerInfo.TotalphysicalMemory
        failedTargetChassis             = $computerInfo.ChassisSKUNumber
        failedTargetManufacturer        = $computerInfo.Manufacturer
        failedTargetModel               = $computerInfo.Model

    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    $errorLogFull = $errorLog | select-object -last 1

# Initialize an array to store formatted content
$jbody = @()

# Loop through each errorLog item and format it as a JSON paragraph
foreach ($errorIndv in $errorLog) {
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Process Failed: $($errorIndv.processFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Time Failed: $($errorIndv.timeToFail)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Reason Failed: $($errorIndv.reasonFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Standard Name: $($errorIndv.failedTargetStandardName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target DNS Name: $($errorIndv.failedTargetDNSName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target User: $($errorIndv.failedTargetUser)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target WorkGroup: $($errorIndv.failedTargetWorkGroup)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Domain: $($errorIndv.failedTargetDomain)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Memory: $($errorIndv.failedTargetMemory) MB"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Chassis: $($errorIndv.failedTargetChassis)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Manufacturer: $($errorIndv.failedTargetManufacturer)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Model: $($errorIndv.failedTargetModel)"
                }
            )
        }
    )
    
    $jbody += $paragraphs
}

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $true
            }
        }
    )
}

# Convert the PowerShell object to a JSON string
$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10

# Perform the API call
try {
    $response = Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
    Write-Output "API call successful: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Output "API call failed: $($_.Exception.Message)"
}



#Make a public comment and transition the ticket to a new status
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. UPN: $emailAddr is already in use."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
}


#Set their extension attribute here.            
$extAttr1 = $udata.customfield_10738.value

<#It takes a bit until the user account is created / able to be modified after creation. It will check every 10 seconds until they are discoverable via Get-ADUser
The final 10 second delay is to handle instances that even though it resolves via Get-ADUser it still is not able to be set via Set-ADUser 
#>
$adUserDetector = 0
while ($adUserDetector -le 1)
{
    If (!(Get-ADUser -identity $acctSAMName -Server $newUserServer -ErrorAction SilentlyContinue))
    {
        Write-Output "User does not exist in AD yet. Waiting 10 seconds"
        Start-Sleep -Seconds 10
    }
    Else
    {
        Write-Output "User has been created. Moving to setting properties on prem"
        $adUserDetector = 10
    }


}

#This sets values for a user that can only be done after they are created. It adds their extension attribute, and verifies their country values are populated correctly.
set-aduser $acctSAMName -add @{"extensionAttribute1"=$extAttr1} -Server $newUserServer
set-aduser $acctSAMName -Replace @{c="$usageLoc";co="$country";countrycode=$countryCode} -Server $newUserServer
 

#Sync the new user, which creates them in AAD 
Start-ADSyncSyncCycle -PolicyType Delta 

#Similiar to the ADUserDetector, this waits until they are available in MGGraph and then sets some values that can only be set in the cloud 
$mgUserDetector = 0
while ($mgUserDetector -le 1)
{
    If (!(Get-MGUser -userid $emailaddr -ErrorAction SilentlyContinue))
    {
        Write-Output "User does not exist in AAD yet. Waiting 10 seconds"
        Start-Sleep -Seconds 10
    }
    Else
    {
        Write-Output "User has been created. Moving to setting properties that are Graph Only after a final minute delay to ensure account is addressable"
        Start-Sleep -Seconds 60
        $mgUserDetector = 10
    }


}
#adds a usage location and enables their account 
Update-MGUser -UserId $emailAddr -UsageLocation $usageLoc -AccountEnabled:$true


}
#If their location hired is not compatible / configured with Domain Trust and VPN connections back to HQ, the new user account is just created in the cloud.
Else
{
Write-Output "Creating $emailAddr on MG Graph"
            New-MGuser -AccountEnabled `
            -ShowInAddressList `
            -UsageLocation $usageLoc `
            -Country $country `
            -DisplayName $displayName `
            -UserPrincipalName $emailAddr `
            -BusinessPhones $businessPhone `
            -CompanyName $uData.customfield_10756.value`
            -JobTitle $jobtitle `
            -PasswordProfile $PasswordProfile `
            -Department $DepartmentString `
            -MailNickName $mailNN `
            -GivenName $firstName `
            -EmployeeHireDate $uData.customfield_10613 `
            -OfficeLocation $locationHired `
            -EmployeeType $uData.customfield_10736.value`
            -Surname $lastName `

            $time = Get-Date
            Write-Output "Waiting 1 minute at $time to allow for license assignment and group creation"
            Start-Sleep -Seconds 60


            #Pull the Manager ID user information to bind to the new user
            $tempVar = $uData.customfield_10765
            $managerID = (Get-MGUser -Search "UserPrincipalName:$($tempvar.emailAddress)" -ConsistencyLevel:eventual -top 1).ID 

            if ($null -eq $managerID)
            {
            Write-Output "Unable to find the manager via UPN, checking via Display Name"
            $managerID = (Get-MGUser -Search "DisplayName:$($tempvar.displayName)" -ConsistencyLevel:eventual -top 1).ID

            }


            #Retrieve the ObjectID of the created user to update fields that can only be done after creation
            $userObjID = (Get-MGUser -UserID $emailAddr).ID


	        #Sets the Manager ID
            $params = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
            }

            #Sets manager of the user 
            Set-MgUserManagerByRef -UserId $emailAddr -BodyParameter $params
}
#Doclink and Citrix User Adds Get Done Here
$softwareNeeds = $form.fields.customfield_10747.value
$procProcess = 'CompuData and Citrix Evaluation'
If ($locationHired -eq 'parentCompany East' -and (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')))
{
    try{
    $compuDataGroup1 = Get-ADGroup -Identity "Citrix Cloud W11M Desktop Users" -server 'Domain.extension1'
    $compuDataGroup2 = Get-ADGroup -Identity "DocLink Users" -Server 'Domain.extension1'
    Add-ADGroupMember -identity $compuDataGroup1 -members $acctSAMName
    Add-ADGroupMember -identity $compuDataGroup2 -members $acctSAMName
    }
    Catch{
        $currTime = Get-Date -format "HH:mm"
        $errorLog += [PSCustomObject]@{
        processFailed                   = $procProcess
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] #gets the most recent error
        failedTargetStandardName        = $computerinfo.Name
        failedTargetDNSName             = $computerinfo.DNSHostName
        failedTargetUser                = $computerInfo.Username
        failedTargetWorkGroup           = $computerInfo.Workgroup
        failedTargetDomain              = $computerInfo.Domain
        failedTargetMemory              = $computerInfo.TotalphysicalMemory
        failedTargetChassis             = $computerInfo.ChassisSKUNumber
        failedTargetManufacturer        = $computerInfo.Manufacturer
        failedTargetModel               = $computerInfo.Model

    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    $errorLogFull = $errorLog | select-object -last 1

# Initialize an array to store formatted content
$jbody = @()

# Loop through each errorLog item and format it as a JSON paragraph
foreach ($errorIndv in $errorLog) {
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Process Failed: $($errorIndv.processFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Time Failed: $($errorIndv.timeToFail)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Reason Failed: $($errorIndv.reasonFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Standard Name: $($errorIndv.failedTargetStandardName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target DNS Name: $($errorIndv.failedTargetDNSName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target User: $($errorIndv.failedTargetUser)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target WorkGroup: $($errorIndv.failedTargetWorkGroup)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Domain: $($errorIndv.failedTargetDomain)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Memory: $($errorIndv.failedTargetMemory) MB"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Chassis: $($errorIndv.failedTargetChassis)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Manufacturer: $($errorIndv.failedTargetManufacturer)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Model: $($errorIndv.failedTargetModel)"
                }
            )
        }
    )
    
    $jbody += $paragraphs
}

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $true
            }
        }
    )
}

# Convert the PowerShell object to a JSON string
$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10

# Perform the API call
try {
    $response = Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
    Write-Output "API call successful: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Output "API call failed: $($_.Exception.Message)"
}



#Make a public comment and transition the ticket to a new status
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. Error on Creation: $emailAddr. Review internal notes for more details"
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
    }

}
elseif ($locationHired -ne 'parentCompany East' -and (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')))
{
    try{
                #SAM Account Names have a requirement to be sub 20 characters, otherwise it fails. 
                If ($mailNN.length -gt 20)
                {
                $acctSAMName = $mailNN.substring(0,20)
                }
                Else
                {
                $acctSAMName = $mailNN
                }
                $date = $uData.customfield_10613
                $date = get-date $date

                $DoW = $date.DayOfWeek.ToString()
                $Month = (Get-date $date -format "MM").ToString()
                $Day = (Get-date $date -format "dd").ToString()
                $pw = $DoW+$Month+$Day+"!"
                $password = ConvertTo-SecureString -string "$pw" -AsPlainText -Force

                $compuDataUPN = $emailAddr.Split('@')[0] +"@Domain.extension1"
                #Create the new user here 
                New-ADUser -Enabled $true `
                -name $displayName `
                -Country "US" `
                -DisplayName $displayName `
                -UserPrincipalName $compuDataUPN `
                -OfficePhone "14107562600" `
                -Company "Not Affiliated" `
                -Title "DocLink User"`
                -AccountPassword $password `
                -Department "Service Account" `
                -GivenName $firstName `
                -Office "parentCompany East" `
                -Path "OU=CompuData - External Sage Users - Non-Synching,DC=parentCompany,DC=COM" `
                -Surname $lastName `
                -Server "Domain.extension1" `
                -EmailAddress $emailAddr `
                -SamAccountName $acctSAMName -erroraction Stop
    
                $procStartTime = Get-Date
                $currTime = Get-Date -format "HH:mm"
                $procEndTime = Get-Date
                $procNetTime = $procEndTime - $procStartTime
                Write-Output "[$($currTime)] | [$process] | [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
                $compuDataGroup1 = Get-ADGroup -Identity "Citrix Cloud W11M Desktop Users" -server 'Domain.extension1'
                $compuDataGroup2 = Get-ADGroup -Identity "DocLink Users" -Server 'Domain.extension1'
                Add-ADGroupMember -identity $compuDataGroup1 -members $acctSAMName
                Add-ADGroupMember -identity $compuDataGroup2 -members $acctSAMName
                Set-ADUser $acctSAMName -ChangePasswordAtLogon $true -erroraction Stop
    }
    Catch{
        $currTime = Get-Date -format "HH:mm"
        $errorLog += [PSCustomObject]@{
        processFailed                   = $procProcess
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] #gets the most recent error
        failedTargetStandardName        = $computerinfo.Name
        failedTargetDNSName             = $computerinfo.DNSHostName
        failedTargetUser                = $computerInfo.Username
        failedTargetWorkGroup           = $computerInfo.Workgroup
        failedTargetDomain              = $computerInfo.Domain
        failedTargetMemory              = $computerInfo.TotalphysicalMemory
        failedTargetChassis             = $computerInfo.ChassisSKUNumber
        failedTargetManufacturer        = $computerInfo.Manufacturer
        failedTargetModel               = $computerInfo.Model

    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    $errorLogFull = $errorLog | select-object -last 1

# Initialize an array to store formatted content
$jbody = @()

# Loop through each errorLog item and format it as a JSON paragraph
foreach ($errorIndv in $errorLog) {
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Process Failed: $($errorIndv.processFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Time Failed: $($errorIndv.timeToFail)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Reason Failed: $($errorIndv.reasonFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Standard Name: $($errorIndv.failedTargetStandardName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target DNS Name: $($errorIndv.failedTargetDNSName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target User: $($errorIndv.failedTargetUser)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target WorkGroup: $($errorIndv.failedTargetWorkGroup)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Domain: $($errorIndv.failedTargetDomain)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Memory: $($errorIndv.failedTargetMemory) MB"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Chassis: $($errorIndv.failedTargetChassis)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Manufacturer: $($errorIndv.failedTargetManufacturer)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Model: $($errorIndv.failedTargetModel)"
                }
            )
        }
    )
    
    $jbody += $paragraphs
}

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $true
            }
        }
    )
}

# Convert the PowerShell object to a JSON string
$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10

# Perform the API call
try {
    $response = Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
    Write-Output "API call successful: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Output "API call failed: $($_.Exception.Message)"
}



#Make a public comment and transition the ticket to a new status
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. Error on Creation: $emailAddr. Review internal notes for more details"
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
    }


}



#The variance between creation options converges at this point 

             #Sets Licensing in M365
                if ($license1 -eq "" -or $null -eq $license1) 
                {
                    Write-Output "Null"
                } 
                else 
                {
                    $sku1 = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $license1
                    $remLisc = $sku1.prepaidunits.enabled - $sku1.consumedunits
	
	        if ($remlisc -le 0)
	        { 
    
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation failed, $license1 licenses need purchased"
                    }
                }
            ]
        },
    "transition": {
        "id": "991"
    }
}
"@ 
                    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
                    continue
	                }
                    Else
                    {

                            Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()
                    }


                }


                if ($license2 -eq "" -or $null -eq $license2) 
                {
                    Write-Output "Null"
                } 
                else 
                {
                    $sku1 = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $license2
                    $remLisc = $sku1.prepaidunits.enabled - $sku1.consumedunits
	
	        if ($remlisc -le 0)
	        { 
	
	        
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation failed, $license2 licenses need purchased"
                    }
                }
            ]
        },
    "transition": {
        "id": "991"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
	        }
            Else
            {

                    Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()
            }


            }
                if ($usageLoc -in "IT","CA","BE","AU","DE","DK","VN","AE","MY","GB","ZA")
                {
                $sku3 = Get-MgSubscribedSku -All |  Where-Object -Property SkuPartNumber -eq 'OFFICE365_MULTIGEO'
                $remLisc = $sku3.prepaidunits.enabled - $sku3.consumedunits
	
	        if ($remlisc -le 0)
	        { 
	
	        
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation failed, OFFICE365_MULTIGEO licenses need purchased"
                    }
                }
            ]
        },
    "transition": {
        "id": "991"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
	        }
            Else
            {

                    Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku3.SkuId} -RemoveLicenses @()
            }


                }
            #After the user has been created and licenses have been applied, their mailbox is generated. This waits until their email is created to set email address values
            $emailDetector = 0
            while ($emailDetector -le 1)
                {
                If (!(Get-Exomailbox -identity $emailAddr -ErrorAction SilentlyContinue))
                    {
                        Write-Output "Mailbox does not exist yet. Waiting 10 seconds"
                        Start-Sleep -Seconds 10
                    }
                Else
                    {
                        Write-Output "Mailbox has been created. Moving onto Group Assignment."
                        $emaildetector = 10
                    }
                }
            #set the extension attribute on the mailbox if they were created in the cloud
            if($createLAD -eq 'N')
            {

            $extAttr1 = $udata.customfield_10738.value

            Set-Mailbox $emailAddr -customattribute1 $extAttr1
            }




            #Sets Groups in AzureAD and ExchangeOnline

            #Group1
                if ($group1 -eq "" -or $null -eq $group1) 
                {
                    Write-Output "Null"
                } 
    
                else 
                {
                    $gname = $group1
                    $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
                        } 
                    catch 
                        {
                        Write-Output "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $group1 -member $emailAddr -BypassSecurityGroupManagerCheck -erroraction stop
                            }
                        catch
                            {
                            Write-Output "Unable to add $emailAddr to "$group1 ". Please do this manually."
                            }
                        }
                }

            #Group2

                    if ($group2 -eq "" -or $null -eq $group2) 
                {
                    Write-Output "Null"
                } 
    
                else 
                {
                    $gname = $group2
                    $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
                        } 
                    catch 
                        {
                        Write-Output "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $group2 -member $emailAddr -BypassSecurityGroupManagerCheck -erroraction stop
                            }
                        catch
                            {
                            Write-Output "Unable to add $emailAddr to "$group2 ". Please do this manually."
                            }
                }
                }

            #Group3    
                    if ($group3 -eq "" -or $null -eq $group3) 
                {
                    Write-Output "$Null"
                } 
    
                else 
                {
                    $gname = $group3
                    $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
                        } 
                    catch 
                        {
                        Write-Output "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $group3 -member $emailAddr -BypassSecurityGroupManagerCheck -erroraction stop
                            }
                        catch
                            {
                            Write-Output "Unable to add $emailAddr to "$group3 ". Please do this manually."
                            }
                         }

                }
        #add the New User to the MFA Enabled Group
        New-MgGroupMember -GroupId "Group10" -DirectoryObjectId $userObjID
        #Logic
        if ($DepartmentString -eq "Global Information Technology")
        {
            try
            {
                $gname = "IDSecurity-GIT Primary"
                $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                $userObjID = (Get-MGUser -UserID $emailAddr).ID
                New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
            }
            catch
            {
            Write-Output "Unable to add $emailAddr to "$gname ". Please do this manually."
            }
    
        }

        Elseif ($DepartmentString -eq "Executive")
        {
            try
            {
                $gname = "Group9"
                $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                $userObjID = (Get-MGUser -UserID $emailAddr).ID
                New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
            }
            catch
            {
            Write-Output "Unable to add $emailAddr to "$gname ". Please do this manually."
            }
    
        }
        
        Elseif ($usageLoc -in "IT","BE","DE","DK","GB")
        {
        $null
        }


        Else
        {
            if ($license1 -eq "SPE_E5")
            { 
                $licStr = "E5"
            }
            if ($license1 -eq "SPE_F1")
            { 
                $licStr = "F3"
            }

            $gname = "IDSecurity-"+$licStr+"-"+$usageLoc
            try
            {
                $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                $userObjID = (Get-MGUser -UserID $emailAddr).ID
                New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
            }
            catch
            {
            Write-Output "Unable to add $emailAddr to "$gname ". Please do this manually."
            }
    

        }
               
            

        #Close the Ticket with a comment      
        # Create the JSON payload
If ($locationHired -eq 'parentCompany East' -and (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')))
{
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Standard Username: $emailAddr"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Citrix/Sage/DocLink/CompuData Account: $emailAddr"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Password: $pw"
                }
            )
        }
    )
    
    $jbody += $paragraphs

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $false
            }
        }
    )
}

$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers


# Define the URL
$JiraUrl = "https://parentCompany.atlassian.net/rest/api/3/issue/$key"

# Create the JSON payload
$body = @{
    fields = @{
        customfield_10919 = "$emailAddr"
    }
} | ConvertTo-Json -Depth 4


$response = Invoke-RestMethod -Method Put -Uri $JiraUrl -Headers $headers -Body $body
}

elseif ($locationHired -ne 'parentCompany East' -and (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')))
{
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Standard Username: $emailAddr"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Citrix/Sage/DocLink/CompuData Account: $compuDataUPN"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Password: $pw"
                }
            )
        }
    )
    
    $jbody += $paragraphs

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $false
            }
        }
    )
}
$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers


# Define the URL
$JiraUrl = "https://parentCompany.atlassian.net/rest/api/3/issue/$key"
# Create the JSON payload
$body = @{
    fields = @{
        customfield_10919 = "$compuDataUPN"
    }
} | ConvertTo-Json -Depth 4
$response = Invoke-RestMethod -Method Put -Uri $JiraUrl -Headers $headers -Body $body
}

    $jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Resolved via automated process. New user password is $pw."
                    }
                }
            ]
        },
    "transition": {
        "id": "961"
    }
}
"@
Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
} 



            
        
}   


#For Full Script End:
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
Write-Output "Errors: `n`n`n"
Write-Output $errorLogFull
Write-Output "Your Error Log is also available as a CSV at $exportPath"
$ErrorLogFull | Export-CSV -Path $exportPath 
SignatureBlock

