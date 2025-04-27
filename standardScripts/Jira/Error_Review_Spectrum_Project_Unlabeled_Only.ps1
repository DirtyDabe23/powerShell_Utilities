$allStartTime = Get-Date 
$pageCount = 1
# Import CSV
$errorsToReview = Import-Csv -Path "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs\devErrors.csv"

# Jira API Setup
$encodedText = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$userName@uniqueParentCompany.com:$jiraRetrSecret"))
$headers = @{
    "Authorization" = "Basic $encodedText"
    "Content-Type"  = "application/json"
}

# Initialize variables
$ticketsMatching = @()
$uriTemplate = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=project%3Dspec%20AND%20labels%20%3D%20EMPTY&startAt={0}"

# Retrieve total issue count
$total = (Invoke-RestMethod -Method Get -Uri ($uriTemplate -f 0) -Headers $headers).total

# Process issues in batches
for ($count = 0; $count -lt $total; $count += 50) {
    $uri = $uriTemplate -f $count
    $issues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $issuePageStartTime = Get-Date 

    foreach ($issue in $issues.issues) {
        $ticketNum = $issue.key
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
                "add" = "$($errorToReview.Tag)" # Replace with your label
            })
        }
    }
    $jsonPayload = $payload | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers
                    break
                }
            }
        }
    }
    $issuePageEndTime = Get-Date
    $issuePageNetTime = $issuePageEndTime - $issuePageStartTime
    $currTime = Get-Date -format "HH:mm"
    $issuePageProcess = "Jira Issue Page Review"
    Write-Output "[$($currTime)] | Time taken for [$issuePageProcess : Page $pageCount] to complete: $($issuePageNetTime.hours) hours, $($issuePageNetTime.minutes) minutes, $($issuePageNetTime.seconds) seconds"
    $pagecount++
}

# Export the results
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Time taken for [Spectrum Error Audit] to complete: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
$exportPath = "\\uniqueParentCompanyusers\departments\public\Tech-Items\scriptLogs\error_report.csv"
$ticketsMatching | Export-Csv -Path $exportPath -NoTypeInformation

# SIG # Begin signature block#Script Signature# SIG # End signature block






