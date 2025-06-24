$Text = ‘david.drosdick@Domain.extension1:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}



#How to get all new user onboarding requests
$pendingRequests = Invoke-RestMethod -Method get -uri 'https://parentCompany.atlassian.net/rest/api/2/search?jql=summary%20~%20"Onboard%20Request"' -Headers $headers


foreach ($ticket in $pendingRequests.issues)
    {
        
        if ($ticket.fields.status.name -eq "Resolved")
        {
            $null
        }
        Else
        {
            write-host $ticket.key
            $key = $ticket.key 
            $Form = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key" -Headers $headers
            $NewForm = ConvertTo-Json $Form
            $NewForm2 = ConvertFrom-Json $NewForm
            $uData = $NewForm2.fields


            #Sets the temporary password for new users

            $PasswordProfile = @{
    
                Password = 'parentCompany123!'
                  }

            #Standardizes and Sanitizes the User Information 
            $firstName = $uData.customfield_10768.substring(0,1).toUpper()+$uData.customfield_10768.substring(1).toLower()
            $firstname = $firstname.trim()
            $lastName = $uData.customfield_10723.substring(0,1).toUpper()+$uData.customfield_10723.substring(1).toLower()
            $lastname = $lastname.trim()
            $lastname = $lastname.replace(' ','')
            $jobtitle = $uData.customfield_10695.substring(0,1).toUpper()+$uData.customfield_10695.substring(1).toLower()
            $jobtitle = $jobtitle.trim()
            $TextInfo = (Get-Culture).TextInfo
            $jobtitle = $TextInfo.ToTitleCase($jobtitle)

            $otherEmail = $udata.customfield_10727.trim()


            #Set their email address with proper casing
            $emailAddr = $firstName + "." +$lastName + $uData.customfield_10766

            #Set their mail nickname with proper casing
            $mailNN = $firstname + "."+$lastName
            $mailNN = $mailNN.trim()

            #Set their displayname with proper casing 
            $displayName = $firstname + " " +$lastname
            $displayName = $displayName.trim()




            New-MGuser -AccountEnabled  `
            -ShowInAddressList `
            -UsageLocation $udata.customfield_10777 `
            -Country $udata.customfield_10778 `
            -DisplayName $displayName `
            -UserPrincipalName $emailAddr `
            -BusinessPhones $uData.customfield_10767`
            -CompanyName $uData.customfield_10756.value`
            -JobTitle $jobtitle `
            -PasswordProfile $PasswordProfile `
            -Department $uData.customfield_10697.value`
            -MailNickName $mailNN `
            -GivenName $firstName `
            -EmployeeHireDate $uData.customfield_10613 `
            -OfficeLocation $uData.customfield_10776 `
            -EmployeeType $uData.customfield_10736.value`
            -Surname $lastName `
            -OtherMails $otherEmail `

            $time = Get-Date
            Write-Host "Waiting 1 minute at $time to allow for license assignment and group creation"
            Start-Sleep -Seconds 60


            #Pull the Manager ID user information to bind to the new user
            $tempVar = $uData.customfield_10765.displayName
            $managerID = (Get-MGUser -Search "DisplayName:$tempvar" -ConsistencyLevel:eventual -top 1).ID


            #Retrieve the ObjectID of the created user to update fields that can only be done after creation
            $userObjID = (Get-MGUser -UserID $emailAddr).ID


              #Sets the Manager ID
              Set-MgUserManagerByRef -UserId $emailAddr `
                -AdditionalProperties @{
                     "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
                }




             #Sets Licensing in M365
                if ($uData.customfield_10774 -eq "" -or $uData.customfield_10774 -eq $null) 
                {
                    Write-Host "Null"
                } 
                else 
                {
                    $sku1 = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $uData.customfield_10774
                    Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()


                }


                if ($uData.customfield_10775 -eq "" -or $uData.customfield_10775 -eq $null) 
                {
                    Write-Host "Null"
                } 
                else 
                {
                    $sku1 = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $uData.customfield_10775
                    Set-MgUserLicense -UserId $emailAddr -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()


                }






            #Sets Groups in AzureAD and ExchangeOnline

            #Group1
                if ($uData.customfield_10771 -eq "" -or $uData.customfield_10771 -eq $null) 
                {
                    Write-Host "Null"
                } 
    
                else 
                {
                    $groupObjID = (Get-AzureADGroup -SearchString $uData.customfield_10771).objectID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        Add-AzureADGroupMember -ObjectId $groupObjID -RefObjectId $userObjID 
                        } 
                    catch 
                        {
                        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $uData.customfield_10771 -member $emailAddr -BypassSecurityGroupManagerCheck
                            }
                        catch
                            {
                            Write-Host "Unable to add $emailAddr to "$uData.customfield_10771". Please do this manually."
                            }
                        }
                }

            #Group2

                    if ($uData.customfield_10772 -eq "" -or $uData.customfield_10772 -eq $null) 
                {
                    Write-Host "Null"
                } 
    
                else 
                {
                    $groupObjID = (Get-AzureADGroup -SearchString $uData.customfield_10772).objectID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        Add-AzureADGroupMember -ObjectId $groupObjID -RefObjectId $userObjID 
                        } 
                    catch 
                        {
                        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $uData.customfield_10772 -member $emailAddr -BypassSecurityGroupManagerCheck
                            }
                        catch
                            {
                            Write-Host "Unable to add $emailAddr to "$uData.customfield_10772". Please do this manually."
                            }
                }
                }

            #Group3    
                    if ($uData.customfield_10773 -eq "" -or $uData.customfield_10773 -eq $null) 
                {
                    Write-Host "$Null"
                } 
    
                else 
                {
                    $groupObjID = (Get-AzureADGroup -SearchString $uData.customfield_10773).objectID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        Add-AzureADGroupMember -ObjectId $groupObjID -RefObjectId $userObjID 
                        } 
                    catch 
                        {
                        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
                        try
                            {
                            Add-DistributionGroupMember -Identity $uData.customfield_10773 -member $emailAddr -BypassSecurityGroupManagerCheck
                            }
                        catch
                            {
                            Write-Host "Unable to add $emailAddr to "$uData.customfield_10773". Please do this manually."
                            }
                         }

                }
        #add the New User to the MFA Enabled Group
        New-MgGroupMember -GroupId "Group10" -DirectoryObjectId $userObjID       
        }   

    }
SignatureBlock

