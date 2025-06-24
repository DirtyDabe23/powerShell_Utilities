function Get-JiraTicket{
    <#
    .SYNOPSIS
    This function retrieves Jira tickets based on the provided parameters and returns their details.
    .DESCRIPTION
    This function connects to a Jira instance using the provided credentials and retrieves tickets based on the specified parameters. It returns a list of ticket details including key, summary, status, and assignee.
    .COMPONENT
    Jira
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It defaults to the current user's username and domain.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER jiraTicket
    The Jira ticket key to retrieve details for. Example: "GHD-1234".
    .PARAMETER ouputType
    To what degree of detail you want the returned object to provide. The default is filtered, which returns a limited set of properties.
    .EXAMPLE
    Get-JiraTicket -jiraKey $jiraKey -jiraTicket "GHD-1234"
    Retrieves the details of the Jira ticket with key "GHD-1234" using the provided API key.
    .NOTES
    This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to access the Jira instance.
    The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A list of Jira ticket details including key, summary, status, and assignee.
    #>
    [CmdletBinding()]
    param(
        
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2,HelpMessage = "The Jira Ticket, Example: GHD-1234 ")]
        [string]$jiraTicket,
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
    try{
        $Form = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket" -Headers $jiraHeader -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0
         if ($outputType -eq 'Filtered'){
                $filteredOutput += [PSCustomObject]@{
                    Reporter        = $form.fields.reporter.displayName
                    ReporterEmail   = $form.fields.reporter.emailAddress
                    Key             = $form.key
                    Summary         = $form.fields.summary
                    Description     = $form.fields.Description
                    Status          = $form.fields.status.name
                    Created         = $form.fields.created
                    Updated         = $form.fields.updated
                    Priority        = $form.fields.priority.name
                    IssueType       = $form.fields.issuetype.name
                }
            return $filteredOutput  
        }
        return $Form
    }
    catch{
        Write-Error "Failed to connect to Jira API. Please check your credentials and network connection."
        throw $error[0] | select-object -Property *
    }
}
SignatureBlock

