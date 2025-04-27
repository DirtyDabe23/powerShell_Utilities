$measureCommand2 = Measure-Command -Expression {
#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "JiraAPI" -AsPlainText

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

    $fieldName = "Office Location and Department"

    $foundField = $fields | Where-Object {($_.Name -eq $fieldName)}


If ($null -ne $foundField)
{
    $reviewingField = $fields | Where-Object {($_.Name -eq $fieldName)}

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
                if ($null -ne $fieldvalue.OptionID)
                {
                switch ($fieldValue.optionID) {
                    10833{$officeLocation="unique-Office-Location-0"}
                    10834{$officeLocation="unique-Office-Location-1"}
                    10835{$officeLocation="unique-Office-Location-2"}
                    10878{$officeLocation="unique-Office-Location-3"}
                    10879{$officeLocation="unique-Company-Name-20"}
                    10880{$officeLocation="unique-Company-Name-7"}
                    10881{$officeLocation="unique-Office-Location-6"}
                    10882{$officeLocation="unique-Office-Location-7"}
                    10883{$officeLocation="uniqueParentCompany (Beijing)Â Refrigeration Equipment Co., Ltd."}
                    10884{$officeLocation="unique-Office-Location-9"}
                    10887{$officeLocation="unique-Company-Name-3"}
                    10888{$officeLocation="unique-Company-Name-18"}
                    10889{$officeLocation="unique-Company-Name-5"}
                    10891{$officeLocation="unique-Company-Name-21"}
                    10893{$officeLocation="unique-Company-Name-6"}
                    10894{$officeLocation="unique-Company-Name-4"}
                    10895{$officeLocation="unique-Office-Location-16"}
                    10896{$officeLocation="unique-Company-Name-2"}
                    10897{$officeLocation="unique-Office-Location-18"}
                    10898{$officeLocation="unique-Company-Name-10"}
                    10899{$officeLocation="unique-Company-Name-11"}
                    10900{$officeLocation="unique-Office-Location-21"}
                    10901{$officeLocation="unique-Company-Name-8"}
                    11959{$officeLocation="unique-Company-Name-17"}
                    11960{$officeLocation="unique-Company-Name-16"}
                    11979{$officeLocation="unique-Company-Name-12"}
                    11981{$officeLocation="unique-Company-Name-14"}
                    11986{$officeLocation="unique-Office-Location-27"}
                    
                }
                $reviewedFieldValues += [PSCustomObject]@{
                    officeLocation        = $officeLocation
                    validDepartment       = $fieldValue.Value
                }
            }
            }
        }

    }
    $reviewedFieldValues    
}
else
{
    Write-Output "Field Name not found"
}
}
# SIG # Begin signature block#Script Signature# SIG # End signature block


































