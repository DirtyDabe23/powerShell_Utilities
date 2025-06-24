#Pull the Data
$errorsToReview = Import-CSV -Path "\\parentCompanyusers\departments\Public\Tech-Items\Script Configs\devErrors.csv"

#File Creation Objects
$shareLoc = "\\parentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "$($errorToReview.ClassName).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm

$issuePages = @();
$attachments =@();

#Jira
$Text = ‘david.drosdick@Domain.extension1:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" =   "Basic $EncodedText"
    "Content-Type" =    "application/json"
}

[int] $count = 0 
$uri = "https://parentCompany.atlassian.net/rest/api/2/search?jql=project%20%3D%20spec%20&startAt=$count"


$procStartTime = Get-Date 


#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$total = (Invoke-RestMethod -Method get -uri $uri -Headers $headers).total
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
$procProcess = "Jira Ticket Count"
Write-Output "[$($currTime)] | Time taken for [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


$procStartTime = Get-Date 
While ($count -lt $total)
{
    $uri = "https://parentCompany.atlassian.net/rest/api/2/search?jql=project%20%3D%20spec%20&startAt=$count"
    #Jira
    $Text = ‘david.drosdick@Domain.extension1:$jiraRetrSecret’
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    $headers = @{
        "Authorization" =   "Basic $EncodedText"
        "Content-Type" =    "application/json"
        "maxResults"   =    [int]50
        "startAt"      =    $count
    }

    $issuePages += Invoke-RestMethod -Method get -uri $uri -Headers $headers

    if (($total - $count) -ge 50) 
    {
        # Process 50 tickets
        $count += 50
    } 
    else 
    {
        # Process the remaining tickets
        $remaining = $total - $count
        # Process $remaining tickets
        $count += $remaining
    }
}
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
$procProcess = "Jira Issue Page Retrieval"
Write-Output "[$($currTime)] | Time taken for [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


$procStartTime = Get-Date 

ForEach ($issuePage in $issuePages)
{
    ForEAch ($issue in $issuePage.issues)
    {
        $TicketNum = $issue.key
        $Form = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$TicketNum" -Headers $headers
        $attachments += $form.fields.attachment | where-Object {($_.FileName -eq 'log.txt')}

    }
}

$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
$procProcess = "Jira Issue Attachment Retrieval"
Write-Output "[$($currTime)] | Time taken for [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
SignatureBlock

