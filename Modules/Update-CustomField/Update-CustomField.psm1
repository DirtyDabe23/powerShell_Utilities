function Update-CustomField {
    #Requires -Module Get-CustomField
    #Requires -Version 7.0
    <#
    .SYNOPSIS
    This function updates a custom field in Jira.
    
    .DESCRIPTION
    This function allows you to update a custom field in Jira by specifying the custom field name, parent ID, new value, and whether to hide it from users. 
    It uses the Jira REST API for the update operation.
    
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API.
    
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    
    .PARAMETER customFieldName
    The name of the custom field to update. This should match the name used in Jira.
    
    .PARAMETER customFieldParentID
    The parent ID of the custom field option to update. This is usually the ID of the context or parent option.
    
    .PARAMETER newValue
    The ID of the custom field option to update. This is the specific option ID within the custom field context.
    
    .PARAMETER hideFromUsers
    Optional parameter to hide the custom field from users. Default is false.
    
    .EXAMPLE
    Update-CustomField -jiraKey "your_jira_api_key" -customFieldName "Custom Field Name" `
                       -customFieldParentID "12345" -newValue "New Value" -hideFromUsers
    This example updates the custom field with the specified name and parent ID to the new value, and hides it from users.

    .EXAMPLE
    Update-CustomField -jiraKey "your_jira_api_key" -customFieldName "Custom Field Name" `
                       -customFieldParentID "12345" -newValue "New Value"
    This example updates the custom field with the specified name and parent ID to the new value without hiding it from users.
    
    .NOTES
    This function requires the Get-CustomField function to retrieve the custom field details.
    Ensure that you have the necessary permissions to update custom fields in Jira.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain.toLower() -join ""),
        [Parameter(Mandatory = $true, HelpMessage = "Jira API key for authentication. This should be a valid API token.")]
        [string]$jiraKey,
        [Parameter(Mandatory = $true, HelpMessage = "Name of the custom field to update. This should match the name used in Jira.")]
        [string]$customFieldName,
        [Parameter(Mandatory = $true, HelpMessage = "ID of the custom field option to update. This is the specific option ID within the custom field context.")]
        [string]$newValue,
        [Parameter(Mandatory = $false, HelpMessage = "Use this switch if this is a cascading field child option",ParameterSetName = "ParentID")]
        [switch]$isCascadingChild,
        [Parameter(Mandatory = $false, HelpMessage = "Parent ID of the custom field option to update. This is usually the ID of the context or parent option.",ParameterSetName = "ParentID")]
        [string]$customFieldParentID ,
        [Parameter(Mandatory = $false, HelpMessage = "Optional parameter to hide the custom field from users. Default is false.")]
        [switch]$hideFromUsers
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

    switch ($hideFromUsers.IsPresent){
        $true{
                    $hidden = $true
        }
        Default {
                    $hidden = $false
        }
    }
    Write-Output "Hidden: $hidden"

    # Get the custom field by name
    $customField    = Get-CustomField -customFieldName $customFieldName -jiraKey $jiraKey
    $contextID      = (Invoke-RestMethod -uri ("https://parentCompany.atlassian.net/rest/api/3/field/",$customField.id , "/contexts" -join "") -Headers $jiraHeader).values.ID

    if ($null -eq $customField) {
        throw "Custom field '$customFieldName' not found."
    }
    if($isCascadingChild){
            $body = @{
            options = @(
                [Ordered]@{
                    disabled    = $hidden
                    optionId    = "$customFieldParentID" 
                    value       = "$newValue"
                }
            )
        } | ConvertTo-Json -Depth 5
    }
    else{
        $body = @{
            options = @(
                [Ordered]@{
                    disabled    = $hidden 
                    value       = "$newValue"
                }
            )
        } | ConvertTo-Json -Depth 5
    }

    # Construct the request URI for updating the custom field option
    $requestURI = "https://parentCompany.atlassian.net/rest/api/3/field/", "$($customField.id)", "/context/", $contextID, "/option" -join""
    # Update the custom field option
    try {
        $response = Invoke-RestMethod -Uri $requestURI  -Headers $jiraHeader -Method Post -Body $body
        Write-Host "Custom field '$customFieldName' updated successfully to '$newValue'."
    } catch {
        throw "Failed to update custom field: $customFieldName. Error: $_"
    }
    return $response
}
SignatureBlock

