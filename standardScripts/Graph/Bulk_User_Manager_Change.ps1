$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}



#How to get all new user onboarding requests
$pendingRequests = Invoke-RestMethod -Method get -uri 'https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=summary%20~%20"Bulk%20Manager%20Change"' -Headers $headers


foreach ($ticket in $pendingRequests.issues)
    {
        
        if ($ticket.fields.status.name -ne "Ready for Automation")
        {
            $null
        }
        Else
        {
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
            
            write-host $ticket.key
            $key = $ticket.key 
            $Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key" -Headers $headers
            $NewForm = ConvertTo-Json $Form
            $NewForm2 = ConvertFrom-Json $NewForm
            $uData = $NewForm2.fields

            #Load the user information array into a variable.
            $users = $udata.customfield_10780

            #Get the Manager ID
            $tempVar = $uData.customfield_10765.displayName
            $managerID = (Get-MGUser -Search "DisplayName:$tempvar" -ConsistencyLevel:eventual -top 1).ID

            #set the counter to null
            $i = 0


            ForEach ($user in $users)
            {
                #Creates a temporary array, splitting everything after the email address
                $arr = $udata.customfield_10780[$i].Substring(137) -split ";"
                #Sets the email address to the first part of the array split above
                $userEmail = $arr[0]
                #General Write-Host message to indicate it's running.
                Write-Host "User to modify is:" $userEmail "Manager of user is:" $udata.customfield_10765.emailAddress
                #Sets the Manager
                Set-MgUserManagerByRef -UserId $userEmail `
                -AdditionalProperties @{
                     "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
                } #-WhatIf


                $i++

            }
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



            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers        
        
        }

    }
# SIG # Begin signature block#Script Signature# SIG # End signature block








