param(
    [string] $Key
)
function Set-PrivateErrorJira{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [switch]$Continue
    )
    $currTime = Get-Date -format "HH:mm"
    $errorLog = [PSCustomObject]@{
        processFailed                   = $procProcess
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] | Select-Object * #gets the most recent error
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

        
    # Initialize an array to store formatted content
    $jbody = @()

    # Loop through each errorLog item and format it as a JSON paragraph

        $paragraphs = @(
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Process Failed: $($errorLog.processFailed)"
                    }
                )
            },
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
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target Standard Name: $($errorLog.failedTargetStandardName)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target DNS Name: $($errorLog.failedTargetDNSName)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target User: $($errorLog.failedTargetUser)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target WorkGroup: $($errorLog.failedTargetWorkGroup)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target Domain: $($errorLog.failedTargetDomain)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target Memory: $($errorLog.failedTargetMemory) MB"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target Chassis: $($errorLog.failedTargetChassis)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target Manufacturer: $($errorLog.failedTargetManufacturer)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Failed Target Model: $($errorLog.failedTargetModel)"
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
function Set-SuccessfulComment {
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
                    "body": "Successfully Invited: $invitedUserDisplayName / $existingEmailCheck!"
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
#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText
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


$invitedUserCompanyName =   $form.fields.customfield_10952
$inviteDirectURI =          $form.fields.customfield_10953


$attachment = $form.Fields.Attachment | Where-Object {($_.FileName -like "*External*")}
if ($attachment) {
    $attachmentContent = Invoke-RestMethod -Uri $attachment[0].content -Method Get -Headers $jiraHeader
    $csv = $attachmentContent | ConvertFrom-CSV
    ForEAch ($user in $csv){
        try{
            $existingEmailCheck = $user.invitedUserEmail
            $existingContact = Get-MgUser -filter "mail eq '$existingEmailCheck'" -erroraction SilentlyContinue
            if (!($existingContact)){$existingContact = $allUSers | Where-Object {($_.OtherMails -like "*$existingEmailCheck*")}}
            $invitedUserDisplayName = $user.invitedUserName , $invitedUserCompanyName -join " - "
            Write-output "$existingEmailCheck is the user who will be receiving an email invite."
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
                SendInvitationMessage = $true
            }
            $newGuestUserJSONBody = $guestUserParams | ConvertTo-JSON -Depth 3
            #Creates the Guest User
            $userinvited = Invoke-RestMethod -uri $graphGuestUserURI -Method Post -Body $newGuestUserJSONBody -Headers $graphAPIHeader -Verbose -Debug
            $goodUsers.add($userinvited)
            Write-Output $userinvited
            Set-SuccessfulComment -continue:$true
        }
        catch{
            Write-Output "Failed to invite $existingEmailCheck"
            $badUsers.add($existingEmailCheck)
            Set-PrivateErrorJira -Continue:$true
        }

    }
}

Write-output "External Users Successfully Invited: $($goodUsers.Count)"
Write-output "External Users Failed Creation: $($badUsers.Count)"
Write-Output "The Failing Users were:`n$badUsers`n`n`n"
Write-Output "The Successfully Created Users were: `n$goodUsers"
Write-OUtput "Errors:`n$error"

# SIG # Begin signature block#Script Signature# SIG # End signature block













