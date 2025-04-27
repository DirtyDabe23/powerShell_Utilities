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

Connect-MGGraph -AccessToken $token


#Jira API
$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)

#Set the Header
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}


#Connecting to Jira and pulling ticketing information into variables
$TicketNum = Read-Host -Prompt "Enter the Ticket Number (Ex: GHD-2157)"
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $headers
$NewForm = ConvertTo-Json $Form
$NewForm2 = ConvertFrom-Json $NewForm
$uData = $NewForm2.fields

$uToMod = $udata.customfield_10781

$firstName = $udata.customfield_10722
Write-Host $firstName
$lastName = $udata.customfield_10723
Write-Host $lastName
$supervisor = $udata.customfield_10765.emailAddress
Write-Host $supervisor
$newTitle = $udata.customfield_10695
Write-Host $newTitle
$department = $udata.customfield_10697.value
Write-Host $department
$location = $udata.customfield_10693.value
Write-Host $location
$phoneNumber = $udata.customfield_10726
Write-Host $phoneNumber
$persEmail = $udata.customfield_10727
Write-Host $persEmail `n`n`n`n`n`n


$jbody = $null
#FirstName Modification
If ($firstName -eq $null)
{
$firstnamelog = "No first name to mod for $($uToMod.displayName)\n"
Write-Host $firstnamelog
$jbody += $firstnamelog
}

Else
{
    $firstnamelog = "Setting new first name for $($uToMod.displayName)\n"
    Write-Host  $firstnamelog
    Update-MgUser -UserId $uToMod.emailAddress -GivenName $firstName
    $jbody += $firstnamelog
 }

#LastName Modification
If ($lastName -eq $null)
{
$lastnamelog = "No last name to mod for $($uToMod.displayName)\n"
Write-Host  $lastnamelog
$jbody += $lastnamelog
}

Else
{
    $lastnamelog = "Setting new last name for $($uToMod.displayName)\n" 
    Write-Host $lastnamelog
    Update-MgUser -UserId $uToMod.emailAddress -Surname $lastName
    $jbody += $lastnamelog
 }


#Title Modification
 If ($newTitle -eq $null)
{
$titlelog = "No title to mod for $($uToMod.displayName)\n"
Write-Host $titlelog
$jbody += $titlelog
}

Else
{
    $titlelog = "Setting new title for $($uToMod.displayName)\n"
    Write-Host $titlelog
    Update-MgUser -UserId $uToMod.emailAddress -JobTitle $newTitle
    $jbody += $titlelog
 }

#Department Modification
 If ($department -eq $null)
{
$deptlog = "No department to mod for $($uToMod.displayName)\n"
Write-Host $deptlog
$jbody += $deptlog
}

Else
{
    $deptlog = "Setting new department for $($uToMod.displayName)\n"
    Write-Host  $deptlog
    Update-MgUser -UserId $uToMod.emailAddress -Department $department
    $jbody += $deptlog
 }


#Department Modification
 If ($location -eq $null)
{
$loclog = "No location to mod for $($uToMod.displayName)\n"
Write-Host $loclog
$jbody += $loclog
}

Else
{
    $loclog = "Setting new location for $($uToMod.displayName)\n" 
    Write-Host $loclog
    Update-MgUser -UserId $uToMod.emailAddress -OfficeLocation $location
    $jbody += $loclog
 }


#Mobile Phone Modification
 If ($phoneNumber -eq $null)
{
$phoneLog = "No phone number to mod for $($uToMod.displayName)\n"
Write-Host $phoneLog
$jbody += $phoneLog
}

Else
{
    $phoneLog = "Setting new phone number for $($uToMod.displayName)\n"
    Write-Host  $phonelog
    Update-MgUser -UserId $uToMod.emailAddress -MobilePhone $phoneNumber
    $jbody += $phoneLog
 }




#PersonalEmail Modification
 If ($persEmail -eq $null)
{
$emailLog = "No personal email to mod for $($uToMod.displayName)\n"
Write-Host $emailLog
$jbody += $emailLog
}

Else
{
    $emailLog = "Setting new personal email address for $($uToMod.displayName)\n"
    Write-Host $emailLog
    Update-MgUser -UserId $uToMod.emailAddress -OtherMails $persEmail
    $jbody += $emailLog
 }



#Manager
 If ($supervisor -eq $null)
{
$superlog = "No supervisor to mod for $($uToMod.displayName)\n"
Write-Host $superlog
$jbody += $superlog
}

Else
{
     $superlog = "Setting new supervisor for $($uToMod.displayName)\n"
    Write-Host  $superlog
    $managerID = (Get-MGUser -UserID $supervisor).ID
     Set-MgUserManagerByRef -UserId $uToMod.emailAddress `
                -AdditionalProperties @{
                     "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
                }
    $jbody += $superlog

    
 }



 $jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "testing"
                    }
                }
            ]
        },
    "transition": {
        "id": "951"
    }
}
"@ 


Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/3/issue/$TicketNum/transitions" -Method Post -Body $jsonPayload -Headers $headers
# SIG # Begin signature block#Script Signature# SIG # End signature block








