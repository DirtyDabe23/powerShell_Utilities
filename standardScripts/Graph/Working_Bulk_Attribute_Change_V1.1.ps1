$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}



$pendingRequests = Invoke-RestMethod -Method get -uri 'https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=summary%20~%20"Employee%20Change"' -Headers $headers
foreach ($ticket in $pendingRequests.issues)
    {
        
        
        if ($ticket.fields.status.name -ne "Ready for Automation")
        {
            $null
        
        }
     
     
        else 
        {
            $erroronMod = $null
            #Connect to MS Graph
            
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

            #Connect to Graph 
            Connect-MGGraph -AccessToken $token    
     
     
     
     
            #Jira Connection and Form Ingestion
            write-host $ticket.key
            $key = $ticket.key 
            $Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key" -Headers $headers
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


            #FirstName Modification
            If ($firstName -eq $null)
            {
            Write-Host "No first name to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new first name for $($uToMod.displayName)" 
                Update-MgUser -UserId $uToMod.emailAddress -GivenName $firstName
             }

            #LastName Modification
            If ($lastName -eq $null)
            {
            Write-Host "No last name to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new last name for $($uToMod.displayName)" 
                Update-MgUser -UserId $uToMod.emailAddress -Surname $lastName
             }


            #Title Modification
             If ($newTitle -eq $null)
            {
            Write-Host "No title to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new title for $($uToMod.displayName)" 
                Update-MgUser -UserId $uToMod.emailAddress -JobTitle $newTitle
             }

            #Department Modification
             If ($department -eq $null)
            {
            Write-Host "No department to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new department for $($uToMod.displayName)" 
                Update-MgUser -UserId $uToMod.emailAddress -Department $department
             }


            #Department Modification
             If ($location -eq $null)
            {
            Write-Host "No location to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new location for $($uToMod.displayName)" 
                Update-MgUser -UserId $uToMod.emailAddress -OfficeLocation $location
             }


            #Mobile Phone Modification
             If ($phoneNumber -eq $null)
            {
            Write-Host "No phone number to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new phone number for $($uToMod.displayName)"
                try
                {
                 
                    Update-MgUser -UserId $uToMod.emailAddress -MobilePhone $phoneNumber -erroraction stop
                }
                catch
                {
                    Write-Host "An error occured setting new phone number for $($uToMod.displayName)"
                    $erroronMod = $true 
                }

             }




            #PersonalEmail Modification
             If ($persEmail -eq $null)
            {
            Write-Host "No last name to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new personal email address for $($uToMod.displayName)"
                try
                { 
                    Update-MgUser -UserId $uToMod.emailAddress -OtherMails $persEmail -erroraction stop
                }
                Catch
                {
                    Write-Host "An error occured setting new personal email address for $($uToMod.displayName)"
                    $erroronMod = $true 
                }
            }



            #Manager
             If ($supervisor -eq $null)
            {
            Write-Host "No supervisor to mod for $($uToMod.displayName)"
            }

            Else
            {
                Write-Host "Setting new supervisor for $($uToMod.displayName)"
                $managerID = (Get-MGUser -UserID $supervisor).ID
                 Set-MgUserManagerByRef -UserId $uToMod.emailAddress `
                            -AdditionalProperties @{
                                 "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
                            }


    
             }

If ($erroronMod = $null)
{
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Resolved via automated process."
                    }
                }
            ]
        },
    "transition": {
        "id": "961"
    }
}
"@ 
}

If ($erroronMod = $true)
{
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "There were errors modifying this user. Please perform the edits manually."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
}


            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            Disconnect-MgGraph

}

     }
     
     
     
     
     
    
# SIG # Begin signature block#Script Signature# SIG # End signature block








