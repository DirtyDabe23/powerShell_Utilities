$measureCommand1 = Measure-Command -Expression {
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }



        $Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $jiraHeader

        $fieldName = "Office Location and Department"

        $foundField = $fields | Where-Object {($_.Name -eq $fieldName)}


    If ($null -ne $foundField)
    {
        $reviewingField = $fields | Where-Object {($_.Name -eq $fieldName)}

        $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $jiraHeader


        $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $jiraHeader

        $reviewedFieldValues = @()
        $results = [System.Collections.Generic.List[object]]::new()

        If ($reviewingFieldValues.Total -ge 100)
        {
            $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

            for ($count = 0; $count -lt $reviewingFieldValues.Total; $count += 100) 
            {
                $uri = $uriTemplate -f $count
                $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $jiraHeader
                ForEach ($fieldValue in $fieldValues.values)
                {
                    if ($null -ne $fieldvalue.OptionID)
                    {
                    switch ($fieldValue.optionID) {
                        10833{$officeLocation="parentCompany East"}
                        10834{$officeLocation="Location2"}
                        10835{$officeLocation="parentCompany Midwest"}
                        10878{$officeLocation="parentCompany Iowa"}
                        10879{$officeLocation="subsidiaryCompany1"}
                        10880{$officeLocation="parentCompany Europe BVBA"}
                        10881{$officeLocation="parentCompany (Milano) Europe, S.r.l."}
                        10882{$officeLocation="parentCompany (Sondrio) Europe, S.r.l."}
                        10883{$officeLocation="parentCompany (Beijing)Â Refrigeration Equipment Co., Ltd."}
                        10884{$officeLocation="parentCompany (Shanghai) Refrigeration Equipment Co., Ltd."}
                        10887{$officeLocation="parentCompany Australia (Pty.) Ltd."}
                        10888{$officeLocation="subsidiaryCompany2, Inc."}
                        10889{$officeLocation="parentCompany Dry Cooling, Inc."}
                        10891{$officeLocation="subsidiaryCompany4"}
                        10893{$officeLocation="parentCompany Europe A/S"}
                        10894{$officeLocation="parentCompany Brasil"}
                        10895{$officeLocation="subsidiaryCompany3"}
                        10896{$officeLocation="parentCompany Alcoil, Inc."}
                        10897{$officeLocation="parentCompany Air Cooling Systems (Jiaxing) Co., Ltd."}
                        10898{$officeLocation="parentCompany Iowa Sales & Engineering"}
                        10899{$officeLocation="parentCompany LMP"}
                        10900{$officeLocation="parentCompany Select Tech"}
                        10901{$officeLocation="parentCompany Europe GmbH"}
                        11959{$officeLocation="subsidiaryCompany2 Asia Pacific Sdn Bhd"}
                        11960{$officeLocation="subsidiaryCompany2 (Shanghai) Cooling Tower Co., Ltd."}
                        11979{$officeLocation="parentCompany Middle East DMCC"}
                        11981{$officeLocation="parentCompany S.A. (Pty.) Ltd."}
                        11986{$officeLocation="parentCompany Newton"}
                    
                    }
                    $reviewedFieldValues = [PSCustomObject]@{
                        officeLocation        = $officeLocation
                        validDepartment       = $fieldValue.Value
                    }
                $results.add($reviewedFieldValues)
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


SignatureBlock

