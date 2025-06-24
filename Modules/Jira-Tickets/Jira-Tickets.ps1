function Get-JiraRequiredFields {
    #Requires -Module Jira-Comments
    #Requires -Version 7.0 
    <#
    .SYNOPSIS
    Creates a new Jira ticket in the specified project.
    .DESCRIPTION
    This function creates a new Jira ticket in the specified project using the Jira API.

    .PARAMETER jiraOrg
    The Jira organization name. Defaults to 'parentCompany'.
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER jiraAssignee
    The UPN of the user to assign the ticket to. Defaults to the current user's username and domain.
    .PARAMETER jiraProject
    The Jira project to retrieve.
    .PARAMETER jiraIssueType
    The Jira issue type to retrieve. Defaults to "Task".
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
    [Parameter(Position = 4, Mandatory = $false, HelpMessage = "The Jira Issue Type to Retrieve.")]
    [string]$jiraIssueType = "Task"
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $projects = (invoke-restmethod -uri "https://parentCompany.atlassian.net/rest/api/3/project/search" -Headers $jiraHeader -method Get).values.key
    if ($projects -notcontains $jiraProject) {
        throw "The specified project '$jiraProject' does not exist or is not accessible."
    }
    $projectIssueMetaData = invoke-restmethod -uri "https://parentCompany.atlassian.net/rest/api/3/issue/createmeta/$jiraProject/issuetypes" -Headers $jiraHeader -Method Get
    $availableIssueTypes = $projectIssueMetaData.IssueTypes | select-object -Property ID , Name 
    if ($availableIssueTypes.Name -notcontains $jiraIssueType) {
        throw "The specified issue type '$jiraIssueType' is not available for the project '$jiraProject'. Available issue types are:`n$($availableIssueTypes.Name -join "`n")"
    }
    $issueTypeID = ($availableIssueTypes | Where-Object {($_.Name -eq $jiraIssueType)}).ID
    $createIssueMetaData = invoke-restmethod -uri "https://parentCompany.atlassian.net/rest/api/3/issue/createmeta/$jiraProject/issuetypes/$issueTypeID" -Headers $jiraHeader -Method Get
    $requirements = $createIssueMetaData.Fields | Where-Object {($_.required -eq $true)} | select-object -property  name , key , allowedValues 
    if ($requirements.Count -eq 0) {
        throw "No required fields found for the specified issue type '$jiraIssueType' in project '$jiraProject'."
    }
    else{
        return $requirements
    }
}

SignatureBlock

