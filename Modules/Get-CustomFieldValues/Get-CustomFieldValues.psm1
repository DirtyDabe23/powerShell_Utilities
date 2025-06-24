function Get-CustomFieldValues{
    <#
    .Synopsis
        Retrieves the values of a specific custom field in Jira.
    .DESCRIPTION
    This function connects to Jira and retrieves the values of a specified custom field by its name.
    .COMPONENT
        Jira
    .PARAMETER customFieldName
        The name of the custom field to retrieve values from.
    .PARAMETER jiraUser
        The username of the account used to connect to Jira via the API. Defaults to the current user's username and domain.
    .PARAMETER jiraKey
        The Jira API key for authentication. This should be a valid API token.
    .EXAMPLE
        Get-CustomFieldValues -customFieldName "Office Location and Department" -jiraUser $jiraUser -jiraKey $jiraKey
    .NOTES
        This function requires the Jira API key for authentication. Ensure that you have the necessary permissions to
        access the Jira instance.
        The function uses the 'Invoke-RestMethod' cmdlet to make API calls to Jira.
    .LINK
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A list of values associated with the specified custom field in Jira.
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Customfield Name to Pull from Jira", Mandatory=$true)]
    [string]$customFieldName,
    [Parameter(Position = 1,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.Tolower() -join ""),
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
        $foundField = $fields | Where-Object {($_.Name -eq $customFieldName)}


    If ($null -ne $foundField)
    {
        $reviewingField = $fields | Where-Object {($_.Name -eq $customFieldName)}

        $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $jiraHeader


        $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $jiraHeader

        $reviewedFieldValues = @()

        If ($reviewingFieldValues.Total -ge 100)
        {
            $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

            for ($count = 0; $count -lt $reviewingFieldValues.Total; $count += 100) 
            {
                $uri = $uriTemplate -f $count
                $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $jiraHeader
                ForEach ($fieldValue in $fieldValues.values)
                {
                    $reviewedFieldValues += [PSCustomObject]@{
                        FieldName   = $customFieldName
                        ID          = $fieldValue.ID
                        Value       = $fieldValue.Value
                        OptionID    = $fieldValue.optionID
                        Disabled    = $fieldValue.Disabled
                    }
                }
            }

        }
        else 
        {
            $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option"
            $fieldValues = Invoke-RestMethod -Method Get -Uri $uriTemplate -Headers $jiraHeader
            ForEach ($fieldValue in $fieldValues.values)
                {
                    $reviewedFieldValues+= [PSCustomObject]@{
                        FieldName   = $customFieldName
                        ID          = $fieldValue.ID
                        Value       = $fieldValue.Value
                        OptionID    = $fieldValue.optionID
                        Disabled    = $fieldValue.Disabled
                    }
                }
        }
    return $reviewedFieldValues    
    }
    else
    {
        Write-Output "Field Name not found"
    }
}
SignatureBlock

