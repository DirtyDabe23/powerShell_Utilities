function New-CustomField{
    #Requires -Version 7.0
    <#
    .SYNOPSIS
    This function creates a custom field in Jira
    
    .DESCRIPTION
    This function allows you to create a custom field in Jira. It requires the Jira API and appropriate permissions to execute successfully.
    
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It will default to your UserName and UserDNSDomain. 

    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.

    .PARAMETER fieldName
    The name of the custom field to be created. This should be a unique name that does not conflict with existing fields.

    .PARAMETER description
    The description of the custom field to be created. This should provide a clear understanding of the field's purpose.    

    .PARAMETER fieldType
    The type of the custom field to be created. This should be a valid Jira field type such as 'text', 'number', 'date', etc. Valid options include:
    cascading, datepicker, datetime, float, grouppicker, importid, labels, multicheckboxes, multigrouppicker, multiselect, multiversion,

    .EXAMPLE
    New-CustomField -jiraUser "david.drosdick" -jiraKey $jiraKey -fieldName "New Custom Field" -description "This is a new custom field" -fieldType "textfield"
    This example creates a new custom field named "New Custom Field" with the type "textfield" and the provided description.

    .EXAMPLE
    New-CustomField -jiraKey $jiraKey -fieldName "New Custom Field" -description "This is a new custom field" -fieldType "textfield"
    This example creates a new custom field named "New Custom Field" with the type "textfield" and the provided description, using the default Jira user.

    
    .NOTES
    This function requires the Jira API to be accessible and the user must have permissions to create custom fields in Jira.
    The function will return the details of the created custom field if successful, or an error message if it fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Position = 1,Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Position = 2 , Mandatory = $true, HelpMessage = "The name of the custom field to be created. This should be a unique name that does not conflict with existing fields.")]
        [string]$fieldName,
        [Parameter(Position = 3,Mandatory = $true,HelpMessage = "The description of the custom field to be created.")]
        [string]$description,
        [Parameter(Position = 3,Mandatory = $true,HelpMessage = "The type of the custom field to be created. This should be a valid Jira field type such as 'text', 'number', 'date', etc.")]
        [ValidateSet("cascading", "datepicker", "datetime", "float", "grouppicker", "importid", "labels", "multicheckboxes", "multigrouppicker", "multiselect", "multiversion","project"
        ,"radiobuttons","readonlyfield","select","textarea","textfield","url","userpicker","version")]
        [string]$fieldType
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    
    $jiraFieldType = 'com.atlassian.jira.plugin.system.customfieldtypes:' ,$fieldType.ToLower() -join ""

    $body = [ordered]@{
        "name" = $fieldName
        "description" = $description
        "type" = $jiraFieldType
    } | ConvertTo-JSON -Depth 5

    $requestURI = "https://parentCompany.atlassian.net/rest/api/3/field"
    try {
        $response = Invoke-RestMethod -Uri $requestURI -Method Post -Headers $jiraHeader -Body $body
        Write-Output "Custom field created successfully: $($response.name)"
        return $response
    } 
    catch {
        Throw "Failed to create custom field $fieldName`: $_"
    }
}
SignatureBlock

