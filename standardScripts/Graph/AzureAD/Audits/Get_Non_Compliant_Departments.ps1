#Jira Header
$Text = ‘david.drosdick@Domain.extension1:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}

$Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $headers

$fieldName = "Office Location and Department"

$foundField = $fields | Where-Object {($_.Name -eq $fieldName)}


If ($foundField -ne $null)
{
    $reviewingField = $fields | Where-Object {($_.Name -eq $fieldName)}

    $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $headers


    $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $headers

    $reviewedFieldValues = @()

    If ($reviewingFieldValues.Total -ge 100)
    {
        $uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

        for ($count = 0; $count -lt $reviewingFieldValues.Total; $count += 100) 
        {
            $uri = $uriTemplate -f $count
            $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
            ForEach ($fieldValue in $fieldValues.values)
            {
                $reviewedFieldValues += [PSCustomObject]@{
                    FieldName   = $fieldName
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
        $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
        ForEach ($fieldValue in $fieldValues.values)
            {
                $reviewedFieldValues+= [PSCustomObject]@{
                    FieldName   = $fieldName
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
    Write-Output "Field Name not found"
}



$userObject = @()   


$allUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated")} | select-object -Property "OnPremisesSyncEnabled", "ID", "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "Department", "Manager", "BusinessPhones", "UsageLocation"| Sort-Object -Property DisplayName

ForEach ($user in $allUsers)
{
    $userOfficeLocationFieldData = $reviewedFieldValues | Where-Object {($_.Value -eq $($user.OfficeLocation))}
    $userOfficeLocationCompliantDepartments = $reviewedFieldValues | Where-Object {($_.OptionID -eq $($userOfficeLocationFieldData.id))}
    If ($user.Department -notin $($userOfficeLocationCompliantDepartments.value))
    {
        try
        {
            $managerID = Get-MGBetaUserManager -userid $user.Id -ErrorAction Stop
            $manager = Get-MGBetaUser -userid $managerID.ID -ErrorAction Stop
            $managerOfficeLocationFieldData = $reviewedFieldValues | Where-Object {($_.Value -eq $($manager.OfficeLocation))}
            $managerOfficeLocationCompliantDepartments = $reviewedFieldValues | Where-Object {($_.OptionID -eq $($managerOfficeLocationFieldData.id))}
            If ($manager.Department -in $($managerOfficeLocationCompliantDepartments.value))
            {
                $Compliant = $True
            }
            Else 
            {
                $Compliant = $False
            }
            $userObject += [PSCustomObject]@{
                SynchingLocal               = $user.OnPremisesSyncEnabled
                ID                          = $user.ID
                DisplayName                 = $user.DisplayName
                Department                  = $user.Department
                UserPrincipalName           = $user.UserPrincipalName
                CompanyName                 = $user.CompanyName
                Country                     = $user.Country
                UsageLocation               = $user.UsageLocation
                OfficeLocation              = $user.OfficeLocation
                BusinessPhones              = $user.BusinessPhones[0]
                ManagerDisplayName          = $manager.DisplayName
                ManagerID                   = $manager.ID
                ManagerUserPrincipalName    = $manager.UserPrincipalName
                ManagerOfficeLocation       = $manager.OfficeLocation
                ManagerDepartment           = $manager.Department 
                ManagerCompliant            = $Compliant
                }   
    
        }
    catch
        {
         
        $userObject += [PSCustomObject]@{
            SynchingLocal               = $user.OnPremisesSyncEnabled
            ID                          = $user.ID
            DisplayName                 = $user.DisplayName
            Department                  = $user.Department
            UserPrincipalName           = $user.UserPrincipalName
            CompanyName                 = $user.CompanyName
            Country                     = $user.Country
            UsageLocation               = $user.UsageLocation
            OfficeLocation              = $user.OfficeLocation
            BusinessPhones              = $user.BusinessPhones[0]
            ManagerDisplayName          = "No Manager"
            ManagerID                   = "No Manager"
            ManagerUserPrincipalName    = "No Manager"
            ManagerOfficeLocation       = "No Manager"
            ManagerDepartment           = "No Manager"
            ManagerCompliant            = "No Manager"
            }


        }    
    }
    Else
    {
       $null
    }
}

SignatureBlock

