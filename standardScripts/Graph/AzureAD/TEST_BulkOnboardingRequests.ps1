$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}



#How to get all new user onboarding requests
$pendingRequests = Invoke-RestMethod -Method get -uri 'https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=summary%20~%20"TEST%20Onboard%20Request"' -Headers $headers


foreach ($ticket in $pendingRequests.issues)
    {
        
        
        if ($ticket.fields.status.name -eq "Resolved")
        {
            $null
        }
        Else
        {

            #connect to Exchange Online
            $exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
            $exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
            $exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
            Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

            #The Tenant ID from App Registrations
            $tenantId = $tenantIDString

            # Construct the authentication URL
            $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
            #The Client ID from App Registrations
            $clientId = $appIDString
 

 
            #The Client ID from certificates and secrets section
            $clientSecret = $apiKey 
 
            # Construct the body to be used in Invoke-WebRequest
            $body = @{
                client_id     = $clientId
                scope         = "https://graph.microsoft.com/.default"
                client_secret = $clientSecret
                grant_type    = "client_credentials"
            }
 
            # Get Authentication Token
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
 
            # Extract the Access Token
            $token = ($tokenRequest.Content | ConvertFrom-Json).access_token

            Connect-MGGraph -AccessToken $token
            
            write-host $ticket.key
            $key = $ticket.key 
            $Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key" -Headers $headers
            $NewForm = ConvertTo-Json $Form
            $NewForm2 = ConvertFrom-Json $NewForm
            $uData = $NewForm2.fields

            #Sets the temporary password for new users

            $date = $uData.customfield_10613
            $date = get-date $date

            $DoW = $date.DayOfWeek.ToString()
            $Month = (Get-date $udata.customfield_10613 -format "MM").ToString()
            $Day = $date.Day.ToString()
            $pw = $DoW+$Month+$Day+"!"


             $PasswordProfile = @{
    
                            Password = $pw
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
                    $gname = $udata.customfield_10771
                    $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID
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
                    $gname = $udata.customfield_10772
                    $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID
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
                    $gname = $udata.customfield_10773
                    $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
                    $userObjID = (Get-MGUser -UserID $emailAddr).ID
                    try 
                        {
                        New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID 
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
        
        #Close the Ticket with a comment      
        # Create the JSON payload
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Resolved via automated process. Password is $pw"
                    }
                }
            ]
        },
    "transition": {
        "id": "761"
    }
}
"@ 



            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers

            Disconnect-MgGraph
            Disconnect-ExchangeOnline -confirm:$false
        
        
        }   

    }
# SIG # Begin signature block#Script Signature# SIG # End signature block










