function Get-CustomFieldValues{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Customfield Name to Pull from Jira", Mandatory=$true)]
    [string]$customFieldName
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }



        $Fields = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field" -Headers $jiraHeader
        $foundField = $fields | Where-Object {($_.Name -eq $customFieldName)}


    If ($null -ne $foundField)
    {
        $reviewingField = $fields | Where-Object {($_.Name -eq $customFieldName)}

        $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $jiraHeader


        $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $jiraHeader

        $reviewedFieldValues = @()

        If ($reviewingFieldValues.Total -ge 100)
        {
            $uriTemplate = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

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
            $uriTemplate = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option"
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
# SIG # Begin signature block#Script Signature# SIG # End signature block









