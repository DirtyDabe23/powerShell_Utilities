param(
    [string]$Key
)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::'Tls13','TLS12'
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
$errorsToReview = Import-CSV -Path "C:\DevErrors.CSV"

#JiraConnection 
try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $connection | out-null
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "JiraAPI" -AsPlainText
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
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$errorMatch = $false

$ticketNum = $key
$form = Invoke-RestMethod -Method Get -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$ticketNum" -Headers $headers -ContentType
$attachment = $form.fields.attachment | Where-Object { $_.filename -eq 'log.txt' }

if ($attachment) {
    $attachmentContent = Invoke-RestMethod -Uri $attachment[0].content -Method Get -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 

    foreach ($errorToReview in $errorsToReview) {
        # Escape special characters in the search string
        $escapedSearchString= [regex]::Escape($errorToReview.StackTraceString)
        
        if ($attachmentContent.exception -match $escapedSearchString) {
            $errorMatch = $true
            $ticketsMatching += [PSCustomObject]@{
                TicketNumber = $ticketNum
                DateCreated  = $form.fields.created
                ErrorType    = $errorToReview.Tag
                reporterDisplayName = $form.fields.reporter.displayName
                reporterEmailAddress = $form.fields.reporter.emailaddress
            }
            $payload = @{
"update" = @{
    "labels" = @(@{
        "add" = "$($errorToReview.Tag)"
    })
}
}
$jsonPayload = $payload | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 
            break
        }
    }
    If ($errorMatch -eq $false)
    {
        $payload = @{
            "update" = @{
                "labels" = @(@{
                    "add" = "ERR_NEEDS_INVESTIGATED"
                })
            }
            }
            $jsonPayload = $payload | ConvertTo-Json -Depth 10
            
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 
    }
}
Else{
    $payload = @{
        "update" = @{
            "labels" = @(@{
                "add" = "ERR_NO_ATTACHMENT"
            })
        }
        }
        $jsonPayload = $payload | ConvertTo-Json -Depth 10
        
        Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers -ContentType "application/JSON" -SslProtocol Tls12 -HttpVersion 2.0 
}
Write-Output "Error for $key was: $($errorToReview.Tag)"
# SIG # Begin signature block#Script Signature# SIG # End signature block








