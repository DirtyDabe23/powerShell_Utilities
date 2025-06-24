function Get-CustomField{
    <#
    .SYNOPSIS
        Retrieves information about a specific custom field in Jira.
    .DESCRIPTION
        This function connects to Jira and retrieves information about a specified custom field by its name.
    .COMPONENT
        Jira
    .PARAMETER customFieldName
        The name of the custom field to retrieve information about.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-CustomField -customFieldName "Office Location and Department" -jiraUser $jiraUser -jiraKey $jiraKey
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Customfield Name to Pull from Jira",Mandatory = $true)]
    [string]$customFieldName,
    [Parameter(Position = 1,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
    [Parameter(Position = 2, HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey
    )


#This creates the Jira header for authorization into the API and to return the data in JSON format.
$jiraText = "$jiraUser",":","$jiraKey" -join ""
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $jiraHeader
$foundField = $fields | Where-Object {($_.Name -like "$customfieldName")}
if($foundField){
    return $foundField
}
else{
    Write-Output "Field Not Found"
}
}
SignatureBlock

