param(
        [Parameter (Position = 0, HelpMessage = "Enter the Jira Key, Example: GHD-44619")]
        [string]$Key
)
function Set-PrivateErrorJiraRunbook{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [switch]$Continue
    )
    $currTime = Get-Date -format "HH:mm"
    $errorLog = [PSCustomObject]@{
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] | Select-Object * #gets the most recent error
    }

        
    # Initialize an array to store formatted content
    $jbody = @()

    # Loop through each errorLog item and format it as a JSON paragraph

        $paragraphs = @(
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Time Failed: $($errorLog.timeToFail)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Reason Failed: $($errorLog.reasonFailed)"
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
                    internal = $true
                }
            }
        )
    }
    # Convert the PowerShell object to a JSON string
    $jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10
    # Perform the API call
    try {
        $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $jiraHeader
        if ($response){
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Internal Comment Successfully Made with Error Details"
        }
    } catch {
        Write-Output "API call failed: $($_.Exception.Message)"
        Write-Output "Payload: $jsonPayload"
    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    switch ($Continue){
        $False {exit 1}
        Default {$null}
    }
}

function Set-SuccessfulComment{
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Full', Position = 0)]
        [switch]$Continue
    )
    $jsonPayload = @"
{
"update": {
        "comment": [
            {
                "add": {
                    "body": "Successfully Created: $invitedUserDisplayName / $invitedUserEmail and added to $groupName"
                }
            }
        ]
    }
}
"@
try {
    Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key" -Method Put -Body $jsonPayload -Headers $jiraHeader -erroraction Stop | Out-Null
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Internal Comment Successfully Made with Error Details"
    }
 catch {
    Write-Output "API call failed: $($_.Exception.Message)"
    Write-Output "Payload: $jsonPayload"
}
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
Write-Output $errorLog
switch ($Continue){
    $False {exit 1}
    Default {Continue}
}
}
function Set-PublicErrorJira{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    [switch]$Continue
    ) 
    $jsonPayload = @"
    {
    "update": {
        "comment": [
            {
                "add": {
                    "body": "Automation Failed. GIT will review Internal Logs and report back"
                }
            }
        ]
    },
    "transition": {
    "id": "981"
    }
}
"@
        Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $jiraHeader
        
    switch ($Continue){
    $False {$null}
    Default {Continue}
    }
}

Import-module Az.Accounts
Import-Module Az.KeyVault
Import-Module Microsoft.Graph.Users

#onPremConnection and Data Review
try {
    # Read from Azure Key Vault using managed identity
    connect-azaccount -subscription $subscriptionID -Identity | out-null
    
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
    $error.clear()
    #Connect to: Graph / Via: Secret
    #The Tenant ID from App Registrations
    $graphTenantId = $tenantIDString

    # Construct the authentication URL
    $graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
    
    #The Client ID from App Registrations
    $graphAppClientId = $appIDString
    
    $graphRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText
    
    # Construct the body to be used in Invoke-WebRequest
    $graphAuthBody = @{
        client_id     = $graphAppClientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret =  $graphRetrSecret
        grant_type    = "client_credentials"
    }
    
    
# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
Write-Output "Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop
Write-Output "Successfully Connected, Pulling all users"
$allUsers = Get-MgBetaUser -all -consistencylevel eventual -Property *
$goodUsers       =  [Collections.Generic.List[object]]::new()
$badUsers        =  [Collections.Generic.List[object]]::new()
$groupNames        =  [Collections.Generic.List[object]]::new()
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
#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$TicketNum = $Key
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $jiraHeader

$partnereduniqueParentCompanyLocation =  $form.fields.customfield_10820.value
$invitedUserCompanyName =   $form.fields.customfield_10952
$inviteDirectURI =          $form.fields.customfield_10953



$attachment = $form.Fields.Attachment | Where-Object {($_.FileName -like "*External*")}
if ($attachment) {
    $attachmentContent = Invoke-RestMethod -Uri $attachment[0].content -Method Get -Headers $jiraHeader
    $csv = $attachmentContent | ConvertFrom-CSV
    ForEach ($user in $csv){
        $user | Select-Object -Property *
        $groupName = $partnereduniqueParentCompanyLocation , ": UC - Vendor - " , $invitedUserCompanyName, " ", $user.accessLevel -join ""
        If (!(Get-MgGroup -Filter "DisplayName eq  '$groupName'")){
            if ($groupName -notin $groupNames){
                $groupNames.Add($groupName)
            }
            $FormattedCompanyName = $($invitedUserCompanyName).replace(",","").replace(" ","").replace(".","")
            $formatteduniqueParentCompanyLocation = $($partnereduniqueParentCompanyLocation).replace(",","").replace(" ","").replace(".","")
            $groupMailNickName = $formatteduniqueParentCompanyLocation , $FormattedCompanyName , $user.accessLevel -join ""
            #Request a Token for the Graph API Pushes
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
            # Extract the Access Token
            $baseToken = ($tokenRequest.content | convertfrom-json).access_token
            
            $graphAPIHeader = @{
                "Authorization" = "Bearer $baseToken"
                "Content-Type" = "application/JSON"
                grant_type    = "client_credentials"
            }
            #Building the URI for the user update
            $baseGraphAPI = "https://graph.microsoft.com/"
            $APIVersion = "v1.0/"
            $endPoint = "groups"
            
            $groupGraphAPI = $baseGraphAPI , $APIVersion , $endpoint -join ""
            $groupParams = @{
                DisplayName = $groupName
                MailEnabled = $false
                GroupTypes = @('Unified')
                resourceBehaviorOptions = @('WelcomeEmailDisabled')
                MailNickname = $groupMailNickName
                SecurityEnabled = $true
            }
            $graphNewGroupJSONBody = $groupParams | ConvertTo-JSON -Depth 3
            #creates the Group
            $createdGroup = Invoke-RestMethod -uri $groupGraphAPI -Method Post -Body $graphNewGroupJSONBody -Headers $graphAPIHeader -Verbose -Debug
            $groupID = $createdGroup.ID 
        }
        else{
            $createdGroup = Get-MgGroup -Filter "DisplayName eq  '$groupName'"
            $groupID = $createdGroup.ID 
        }
        
         #Checking to see if the user exists as a contact.
         $existingEmailCheck = $user.invitedUserEmail
         $existingUser = $allUSers | Where-Object {($_.OtherMails -like "*$existingEmailCheck*")}
 
         if (!($existingUser)){
             $existingContact = Get-MgUser -filter "mail eq '$existingEmailCheck'" -erroraction SilentlyContinue
             #If the user does not exist as a guest user, create them here
             If(!($existingContact)){
                $invitedUserDisplayName = $user.invitedUserName , $invitedUserCompanyName -join " - "
                $invitedUserJobTitle = "Rep - " , $user.invitedUserTitle -join ""
                Write-output "$existingEmailCheck is the external email of the user to invite"
                
                
                $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
                # Extract the Access Token
                $baseToken = ($tokenRequest.content | convertfrom-json).access_token
                
                $graphAPIHeader = @{
                    "Authorization" = "Bearer $baseToken"
                    "Content-Type" = "application/JSON"
                    grant_type    = "client_credentials"
                }
                #Building the URI for the user update
                $baseGraphAPI = "https://graph.microsoft.com/"
                $APIVersion = "v1.0/"
                $endPoint = "invitations"
                
                $graphGuestUserURI = $baseGraphAPI , $APIVersion , $endpoint -join ""
                $guestUserParams = @{
                    InvitedUserDisplayName = $InvitedUserDisplayName
                    InvitedUserEmailAddress = $existingEmailCheck
                    inviteRedirectUrl = $inviteDirectURI
                }
                $newGuestUserJSONBody = $guestUserParams | ConvertTo-JSON -Depth 3
                #Creates the Guest User
                $userinvited = Invoke-RestMethod -uri $graphGuestUserURI -Method Post -Body $newGuestUserJSONBody -Headers $graphAPIHeader -Verbose -Debug
                $invitedUserEmail = $userinvited.InvitedUserEmailAddress
                $userGraphID = $userInvited.invitedUser.ID
             }
             else{
                 Write-Output "$($user.invitedUserName) already exists as a mail contact!"
                 $invitedUserEmail = $user.invitedUserEmail
                 $invitedUserJobTitle = "Rep - " , $user.invitedUserTitle -join ""
             }
             
 
             
             $mgUserDetector = 0
             while ($mgUserDetector -le 1)
             {
                 If (!(Get-MgUser -filter "mail eq '$invitedUserEmail'" -erroraction SilentlyContinue)){
                 Write-Output "$invitedUserDisplayName does not exist in MGGraph yet. Waiting 10 seconds"
                 Start-Sleep -Seconds 10
                 }
                 Else{
                 $userGraph = Get-MgUser -filter "mail eq '$invitedUserEmail'"
                 $userGraphID = $userGraph.ID
                 $mgUserDetector = 10
                 }
             }
         }
         #if the user already exists
         else{
             $userGraphID = $existingUser.ID
             $invitedUserDisplayName = $user.invitedUserName , $invitedUserCompanyName -join " - "
             $invitedUserJobTitle = "Rep - " , $user.invitedUserTitle -join ""
             $invitedUserEmail = $user.invitedUserEmail
             $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
             # Extract the Access Token
             $baseToken = ($tokenRequest.content | convertfrom-json).access_token
             
             $graphAPIHeader = @{
                 "Authorization" = "Bearer $baseToken"
                 "Content-Type" = "application/JSON"
             }
             #Building the URI for the user update
             $baseGraphAPI = "https://graph.microsoft.com/"
             $APIVersion = "v1.0/"
             $endPoint = "users/"
             
             $graphGuestUserURI = $baseGraphAPI , $APIVersion , $endpoint ,$userGraphID -join ""
             $guestUserParams = @{
                 JobTitle = $invitedUserJobTitle
                 OfficeLocation = $invitedUserCompanyName
                 DisplayName = $invitedUserDisplayName
             }
             $updateGuestUserJSONBody = $guestUserParams | ConvertTo-JSON -Depth 3
             #Updates User Properties
             $response = Invoke-RestMethod -uri $graphGuestUserURI -Method Patch -Body $updateGuestUserJSONBody -Headers $graphAPIHeader -Verbose -Debug
             Write-Output $response
         }
 
         Try{
            #User Property Updates
             $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
             # Extract the Access Token
             $baseToken = ($tokenRequest.content | convertfrom-json).access_token
             
             $graphAPIHeader = @{
                 "Authorization" = "Bearer $baseToken"
                 "Content-Type" = "application/JSON"
             }
             #Building the URI for the user update
             $baseGraphAPI = "https://graph.microsoft.com/"
             $APIVersion = "v1.0/"
             $endPoint = "users/"
             
             $graphGuestUserURI = $baseGraphAPI , $APIVersion , $endpoint ,$userGraphID -join ""
             $guestUserParams = @{
                 JobTitle = $invitedUserJobTitle
                 OfficeLocation = $invitedUserCompanyName
                 CompanyName = "Not Affiliated"
                 DisplayName = $invitedUserDisplayName
             }
             $updateGuestUserJSONBody = $guestUserParams | ConvertTo-JSON -Depth 3
             #Updates User Properties
             $response = Invoke-RestMethod -uri $graphGuestUserURI -Method Patch -Body $updateGuestUserJSONBody -Headers $graphAPIHeader -Verbose -Debug
             Write-Output $response
             
             Write-Output "Evaluating $groupName to determine if $invitedUserDisplayName needs to be added"
            $usersGroup = Get-MgGroup -Filter "DisplayName eq  '$groupName'"
            $GroupID = $usersGroup.Id
             if(Get-MgUserMEmberOf -UserId $userGraphID -DirectoryObjectId $groupID -ErrorAction SilentlyContinue){
                Write-Output "$invitedUserDisplayName is already a member of $($usersGroup.DisplayName)"
                }
            else{
                Write-Output "ADDING: $invitedUserDisplayName TO $($usersGroup.DisplayName)"
                New-MgGroupMember -GroupId $groupID -DirectoryObjectId $userGraphID
                 
                $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
                # Extract the Access Token
                $baseToken = ($tokenRequest.content | convertfrom-json).access_token
                
                $graphAPIHeader = @{
                    "Authorization" = "Bearer $baseToken"
                    "Content-Type" = "application/JSON"
                    grant_type    = "client_credentials"
                }
                #Building the URI for the user update
                $baseGraphAPI = "https://graph.microsoft.com/"
                $APIVersion = "v1.0/"
                $endPoint = "groups/"
                $memberEndpoint = '/members/$ref'
                
                $graphGuestUserGroupMembersURI = $baseGraphAPI , $APIVersion , $endpoint , $groupID , $memberEndpoint -join ""
                $groupMemberParams = @{
                   '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/" , $userGraphID -join ""
                }
                $groupMemberBodyJSON = $groupMemberParams | ConvertTo-JSON -Depth 3
                #Adds Group Members
                $response = Invoke-RestMethod -uri $graphGuestUserGroupMembersURI -Method Post -Body $groupMemberBodyJSON -Headers $graphAPIHeader -Verbose -Debug -ErrorAction Ignore
                Write-Output $response
            }
            Write-Output "$invitedUserDisplayName has been created as a guest user"
             $goodUsers.add($invitedUserEmail)
             
         }
         catch{
            $errorMessage = $_
            Write-Output $errorMessage
            $ErrorActionPreference = "Stop"  
            Write-Output "$invitedUserEmail failed!"
            $badUsers.Add($invitedUserEmail)
            Set-PrivateErrorJiraRunbook -Continue:$true
         }
        
         Set-SuccessfulComment -Continue:$true
        }
    
}
Else{
    Write-Output "The attachment failed to be read"
    Set-PublicErrorJira
}
# SIG # Begin signature block#Script Signature# SIG # End signature block











