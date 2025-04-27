param(
    [string]$Reporter,
    [string]$Description,
    [string]$Key
)


#onPremConnection and Data Review
try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $workerSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "TTWorker" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
$password = ConvertTo-SecureString $workerSecret -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("$userNameAdmin@uniqueParentCompany.com", $password)
New-PsDrive -name "ScriptConfigs" -PSProvider "FileSystem" -Root "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs" -Credential $Cred
Set-Location ScriptConfigs:
$devErrors = Import-CSV -Path "ScriptConfigs:\DevErrors.CSV"





#JiraConnection 
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
#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}


$ticketNum = $key
$form = Invoke-RestMethod -Method Get -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$ticketNum" -Headers $headers
$attachment = $form.fields.attachment | Where-Object { $_.filename -eq 'log.txt' }

if ($attachment) {
    $attachmentContent = Invoke-RestMethod -Uri $attachment[0].content -Method Get -Headers $headers

    foreach ($errorToReview in $errorsToReview) {
        # Escape special characters in the search string
        $escapedSearchString= [regex]::Escape($errorToReview.StackTraceString)
        
        if ($attachmentContent.exception -match $escapedSearchString) {
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

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers
            break
        }
    }
}

#End / Cleanup
Remove-PSDrive -Name "ScriptConfigs"
# SIG # Begin signature block#Script Signature# SIG # End signature block








