function Get-AssignedJiraIssues {
    <#
    .SYNOPSIS
        Retrieves the issues assigned to the current user in Jira.

    .DESCRIPTION
        This function connects to Jira and retrieves the issues assigned to the current user.
        It uses the Jira REST API to fetch the data and returns it in a structured format.
    .COMPONENT
        Jira
    .PARAMETER JiraOrg
        The organization name for the Jira instance. Defaults to 'parentCompany'.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.

    .EXAMPLE
        Get-AssignedJiraIssues -jiraOrg 'parentCompany' -jiraUser 'david.drosdick@Domain.extension1' -jiraKey $jiraKey -jiraAssignee "David.Drosdick@Domain.extension1"

    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
        The output will be a list of tickets assigned to the user
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions

    .OUTPUTS
    JSON formatted data from the Jira API containing the issues assigned to the user.
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
        [string]$jiraAssignee = ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [parameter(Position = 3, Mandatory = $true, HelpMessage = "The Jira Project to Retrieve.")]
        [string]$jiraProject,
        [Parameter(Mandatory = $false, HelpMessage = "Output type: Filtered or Full. Defaults to Filtered")]
        [PSDefaultValue(Help="Filtered", Value='Filtered')]
        [ValidateSet('Filtered','Full', IgnoreCase = $true)]
        [string]$outputType = 'Filtered'
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $jql = "$jiraAssignee"
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
        throw "No user found with the specified username: $jiraAssignee"
    }
    $jql = "assignee = ","$userID",' AND PROJECT IN ',"($jiraProject)",' AND Resolution = Empty ORDER BY created asc' -join ''
    #This encodes the JQL query to be used in the API call.
    $encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
    $uri = 'https://',$jiraOrg,'.atlassian.net/rest/api/3/search/jql?jql=',$encodedJQL -join ''
    try{
        $jiraResponse = Invoke-RestMethod -uri $uri -method get -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
    }
    catch {
        throw "Failed to connect to Jira API. Please check your credentials and network connection."
    }
    $ticketsAssigned = @()
    if ($jiraResponse.issues) {
        $jiraTickets = $jiraResponse.Issues.ID
        ForEach ($jiraTicket in $jiraTickets){
            $ticketsAssigned += Get-JiraTicket -jiraUser $jiraUser -jiraKey $jiraKey -jiraTicket $jiraTicket -outputType $outputType
        }
            return $ticketsAssigned
        }
    else {
        return "No issues found for the specified assignee."
    }
}
SignatureBlock

