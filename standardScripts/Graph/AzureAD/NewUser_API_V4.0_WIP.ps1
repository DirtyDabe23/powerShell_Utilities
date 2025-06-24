#################################################################################Script Configuration################################################################################
Clear-Host 
$process = "New User Automation"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

#This WMI Query gets a ton of rich information about the endpoint
$computerInfo = Get-WMIObject -class Win32_ComputerSystem | select-object -Property *

#File Creation Objects
$shareLoc = "\\evapcousers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "$($process).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$fileName

#Error Logging
$errorLogFull = @()

#Log Timing For the Full Process Start
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] [$process] Starting"

#################################################################################API Connections#################################################################################

#Connection to the Jira API after getting the token from the Key Vault
$jiraVaultName = 'JiraAPI'
$jiraAPIVersion = "2020-06-01"
$jiraResource = "https://vault.azure.net"
$jiraEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$jiraResource,$jiraAPIVersion
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

$jiraRetrSecret = (Invoke-RestMethod -Uri "https://us-tt-vault.vault.azure.net/secrets/$($jiraVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}




#How to get all new user onboarding requests, this returns only issues with the summary of 'Onboard Request'
$pendingRequests = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/search?jql=project%20%3D%20GHD%20AND%20summary%20~%20%22Onboard%20Request%22%20AND%20status%20%3D%20%22Ready%20For%20Automation%22" -Headers $headers

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
            $exoORG = "evapcoinc.onmicrosoft.com"
		
            Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

           #Authentication via KeyVault To Graph:
            $graphVaultName = 'GITGraphAPI'
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

            $retrGraphSecret = (Invoke-RestMethod -Uri "https://us-tt-vault.vault.azure.net/secrets/$($graphVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $graphToken"}).value

            #secureGraph
            #The Tenant ID from App Registrations
            $graphTenantId = "9e228334-bae6-4c7e-8b7f-9b0824082151"

            # Construct the authentication URL
            $graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
            
            #The Client ID from App Registrations
            $graphClientID = "56cb7f72-67ee-4531-96d7-39a4e2b53555"
            
            
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
            $Form = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/issue/$key" -Headers $headers
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

            $otherEmail = $udata.customfield_10727.trim()


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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
    $response = Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            -OtherMails $otherEmail `

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
                    Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
        New-MgGroupMember -GroupId "276cd6bd-7e8f-483b-9e33-6b6e364bdd50" -DirectoryObjectId $userObjID
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
                $gname = "IDSecurity-Executive Leadership"
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
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Resolved via automated process. New user password is $pw"
                    }
                }
            ]
        },
    "transition": {
        "id": "961"
    }
}
"@ 



            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
        
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
# SIG # Begin signature block
# MIIuqwYJKoZIhvcNAQcCoIIunDCCLpgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDq3Egegk0nnQ7r
# H3l3Vitj4N/oogYQPRJO9CHLS9RPWaCCFAUwggWQMIIDeKADAgECAhAFmxtXno4h
# MuI5B72nd3VcMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0xMzA4MDExMjAwMDBaFw0z
# ODAxMTUxMjAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/z
# G6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZ
# anMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7s
# Wxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL
# 2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfb
# BHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3
# JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3c
# AORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqx
# YxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0
# viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aL
# T8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjQjBAMA8GA1Ud
# EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzANBgkqhkiG9w0BAQwFAAOCAgEAu2HZfalsvhfEkRvDoaIAjeNk
# aA9Wz3eucPn9mkqZucl4XAwMX+TmFClWCzZJXURj4K2clhhmGyMNPXnpbWvWVPjS
# PMFDQK4dUPVS/JA7u5iZaWvHwaeoaKQn3J35J64whbn2Z006Po9ZOSJTROvIXQPK
# 7VB6fWIhCoDIc2bRoAVgX+iltKevqPdtNZx8WorWojiZ83iL9E3SIAveBO6Mm0eB
# cg3AFDLvMFkuruBx8lbkapdvklBtlo1oepqyNhR6BvIkuQkRUNcIsbiJeoQjYUIp
# 5aPNoiBB19GcZNnqJqGLFNdMGbJQQXE9P01wI4YMStyB0swylIQNCAmXHE/A7msg
# dDDS4Dk0EIUhFQEI6FUy3nFJ2SgXUE3mvk3RdazQyvtBuEOlqtPDBURPLDab4vri
# RbgjU2wGb2dVf0a1TD9uKFp5JtKkqGKX0h7i7UqLvBv9R0oN32dmfrJbQdA75PQ7
# 9ARj6e/CVABRoIoqyc54zNXqhwQYs86vSYiv85KZtrPmYQ/ShQDnUBrkG5WdGaG5
# nLGbsQAe79APT0JsyQq87kP6OnGlyE0mpTX9iV28hWIdMtKgK1TtmlfB2/oQzxm3
# i0objwG2J5VT6LaJbVu8aNQj6ItRolb58KaAoNYes7wPD1N1KarqE3fk3oyBIa0H
# EEcRrYc9B9F1vM/zZn4wggawMIIEmKADAgECAhAIrUCyYNKcTJ9ezam9k67ZMA0G
# CSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0zNjA0MjgyMzU5NTla
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDVtC9C
# 0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0JAfhS0/TeEP0F9ce
# 2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJrQ5qZ8sU7H/Lvy0da
# E6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhFLqGfLOEYwhrMxe6T
# SXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+FLEikVoQ11vkunKoA
# FdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh3K3kGKDYwSNHR7Oh
# D26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJwZPt4bRc4G/rJvmM
# 1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQayg9Rc9hUZTO1i4F4z
# 8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbIYViY9XwCFjyDKK05
# huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchApQfDVxW0mdmgRQRNY
# mtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRroOBl8ZhzNeDhFMJlP
# /2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IBWTCCAVUwEgYDVR0T
# AQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHwYD
# VR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNV
# HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRU
# cnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEEATAN
# BgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql+Eg08yy25nRm95Ry
# sQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFFUP2cvbaF4HZ+N3HL
# IvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1hmYFW9snjdufE5Btf
# Q/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3RywYFzzDaju4ImhvTnh
# OE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5UbdldAhQfQDN8A+KVssIh
# dXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw8MzK7/0pNVwfiThV
# 9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnPLqR0kq3bPKSchh/j
# wVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatEQOON8BUozu3xGFYH
# Ki8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bnKD+sEq6lLyJsQfmC
# XBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQjiWQ1tygVQK+pKHJ6l
# /aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbqyK+p/pQd52MbOoZW
# eE4wgge5MIIFoaADAgECAhAOeHFNrWpQadD+X7fviblJMA0GCSqGSIb3DQEBCwUA
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwHhcNMjQxMTEyMDAwMDAwWhcNMjUxMTEyMjM1OTU5WjCBwTET
# MBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgECEwhNYXJ5bGFuZDEd
# MBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEjAQBgNVBAUTCUQwMDY2ODUz
# MzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE1hcnlsYW5kMRIwEAYDVQQHEwlUYW5l
# eXRvd24xEzARBgNVBAoTCkV2YXBjbyBJbmMxEzARBgNVBAMTCkV2YXBjbyBJbmMw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC4VmB16u7QUgi83PhnLWjD
# oSTpgThLIDktbX4jcd5iGW2EIcARhLhX7iUEamx07U9bQgFAElu145EAozu/h/Ed
# KmK6ij2NWOeiv7le/1LlElR+5A5zxYETPArZvETgBa0aORcVZ6MZogWcoSCUH9uo
# 64yLR7rCUAFYjLwfWfnMrjFclOhmzHhQdkrhz527pJbOIPjJFNITmM6RhYzTq02L
# 0fPq7oIkL5eXgkFljr90IUDj5mL5aqRgTUzMEfTWBJYeBkA+lS6xaPyPhFtQazxi
# Rel1K+kyD+1ohzgUOWXIO3RiQKCgWeuVJZMQrS1+ODcFba/hepMT8MKDNGwXeSc5
# RHNJ2mCkdbP3CfIO7BhKJC+4p7L6a1+YsRR/c3CEcFH++NsOKdcmFbzpzpH3skNe
# X+71Vn0VNXmgrSje/x26Wo+FKzra50FA57QXtBB3rz/0mtZaLWuqkoG/tSuBjNvV
# J2yCAajIuiS5Nooik8+76Ajw4PQSkIe/s9xOzHc6gvxekQtLYV6fJQ/f15VuPSZ1
# Gdo9310rzQWnB9xiZe2BR1ylzq/5/aM/1HmU+zXwyEFthy2wFkGXJK8u4JC7vmcH
# Rp7pyhhwyWn56UHZANllz08OpeR13yvWQZeaJwp0TOLgHglth+XDuULMv8vkR98c
# ge7YAkIOLVFeiLUKjYGT1wIDAQABo4ICAjCCAf4wHwYDVR0jBBgwFoAUaDfg67Y7
# +F8Rhvv+YXsIiGX0TkIwHQYDVR0OBBYEFOdeboNElsywAuHpL+DqJa6ik83MMD0G
# A1UdIAQ2MDQwMgYFZ4EMAQMwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdp
# Y2VydC5jb20vQ1BTMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIxQ0Ex
# LmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcmwwgZQGCCsG
# AQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3J0
# MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggIBAM8Sju/eIoI6/OS+2VcTmBjQ
# CJsjEtyjxGAWS7OQm1XuJqOyR4XZIFbi9UE5A0zDAuH4pwD8fYpEfn3terhffRHz
# /HA/cMSu92C4OJAf/AUO20BMo7fRnWh1F+wTUv+K1bCWHZS245m03NE+UqlvTNu8
# LzvvXBTtEckQdB2XlY39MdWDYxJFINL6bQT7vtGdBvZqDGAeyTaVlvSxHkvDVDtQ
# r2K1y3aaZyz91Ek+eTyeCxb0dUkEsntT066cqd1DuvDg5o6qsCJXS/CEfV5u27py
# 5XV3GMeRSw9iAK8eujrfCoztRUia+ZLZoZ/5isqRmokeynNi+KY/VSe2jMIqoJ3J
# yNsEZFJAPF0M6hDcAjzETOSA1ZcvR6npB1jaUDPWKIld7s8gpWV/8jM+61Kh3Sj0
# I1O2JZCxpLegx1dDSCkmUufK6Io3FH1zjQtddQnlAFwW+3IPfyoP0YKlIyenlF0h
# fuBxOlaJ8LZ7VLFcNWzGjhOdwOV/t+JnxVJPFx1RXR3Q8NmmMe08afq22TLpkXQL
# KwXuKtSi3h1cmOFPtnEqABB5VLUPYZlINCgNFWSY+gKCULWJKkQhpVN5r1yO3LbT
# tDRvoQRwPoNs9CkNVl9HQ+Qv6sbpqAqLfGEeN+SEv7lo9lUsUKxAaw1yaVBHIISI
# anBZbb3T3Kf7DmGQDth6MYIZ/DCCGfgCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQg
# RzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAOeHFNrWpQ
# adD+X7fviblJMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIByQI9mBqfiIFsPVLpdYgQpy
# kDD2sy7gd3INOh9RzfLzMA0GCSqGSIb3DQEBAQUABIICAF9GmdZfoka32Du0S5PT
# YicFmmAvilFd5mX47MgRAlZ33bsn6wckR+xTzIG8lJhndrdvbcH6SCyk7t+5CxXm
# jhbShQ7pmAlR66qcKRDHYxylYKGV01daaNIAknYzN0ofEL0nghaNXNPYnqLmQIVe
# TUVhwY5R37Mxauf6BoRAmVfk/bIKKvJtA6A4jutoNeDSVvXs+Fih9qnlzyW1O/zL
# M4Ruv2nnTmGXfaUsecLH8dITEq0yyutOs1Adp/eWZYTJD4UcFcCPECctPC51AZg+
# bWKRJUFYH/Do8mkw6YDzjiyWUv3Tzgd3R1pvxpMyszCzmQ3eYp+uQKfUDMJnrAh3
# wSTjnl5GmeK471I7CZtalaquIRRSoK2XRQ6g+tT69wRGIeWRrKz1TXOitUYu8dvX
# qOam5bHk3UKR+wPryf1457yl75k8t68mkCusYvOEM4E3q7+q2EGsXbJFwGN8nK3Q
# Ctr9fjxTUTVNuK5vLGHgvM3GUPAlTee+Ls53evHmkPLI9HRiTD2u+0aIvyry7KSb
# 54h7Jw22qVyJ9k0GEzRbzC4l1Em/nzKHyt4jV1VRUA89HfstcEzc49HJ6agxQaFQ
# ywLB1N3DFgjrDappHgEvX5fhvdfBmuBWocP6YRLE1RSXBgjeW1U8Eqqv+2rXw3Qh
# z7Md3++qWPmB9u34e0j0T+6/oYIWyTCCFsUGCisGAQQBgjcDAwExgha1MIIWsQYJ
# KoZIhvcNAQcCoIIWojCCFp4CAQMxDTALBglghkgBZQMEAgEwgeUGCyqGSIb3DQEJ
# EAEEoIHVBIHSMIHPAgEBBgkrBgEEAaAyAgMwMTANBglghkgBZQMEAgEFAAQgpo7R
# p/jbncskJIRrhzbtmhVMXcxY4AbLZTcYkhBvujUCFCHmMA2y3QV4kIaF51pFRIWf
# bnr2GA8yMDI0MTIxOTE3NTg1OVowAwIBAaBgpF4wXDELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoMEEdsb2JhbFNpZ24gbnYtc2ExMjAwBgNVBAMMKUdsb2JhbHNpZ24gVFNB
# IGZvciBBZHZhbmNlZCAtIEc0IC0gMjAyMzExoIISUzCCBmswggRToAMCAQICEAEZ
# dXRxyZLXRN+lluu5cBUwDQYJKoZIhvcNAQELBQAwWzELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gU0hBMzg0IC0gRzQwHhcNMjMxMTAyMTAzMDAyWhcNMzQx
# MjA0MTAzMDAyWjBcMQswCQYDVQQGEwJCRTEZMBcGA1UECgwQR2xvYmFsU2lnbiBu
# di1zYTEyMDAGA1UEAwwpR2xvYmFsc2lnbiBUU0EgZm9yIEFkdmFuY2VkIC0gRzQg
# LSAyMDIzMTEwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCyNUZ0qoON
# 1ZanPEjVxcqo31S+CKuh31zpSdBgXrWlGvdDWEOXPPRnYwgyPBl/K9lVRtXUjMBc
# z6TFpRq6pyvOJkIhPOW7oaOV3WDqElWu787cMoTto7XgP3PRNbibu8VE3eG46/NZ
# rYn2cY9aCvoKkgWEDZcBvwW7/FgBs43J1AWFp5ArbqzT2U7apyQ1lm+qs6BBO+D5
# 5xGO1WYCgC09zM8epJaLF4DcTDkaJHUsxXcW2ZGDJn/nE4uiRVTmtkp359ItLuew
# PEjZxo37evQrvKYiSKLX3q14R4gMX5v0kUoGHPoDnmpWHisw4/OOWbC0Hx5hOIZ5
# +YODlI8JMEIztA63iIIYLT/XgYsnoGnx0wWuxkWjwh+brenAyE/X58anQTJo/1nK
# VFz7v9kfFvBS0s+4NZWlkc6jHfV2UpjskWGLCaGtmZnorJQolziMCa48nPh+UaI3
# ashxuh1PDSYBVn5Xw3VC2FPgY2Pdfp4dqGLozv6ZWVP28wCK/ZOVz9ECAwEAAaOC
# AagwggGkMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAd
# BgNVHQ4EFgQUxL7uhzyJdA7es+4ZG4UMzkFOf50wVgYDVR0gBE8wTTAIBgZngQwB
# BAIwQQYJKwYBBAGgMgEeMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2Jh
# bHNpZ24uY29tL3JlcG9zaXRvcnkvMAwGA1UdEwEB/wQCMAAwgZAGCCsGAQUFBwEB
# BIGDMIGAMDkGCCsGAQUFBzABhi1odHRwOi8vb2NzcC5nbG9iYWxzaWduLmNvbS9j
# YS9nc3RzYWNhc2hhMzg0ZzQwQwYIKwYBBQUHMAKGN2h0dHA6Ly9zZWN1cmUuZ2xv
# YmFsc2lnbi5jb20vY2FjZXJ0L2dzdHNhY2FzaGEzODRnNC5jcnQwHwYDVR0jBBgw
# FoAU6hbGaefjy1dFOTOk8EC+0MO9ZZYwQQYDVR0fBDowODA2oDSgMoYwaHR0cDov
# L2NybC5nbG9iYWxzaWduLmNvbS9jYS9nc3RzYWNhc2hhMzg0ZzQuY3JsMA0GCSqG
# SIb3DQEBCwUAA4ICAQCzMtHqZ//b36e0N0Rd7R6+diPJzgPtTdRq5zOMPF8gYtvu
# 6Ww4OeWZcfsmkR8nsXNcAxnPaDLQ1eZ2eEqqPJcy0hXuehwyPGCnQcq5PvFB6sPT
# 8cflvt4axsGOIt/WgOWP8qyyIY14tsSJjJS9MnO42JdEPNdmbA0cEFxeqIhAvaCu
# TlotZE8GJaWExjhwx1RzFI1XFqkwHKgJSd+lAQYDvxOzdJSbB4GvDUGQVSmwYKlU
# +jggM84Jug5MZ1iBhqntiIapmOO25UaXJEdsSNEQaspxsj5dwz0tIYJrg2Nvl8CR
# /vt9lrmqwBzNpa2QeIDWfW2JKkCOrCX664g2I36G8vu1Bu0ogyyz2pp6b0gRFpQ2
# tUVAnYE1DcWxjJs75jzpehhQ+TmKkne7kSJuoLlbKgFAKOTRSKkwjqKGEjdNyVmZ
# x6YDf+GRCn0K+AtCDnGu9s+65TH4+R8t8OAKjISMpTmjO7DzNtlD1ZuYJA/QwuMm
# Pq3h+/seq94G9vtoQewx36nJHowZ9j72Hpgu0WCBWyZ09FROQATftV7U9+7wDYdv
# QECnaeooyKGpT3cSiTFq6ZqDd4upxUQz7rdpTiy0p7SVeJvWqkAsNhqnREOzUthg
# xnNXv3zWNdMjo2BCItYWFc4TGunO9eXPWr6sP3Pp+nO/Gc2il2bKHGANor1UzDCC
# BlkwggRBoAMCAQICDQHsHJJA3v0uQF18R3QwDQYJKoZIhvcNAQEMBQAwTDEgMB4G
# A1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkdsb2JhbFNp
# Z24xEzARBgNVBAMTCkdsb2JhbFNpZ24wHhcNMTgwNjIwMDAwMDAwWhcNMzQxMjEw
# MDAwMDAwWjBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1z
# YTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQg
# LSBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAPAC4jAj+uAb4Zp0
# s691g1+pR1LHYTpjfDkjeW10/DHkdBIZlvrOJ2JbrgeKJ+5Xo8Q17bM0x6zDDOuA
# Zm3RKErBLLu5cPJyroz3mVpddq6/RKh8QSSOj7rFT/82QaunLf14TkOI/pMZF9nu
# Mc+8ijtuasSI8O6X9tzzGKBLmRwOh6cm4YjJoOWZ4p70nEw/XVvstu/SZc9FC1Q9
# sVRTB4uZbrhUmYqoMZI78np9/A5Y34Fq4bBsHmWCKtQhx5T+QpY78Quxf39GmA6H
# PXpl69FWqS69+1g9tYX6U5lNW3TtckuiDYI3GQzQq+pawe8P1Zm5P/RPNfGcD9M3
# E1LZJTTtlu/4Z+oIvo9Jev+QsdT3KRXX+Q1d1odDHnTEcCi0gHu9Kpu7hOEOrG8N
# ubX2bVb+ih0JPiQOZybH/LINoJSwspTMe+Zn/qZYstTYQRLBVf1ukcW7sUwIS57U
# QgZvGxjVNupkrs799QXm4mbQDgUhrLERBiMZ5PsFNETqCK6dSWcRi4LlrVqGp2b9
# MwMB3pkl+XFu6ZxdAkxgPM8CjwH9cu6S8acS3kISTeypJuV3AqwOVwwJ0WGeJoj8
# yLJN22TwRZ+6wT9Uo9h2ApVsao3KIlz2DATjKfpLsBzTN3SE2R1mqzRzjx59fF6W
# 1j0ZsJfqjFCRba9Xhn4QNx1rGhTfAgMBAAGjggEpMIIBJTAOBgNVHQ8BAf8EBAMC
# AYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU6hbGaefjy1dFOTOk8EC+
# 0MO9ZZYwHwYDVR0jBBgwFoAUrmwFo5MT4qLn4tcc1sfwf8hnU6AwPgYIKwYBBQUH
# AQEEMjAwMC4GCCsGAQUFBzABhiJodHRwOi8vb2NzcDIuZ2xvYmFsc2lnbi5jb20v
# cm9vdHI2MDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5j
# b20vcm9vdC1yNi5jcmwwRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUHAgEW
# Jmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMA0GCSqGSIb3
# DQEBDAUAA4ICAQB/4ojZV2crQl+BpwkLusS7KBhW1ky/2xsHcMb7CwmtADpgMx85
# xhZrGUBJJQge5Jv31qQNjx6W8oaiF95Bv0/hvKvN7sAjjMaF/ksVJPkYROwfwqSs
# 0LLP7MJWZR29f/begsi3n2HTtUZImJcCZ3oWlUrbYsbQswLMNEhFVd3s6UqfXhTt
# chBxdnDSD5bz6jdXlJEYr9yNmTgZWMKpoX6ibhUm6rT5fyrn50hkaS/SmqFy9vck
# S3RafXKGNbMCVx+LnPy7rEze+t5TTIP9ErG2SVVPdZ2sb0rILmq5yojDEjBOsghz
# n16h1pnO6X1LlizMFmsYzeRZN4YJLOJF1rLNboJ1pdqNHrdbL4guPX3x8pEwBZzO
# e3ygxayvUQbwEccdMMVRVmDofJU9IuPVCiRTJ5eA+kiJJyx54jzlmx7jqoSCiT7A
# SvUh/mIQ7R0w/PbM6kgnfIt1Qn9ry/Ola5UfBFg0ContglDk0Xuoyea+SKorVdmN
# tyUgDhtRoNRjqoPqbHJhSsn6Q8TGV8Wdtjywi7C5HDHvve8U2BRAbCAdwi3oC8aN
# bYy2ce1SIf4+9p+fORqurNIveiCx9KyqHeItFJ36lmodxjzK89kcv1NNpEdZfJXE
# Q0H5JeIsEH6B+Q2Up33ytQn12GByQFCVINRDRL76oJXnIFm2eMakaqoimzCCBYMw
# ggNroAMCAQICDkXmuwODM8OFZUjm/0VRMA0GCSqGSIb3DQEBDAUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFI2MRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTE0MTIxMDAwMDAwMFoXDTM0MTIxMDAw
# MDAwMFowTDEgMB4GA1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNV
# BAoTCkdsb2JhbFNpZ24xEzARBgNVBAMTCkdsb2JhbFNpZ24wggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQCVB+hzymb57BTKezz3DQjxtEULLIK0SMbrWzyu
# g7hBkjMUpG9/6SrMxrCIa8W2idHGsv8UzlEUIexK3RtaxtaH7k06FQbtZGYLkoDK
# RN5zlE7zp4l/T3hjCMgSUG1CZi9NuXkoTVIaihqAtxmBDn7EirxkTCEcQ2jXPTyK
# xbJm1ZCatzEGxb7ibTIGph75ueuqo7i/voJjUNDwGInf5A959eqiHyrScC5757yT
# u21T4kh8jBAHOP9msndhfuDqjDyqtKT285VKEgdt/Yyyic/QoGF3yFh0sNQjOvdd
# Osqi250J3l1ELZDxgc1Xkvp+vFAEYzTfa5MYvms2sjnkrCQ2t/DvthwTV5O23rL4
# 4oW3c6K4NapF8uCdNqFvVIrxclZuLojFUUJEFZTuo8U4lptOTloLR/MGNkl3MLxx
# N+Wm7CEIdfzmYRY/d9XZkZeECmzUAk10wBTt/Tn7g/JeFKEEsAvp/u6P4W4Lsgiz
# YWYJarEGOmWWWcDwNf3J2iiNGhGHcIEKqJp1HZ46hgUAntuA1iX53AWeJ1lMdjlb
# 6vmlodiDD9H/3zAR+YXPM0j1ym1kFCx6WE/TSwhJxZVkGmMOeT31s4zKWK2cQkV5
# bg6HGVxUsWW2v4yb3BPpDW+4LtxnbsmLEbWEFIoAGXCDeZGXkdQaJ783HjIH2BRj
# PChMrwIDAQABo2MwYTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAd
# BgNVHQ4EFgQUrmwFo5MT4qLn4tcc1sfwf8hnU6AwHwYDVR0jBBgwFoAUrmwFo5MT
# 4qLn4tcc1sfwf8hnU6AwDQYJKoZIhvcNAQEMBQADggIBAIMl7ejR/ZVSzZ7ABKCR
# aeZc0ITe3K2iT+hHeNZlmKlbqDyHfAKK0W63FnPmX8BUmNV0vsHN4hGRrSMYPd3h
# ckSWtJVewHuOmXgWQxNWV7Oiszu1d9xAcqyj65s1PrEIIaHnxEM3eTK+teecLEy8
# QymZjjDTrCHg4x362AczdlQAIiq5TSAucGja5VP8g1zTnfL/RAxEZvLS471GABpt
# ArolXY2hMVHdVEYcTduZlu8aHARcphXveOB5/l3bPqpMVf2aFalv4ab733Aw6cPu
# QkbtwpMFifp9Y3s/0HGBfADomK4OeDTDJfuvCp8ga907E48SjOJBGkh6c6B3ace2
# XH+CyB7+WBsoK6hsrV5twAXSe7frgP4lN/4Cm2isQl3D7vXM3PBQddI2aZzmewTf
# bgZptt4KCUhZh+t7FGB6ZKppQ++Rx0zsGN1s71MtjJnhXvJyPs9UyL1n7KQPTEX/
# 07kwIwdMjxC/hpbZmVq0mVccpMy7FYlTuiwFD+TEnhmxGDTVTJ267fcfrySVBHio
# A7vugeXaX3yLSqGQdCWnsz5LyCxWvcfI7zjiXJLwefechLp0LWEBIH5+0fJPB1lf
# iy1DUutGDJTh9WZHeXfVVFsfrSQ3y0VaTqBESMjYsJnFFYQJ9tZJScBluOYacW6g
# qPGC6EU+bNYC1wpngwVayaQQMYIDSTCCA0UCAQEwbzBbMQswCQYDVQQGEwJCRTEZ
# MBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBU
# aW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNAIQARl1dHHJktdE36WW67lwFTAL
# BglghkgBZQMEAgGgggEtMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDArBgkq
# hkiG9w0BCTQxHjAcMAsGCWCGSAFlAwQCAaENBgkqhkiG9w0BAQsFADAvBgkqhkiG
# 9w0BCQQxIgQg5jWz0VYWuWt6KhXCjIKOI5MTSjerNbgYJWgBuvo1uNYwgbAGCyqG
# SIb3DQEJEAIvMYGgMIGdMIGaMIGXBCALeaI5rkIQje9Ws1QFv4/NjlmnS4Tu4t7D
# 2XHB6hc07DBzMF+kXTBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2ln
# biBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBT
# SEEzODQgLSBHNAIQARl1dHHJktdE36WW67lwFTANBgkqhkiG9w0BAQsFAASCAYAT
# rBhvvY+7giVBg8eM+v3dBJe1rQ/Y3NhA6FESTNzSCPfh8W+CEAEKT+TYy4E2qdGF
# doFMIDWXCehLDGvXcTev9bWDrUm2wIplCWuHZEEt6Nl/qp/pjJLLKTlQTVYc8kpG
# HdwCLyoIvoG7iEQ9Ok2SZ8FyYahmgbD+iAl9++RgFFuO8pbdkPjFM1XagAf1EeoR
# /W1FBBxCpkTZR4WUmf1ZiCvTTrtRF26hk0LAFt6itQxfzmPzjwoMAPZd9vTwnAYI
# j8ACsQj+NHnTd6nrHHGZNZO3vKCC06urC5plLSWwN+mG7qDShfhd5UtqJdOMqudt
# YPqSKCSsQINYCxuKg7moamXn0Hib7QqPc0ovqyl8bEmEH0aaVIt0OzPUWWuLTSKE
# 4F0AroVF1bw1d0pc9G6ofzCQwMaQ/DhFPjPqhQ+5VLl1PZfRmEr9T247V2Iq11+u
# p4XX6MlmZghKZNQlG+sfWWhbB0INsBVUh17vuWuQ3UUDVpKNbgKG8T8itFOy1IM=
# SIG # End signature block
