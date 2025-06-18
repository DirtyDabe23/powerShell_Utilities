Clear-Host 
$process = "GIT Service Desk & Infrastructure Ticket Review"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

$allStartTime = Get-Date 
$pageCount = 1
# Import CSV
#Connection to the Jira API after getting the token from the Key Vault
$vaultName = 'jiraAPIKeyKey'
$apiVersion = "2020-06-01"
$resource = "https://vault.azure.net"
$endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$resource,$apiVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($wwwAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($wwwAuthHeader -split "Basic realm=")[1]
    }
}
$jiraSecret = Get-Content -Raw $jiraSecretFile
$response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($response)
{
    $jiraToken = (ConvertFrom-Json -InputObject $response.Content).access_token
}

$retrSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($vaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value


#Jira Header
$jiraText = "$userName@uniqueParentCompany.com:$retrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}


# Initialize variables
$ticketsMatching = @()
$uriTemplate = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=project%20in%20(CYOPS,GHD)&startAt={0}"

# Retrieve total issue count
$total = (Invoke-RestMethod -Method Get -Uri ($uriTemplate -f 0) -Headers $headers).total
$totalPages = $total/50
If (($totalPages%1) -gt 0)
    {
    $totalPages +=1-($totalPages % 1)
    }


# Process issues in batches
for ($count = 0; $count -lt $total; $count += 50) {
    $uri = $uriTemplate -f $count
    $issues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $issuePageStartTime = Get-Date 

    foreach ($issue in $issues.issues) {
                    $ticketsMatching += [PSCustomObject]@{
                        DateCreated  = $issue.fields.created
                        TicketNumber = $issue.key
                        Status       = $issue.fields.status.name 
                        Summary      = $issue.fields.summary
                        Description  = $issue.fields.description
                        Assignee     = $issue.fields.assignee.displayname
                        assignEmail  = $issue.fields.assignee.emailaddress
                        reporterDisplayName = $issue.fields.reporter.displayName
                        reporterEmailAddress = $issue.fields.reporter.emailaddress
                        DateFinished   = $issue.fields.resolutiondate
                    }

    }
    $issuePageEndTime = Get-Date
    $issuePageNetTime = $issuePageEndTime - $issuePageStartTime
    $currTime = Get-Date -format "HH:mm"
    $issuePageProcess = "Jira Issue Page Review"
    Write-Output "[$($currTime)] | [Total Issuge Pages: $($totalPages)] | Time taken for [$issuePageProcess : Page $pageCount] to complete: $($issuePageNetTime.hours) hours, $($issuePageNetTime.minutes) minutes, $($issuePageNetTime.seconds) seconds"
    $pagecount++
}

# Export the results
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Time taken for [Infrastructure Ticket Audit] to complete: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
$exportPath = "\\uniqueParentCompanyusers\departments\public\Tech-Items\scriptLogs\$(get-date -format YYYY-MM-DD)-cyops-ghd-tickets.csv"
$ticketsMatching | Export-Csv -Path $exportPath -NoTypeInformation

$assignees = $ticketsMatching | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee


$assigneeTicketCount = @()

ForEach ($assignee in $assignees)
{
   #strip the Office Location value down to the base element
   $gName = $assignee.Assignee
   #Get the user count for the individual Given Name  
   $gNameCount = ($ticketsMatching | Where-Object {($_.Assignee -eq $gName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject 
   $assigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}

$assigneeTicketCount | sort-object -Property CompletedTickets -Descending

# SIG # Begin signature block#Script Signature# SIG # End signature block









