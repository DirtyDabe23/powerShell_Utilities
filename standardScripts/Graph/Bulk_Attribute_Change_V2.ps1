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
            Connect-MGGraph -AccessToken $secureToken
     
     
     
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


            $params = @()
    #FirstName Modification
    If ($firstName -eq $null)
    {
    $firstnamelog = "No first name to mod for $($uToMod.displayName)"
    Write-Host $firstnamelog
    $params += $firstnamelog
    }

    Else
    {
        $firstnamelog = "Setting new first name for $($uToMod.displayName)"
        Write-Host  $firstnamelog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -GivenName $firstName
        $params += $firstnamelog
        }
        catch
        {
          $firstnamelog = "An error occured setting new first name for $($uToMod.displayName)"
          Write-Host $firstnamelog
          $erroronMod = $true
          $params += $firstnamelog
        }
     }

    #LastName Modification
    If ($lastName -eq $null)
    {
    $lastnamelog = "No last name to mod for $($uToMod.displayName)"
    Write-Host  $lastnamelog
    $params += $lastnamelog
    }

    Else
    {
        $lastnamelog = "Setting new last name for $($uToMod.displayName)" 
        Write-Host $lastnamelog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -Surname $lastName
        $params += $lastnamelog
        }
        catch
        {
          $lastnamelog= "An error occured setting new last name for $($uToMod.displayName)"
          Write-Host $lastnamelog
          $erroronMod = $true
          $params += $lastnamelog
        }
     }


    #Title Modification
     If ($newTitle -eq $null)
    {
    $titlelog = "No title to mod for $($uToMod.displayName)"
    Write-Host $titlelog
    $params += $titlelog
    }

    Else
    {
        $titlelog = "Setting new title for $($uToMod.displayName)"
        Write-Host $titlelog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -JobTitle $newTitle
        $params += $titlelog
        }
        catch
        {
          $titlelog= "An error occured setting new title for $($uToMod.displayName)"
          Write-Host $titlelog
          $erroronMod = $true
          $params += $titlelog
        }
     }

    #Department Modification
     If ($department -eq $null)
    {
    $deptlog = "No department to mod for $($uToMod.displayName)"
    Write-Host $deptlog
    $params += $deptlog
    }

    Else
    {
        $deptlog = "Setting new department for $($uToMod.displayName)"
        Write-Host  $deptlog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -Department $department
        $params += $deptlog
        }
        catch
      {
        $deptlog = "An error occured setting new department for $($uToMod.displayName)"
        Write-Host $deptlog
        $erroronMod = $true
        $params += $deptlog
      }
     }


    #Location Modification
     If ($location -eq $null)
    {
    $loclog = "No location to mod for $($uToMod.displayName)"
    Write-Host $loclog
    $params += $loclog
    }

    Else
    {
        $loclog = "Setting new location for $($uToMod.displayName)" 
        Write-Host $loclog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -OfficeLocation $location -erroraction stop
        $params += $loclog
        }
        catch
        {
        $loclog = "An error occured setting new location for $($uToMod.displayName)"
        Write-Host $loclog
        $erroronMod = $true 
        $params += $loclog
        }
     }


    #Mobile Phone Modification
     If ($phoneNumber -eq $null)
    {
    $phoneLog = "No phone number to mod for $($uToMod.displayName)"
    Write-Host $phoneLog
    $params += $phoneLog
    }

    Else
    {
        $phoneLog = "Setting new phone number for $($uToMod.displayName)"
        Write-Host  $phonelog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -MobilePhone $phoneNumber -erroraction stop
        $params += $phoneLog
        }
        catch
        {
        $phoneLog = "An error occured setting new phone number for $($uToMod.displayName)"
        Write-Host $phoneLog
        $erroronMod = $true 
        $params += $phoneLog
        }
     }




    #PersonalEmail Modification
     If ($persEmail -eq $null)
    {
    $emailLog = "No personal email to mod for $($uToMod.displayName)"
    Write-Host $emailLog
    $params += $emailLog
    }

    Else
    {
        $emailLog = "Setting new personal email address for $($uToMod.displayName)"
        Write-Host $emailLog
        try
        {
        Update-MgUser -UserId $uToMod.emailAddress -OtherMails $persEmail -erroraction stop
        $params += $emailLog
        }
        catch
        {
        $emailLog =  "An error occured setting new personal email address for $($uToMod.displayName)"
        Write-Host $emailLog
        $erroronMod = $true
        $params = $emailLog
        } 
    }
     



    #Manager
     If ($supervisor -eq $null)
    {
    $superlog = "No supervisor to mod for $($uToMod.displayName)"
    Write-Host $superlog
    $params += $superlog
    }

    Else
    {
         $superlog = "Setting new supervisor for $($uToMod.displayName)"
        Write-Host  $superlog
        $managerID = (Get-MGUser -UserID $supervisor).ID
         Set-MgUserManagerByRef -UserId $uToMod.emailAddress `
                    -AdditionalProperties @{
                         "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
                    }
        $params += $superlog

    
     }

    $jbody = $null

foreach ($line in $params) {
    $jbody += @"
    {
    "type": "paragraph",
    "content": [
        {
        "type": "text",
        "text": "$line"
        }
        ]
    },
"@
}


If ($erroronMod = $null)
{$transID = "961"}
Else{$transid = "981"}



$jbody = $jbody.TrimEnd(',')

$jsonPayload = @"
{
    "transition": {
      "id": "$transid"
    },
    "update": {
      "comment": [
        {
          "add": {
            "body": {
              "content": [
                $jbody    
              ],
              "type": "doc",
              "version": 1
            }
          }
        }
      ]
    }
  }
"@

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/3/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
Disconnect-MgGraph
     }
     
}
# SIG # Begin signature block#Script Signature# SIG # End signature block








