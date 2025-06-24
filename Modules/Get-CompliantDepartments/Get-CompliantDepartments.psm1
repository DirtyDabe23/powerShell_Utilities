function Get-CompliantDepartments {
    <#
    .SYNOPSIS
        Retrieves and formats the list of compliant departments from a custom field in Jira.
    .DESCRIPTION
        This function connects to Jira, retrieves the values of the custom field "Office Location and Department
    .COMPONENT
        Jira, EntraID
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-CompliantDepartments -jiraUser $jiraUser -jiraKey $jiraKey
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to
        access the Jira instance.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A formatted list of compliant departments with their associated locations.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The Jira user to authenticate with.")]
        [string]$jiraUser,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "The Jira API key to use for authentication.")]
        [string]$jiraKey
    )
    $unformattedList = Get-CustomFieldValues -customFieldName "Office Location and Department" -jiraUser $jiraUser -jiraKey $jiraKey
    $formattedList = @()
    $locationIDs = $unformattedlist.optionID | Select-Object -Unique     
    ForEAch ($locationID in $locationIDs){
        $locationName = ($unformattedlist | Where-Object {($_.ID -eq $locationID)}).Value
        $Departments = ($unformattedlist | Where-Object {($_.optionID -eq $locationID)}).Value
        ForEAch ($department in $departments){
            $formattedList += [PSCustomObject]@{
                LocationName    = $locationName
                Department      = $department
            }
        }
    }
    return $formattedList
}
SignatureBlock

