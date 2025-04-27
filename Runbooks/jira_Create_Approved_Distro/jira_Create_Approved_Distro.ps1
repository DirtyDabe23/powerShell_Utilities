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
                    "body": "Resolved via automated process. The New Distribution Group Email Address is $finalizedGroupEmail"
                }
            }
        ]
    },
"transition": {
    "id": "961"
}
}
"@
try {
    $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $jiraHeader
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

try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "JiraAPI" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}

try{
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $managed_ID = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "ExOManagedIdent" -AsPlainText
    Connect-ExchangeOnline -ManagedIdentity -Organization uniqueParentCompanyinc.onmicrosoft.com -ManagedIdentityAccountID $managed_ID
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage
    $ErrorActionPreference = "Stop"
}


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
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$Key" -Headers $jiraHeader

$finalizedGroupEmail    = $form.fields.customfield_10951
$finalizedGroupName     = $form.fields.customfield_10950
$groupDescription       = $form.fields.customfield_10948
$groupOwners            = $form.fields.customfield_10780.emailAddress
$groupMembers           = $form.fields.customfield_10920.emailAddress
$senderPermission       = $form.fields.customfield_10939
$externalSenderAllowed  = $form.fields.customfield_10949.Value

# Example usage of the parameters
Write-Output "The  Key is: $Key"
Write-Output "The finalizedGroupEmail is: $finalizedGroupEmail"
Write-Output "The finalizedGroupName is $finalizedGroupName"
Write-Output "The Group Owner(s) are: $groupOwners / there are $($GroupOWners.count) owners"
Write-Output "The Group Members are:  $groupMembers / there are $($GroupMembers.count) members"
Write-Output "Pemitted senders are: $senderPermission / there are $($senderPermission.count) allowed senders"
Write-Output "Are External Senders allowed: $externalSenderAllowed"
Write-Output "The description is: `n`n$groupDescription`n`n`n"


try{
if ($externalSenderAllowed -eq "No")
{
    New-DistributionGroup -DisplayName $finalizedGroupName -PrimarySmtpAddress $finalizedGroupEmail -Description $groupDescription -Name $finalizedGroupName -ManagedBy $groupOwners -Members $groupMembers   -MemberJoinRestriction Closed -MemberDepartRestriction Closed
}
else{
    New-DistributionGroup -DisplayName $finalizedGroupName -PrimarySmtpAddress $finalizedGroupEmail -Description $groupDescription -Name $finalizedGroupName -ManagedBy $groupOwners -Members $groupMembers RequireSenderAuthenticationEnabled $false   -MemberJoinRestriction Closed -MemberDepartRestriction Closed
}

Set-SuccessfulComment
}
catch{
    $errorMessage = $_
    Write-Output $errorMessage
    Set-PrivateErrorJira
    Set-PublicErrorJira

}
# SIG # Begin signature block#Script Signature# SIG # End signature block







