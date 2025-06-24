function Get-ReportedJiraIssues {
    <#
    .SYNOPSIS
        Retrieves the issues assigned to the current user in Jira.
    .DESCRIPTION
        This function connects to Jira and retrieves the issues assigned to the current user.
    .COMPONENT
        Jira
    .PARAMETER jiraOrg
        The organization name for the Jira instance. Defaults to 'parentCompany'.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .PARAMETER jiraReporter
        The person who reported the issue to Jira
    .EXAMPLE
        Get-ReportedJiraIssues -jiraOrg 'parentCompany' -jiraUser 'david.drosdick@Domain.extension1' -jiraKey $jiraKey -jiraReporter "David.Drosdick@Domain.extension1"
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
        The output will be a list of tickets assigned to the user
    .LINK
        https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
        A list of Jira issues assigned to the current user.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$jiraOrg = 'parentCompany',
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2,Mandatory = $false,HelpMessage = "The assignee for the Jira issues. Defaults to the current user's username and domain.")]
        [string]$jiraReporter = ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [parameter(Position = 3, Mandatory = $true, HelpMessage = "The Jira Project to Retrieve.")]
        [string]$jiraProject,
        [Parameter(Mandatory = $false, HelpMessage = "Output type: Filtered or Full. Defaults to Filtered")]
        [PSDefaultValue(Help="Filtered", Value='Filtered')]
        [ValidateSet('Filtered','Full', IgnoreCase = $true)]
        [string]$outputType
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $jql = "$jiraReporter"
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $userURI = "https://$jiraOrg.atlassian.net/rest/api/3/user/search?query=$encodedJQL"
    try {
        $userResponse = Invoke-RestMethod -Uri $userURI -Method Get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    if ($userResponse -and $userResponse.Count -gt 0) {
        $userId = $userResponse[0].accountId
    } else {
        throw "No user found with the specified username: $jiraReporter"
    }
    $jql = "reporter = ","$userID",' AND PROJECT IN ',"($jiraProject)",' AND Resolution = Empty ORDER BY created asc' -join ''
    #This encodes the JQL query to be used in the API call.
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $uri = 'https://',$jiraOrg,'.atlassian.net/rest/api/3/search/jql?jql=',$encodedJQL -join ''
    try{
        $jiraResponse = Invoke-RestMethod -uri $uri -method get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    $ticketsReported = @()
    $filteredOutput = @()
    if ($jiraResponse.issues) {
        $jiraTickets = $jiraResponse.Issues.ID
        ForEach ($jiraTicket in $jiraTickets){
            $ticketsReported += Get-JiraTicket -jiraUser $jiraUser -jiraKey $jiraKey -jiraTicket $jiraTicket
        }
        if ($outputType -eq 'Filtered'){
            ForEach ($item in $ticketsReported){
                $filteredOutput += [PSCustomObject]@{
                    Reporter        = $item.fields.reporter.displayName
                    ReporterEmail   = $item.fields.reporter.emailAddress
                    Assignee        = $item.fields.assignee.displayName
                    AssigneeEmail   = $item.fields.assignee.emailAddress
                    Key             = $item.key
                    Summary         = $item.fields.summary
                    Description     = $item.fields.Description
                    Status          = $item.fields.status.name
                    Created         = $item.fields.created
                    Updated         = $item.fields.updated
                    Priority        = $item.fields.priority.name
                    IssueType       = $item.fields.issuetype.name
                }
            }
            return $filteredOutput  

        }
        else{
            return $ticketsReported
        }
    }
    else {
        return "No issues found for the specified assignee."
    }
}
SignatureBlock

