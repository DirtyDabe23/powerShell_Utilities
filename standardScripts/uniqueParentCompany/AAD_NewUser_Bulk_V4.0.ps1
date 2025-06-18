#The section below is for API Authentication into the uniqueParentCompany Jira Tenant 
$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}



#How to get all new user onboarding requests, this returns only issues with the summary of 'Onboard Request'
$pendingRequests = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassian.net/rest/api/2/search?jql=project%20%3D%20GHD%20AND%20summary%20~%20%22Onboard%20Request%22%20AND%20status%20%3D%20%22Ready%20For%20Automation%22" -Headers $headers

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

            #connect to Exchange Online
            $exoCertThumb = "5A72B9E49079A6999A440A5438D2CBBABC482DDA"
            $exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
            $exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
            Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

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
            Connect-MGGraph -AccessToken $secureToken
            
            #The section below pulls all of the Jira fields into a variable, converting to and from JSON 
            write-host $ticket.key
            $key = $ticket.key 
            $Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key" -Headers $headers
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
            $credFile = $userLocation.credFile 
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
            Write-Host "Location hired is: $locationHired"
            Write-Host "Department is: $DepartmentString"
            Write-Host "Work Location is: $workLoc"
            Write-Host "Country is: $country"
            Write-Host "Usage Location is $usageLoc"
            Write-Host "UPN Suffix is: $upnSuffix"
            Write-Host "Business phone is: $businessPhone"
            Write-Host "Group 1 is: $group1"
            Write-Host "Group 2 is: $group2"
            Write-Host "Group 3 is: $group3"
            Write-Host "License 1 is: $license1"
            Write-Host "License 2 is: $license2"



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
                    Write-Host "First Name is: $firstName"
	                Write-Host "This has a space"
                    $firstName = $firstName.split(" ")
                    Write-Host "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+" "+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Host "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Host "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.Replace(" ","").Trim()
                    Write-Host "First Name for UPN is $firstNameUPN"
	            }
		
		
            ElseIf($firstName -match "-")
                {
	                Write-Host "This is hyphenated"
                    $firstName = $firstName.split("-")
                    Write-Host "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+"-"+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Host "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Host "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.trim()
                    Write-Host "Last Name for UPN is $firstNameUPN"
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
                    Write-Host "Last Name is: $lastName"
	                Write-Host "This has a space"
                    $lastName = $lastName.split(" ")
                    Write-Host "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+" "+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Host "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Host "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    Write-Host "Last Name for UPN is $lastNameUPN"
	            }
		
		
            ElseIf($lastName -match "-")
                {
	                Write-Host "This is hyphenated"
                    $lastName = $lastName.split("-")
                    Write-Host "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+"-"+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Host "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Host "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.trim()
                    Write-Host "Last Name for UPN is $lastNameUPN"
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
    Write-Host "Default Email Address Notation is in use. Email in use is $emailAddr"

    #if the middle initial field is NOT null
   if (!($udata.customfield_10724 -eq $null))
   {
   #Pull the middle initial from the Jira field
   $middleInitial = $udata.customfield_10724
   
   #Generate a new UPN
   $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN + $upnSuffix
   
   #if their newly generated UPN is taken, it is detected here
   If (Get-MGUser -UserId $emailaddr -erroraction SilentlyContinue)
    {
        Write-Host "First, Middle, Last Address Notation is in use. Email in use is $emailAddr"
        #determine if they have a suffix filled out from Jira 
        if (!($udata.customfield_10725 -eq $null))
        {
        #If the suffix is not null, and the username is not taken, bind it here.
        $nameSuffix = $udata.customfield_10725
        #Create another New UPN 
        $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN +$nameSuffix+ $upnSuffix

        #if the Username of FirstName.MiddleInitial.LastNameUPN.NameSuffix@domainsuffix.com is taken, give up, and update the Jira ticket to 'Needs Done manually' 
        If (Get-MGUser -UserId $emailaddr -erroraction SilentlyContinue)
            {
             Write-Host "First, Middle, Last Address Suffix Notation is in use. Email in use is $emailAddr"
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
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
    Write-Host "Default Email Address Notation is in use. Email in use is $emailAddr"

    #if the middle initial field is NOT null
   if (!($udata.customfield_10724 -eq $null))
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
        Write-Host "First, Middle, Last Address Notation is in use. Email in use is $emailAddr"
        #determine if they have a suffix filled out from Jira 
        if (!($udata.customfield_10725 -eq $null))
        {
        #If the suffix is not null, and the username is not taken, bind it here.
        $nameSuffix = $udata.customfield_10725
        #Create another New UPN 
        $emailAddr = $firstNameUPN + "."+$middleInitial+"."+$lastNameUPN +$nameSuffix+ $upnSuffix

        #if the Username of FirstName.MiddleInitial.LastNameUPN.NameSuffix@domainsuffix.com is taken, give up, and update the Jira ticket to 'Needs Done manually' 
        If (Get-ADUser -Server $newUserServer -Filter "UserPrincipalName -eq '$($emailaddr)'" -erroraction SilentlyContinue)
            {
             Write-Host "First, Middle, Last Address Suffix Notation is in use. Email in use is $emailAddr"
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
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue  
        }

    }


   }         
            
            

}

Write-Host "Creating $emailAddr on Local AD"
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
            -SamAccountName $acctSAMName 

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
        Write-Host "User does not exist in AD yet. Waiting 10 seconds"
        Start-Sleep -Seconds 10
    }
    Else
    {
        Write-Host "User has been created. Moving to setting properties on prem"
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
        Write-Host "User does not exist in AAD yet. Waiting 10 seconds"
        Start-Sleep -Seconds 10
    }
    Else
    {
        Write-Host "User has been created. Moving to setting properties that are Graph Only after a final minute delay to ensure account is addressable"
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
Write-Host "Creating $emailAddr on MG Graph"
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
            Write-Host "Waiting 1 minute at $time to allow for license assignment and group creation"
            Start-Sleep -Seconds 60


            #Pull the Manager ID user information to bind to the new user
            $tempVar = $uData.customfield_10765
            $managerID = (Get-MGUser -Search "UserPrincipalName:$($tempvar.emailAddress)" -ConsistencyLevel:eventual -top 1).ID 

            if ($managerID -eq $null)
            {
            Write-Host "Unable to find the manager via UPN, checking via Display Name"
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
                if ($license1 -eq "" -or $license1 -eq $null) 
                {
                    Write-Host "Null"
                } 
                else 
                {
                    $sku1 = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $license1
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
                    Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
                    continue
	                }
                    Else
                    {

                            Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()
                    }


                }


                if ($license2 -eq "" -or $license2 -eq $null) 
                {
                    Write-Host "Null"
                } 
                else 
                {
                    $sku1 = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $license2
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
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
	        }
            Else
            {

                    Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()
            }


            }
                if ($usageLoc -in "IT","CA","BE","AU","DE","DK","VN","AE","MY","GB","ZA")
                {
                $sku3 = Get-MgSubscribedSku -All |  Where SkuPartNumber -eq 'OFFICE365_MULTIGEO'
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
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
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
                        Write-Host "Mailbox does not exist yet. Waiting 10 seconds"
                        Start-Sleep -Seconds 10
                    }
                Else
                    {
                        Write-Host "Mailbox has been created. Moving onto Group Assignment."
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
                if ($group1 -eq "" -or $group1 -eq $null) 
                {
                    Write-Host "Null"
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
                        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $group1 -member $emailAddr -BypassSecurityGroupManagerCheck -erroraction stop
                            }
                        catch
                            {
                            Write-Host "Unable to add $emailAddr to "$group1 ". Please do this manually."
                            }
                        }
                }

            #Group2

                    if ($group2 -eq "" -or $group2 -eq $null) 
                {
                    Write-Host "Null"
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
                        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $group2 -member $emailAddr -BypassSecurityGroupManagerCheck -erroraction stop
                            }
                        catch
                            {
                            Write-Host "Unable to add $emailAddr to "$group2 ". Please do this manually."
                            }
                }
                }

            #Group3    
                    if ($group3 -eq "" -or $group3 -eq $null) 
                {
                    Write-Host "$Null"
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
                        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $group3 -member $emailAddr -BypassSecurityGroupManagerCheck -erroraction stop
                            }
                        catch
                            {
                            Write-Host "Unable to add $emailAddr to "$group3 ". Please do this manually."
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
            Write-Host "Unable to add $emailAddr to "$gname ". Please do this manually."
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
            Write-Host "Unable to add $emailAddr to "$gname ". Please do this manually."
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
            Write-Host "Unable to add $emailAddr to "$gname ". Please do this manually."
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



            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
        
        }   

    }
    
# SIG # Begin signature block#Script Signature# SIG # End signature block











