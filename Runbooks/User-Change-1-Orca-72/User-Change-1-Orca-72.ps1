param(
    [string] $Key
)
function Set-PrivateErrorJiraRunbook{
    [CmdletBinding()]
    param(
    [Parameter(ParameterSetName = 'Full', Position = 0)]
    [switch]$Continue,
    [Parameter(Position = 1 , HelpMessage = "Enter the Ticket Key. Example: GHD-44881`n`nEnter")]
    [string] $key,
    [Parameter(Position = 2 , HelpMessage = "Enter your Jira Header here")]
    [hashtable] $jiraHeader
    )
    $currTime = Get-Date -format "HH:mm"
    $errorLog = [PSCustomObject]@{
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] | Select-Object * #gets the most recent error
    }

        
    # Initialize an array to store formatted content
    $jbody = @()

    # Loop through each errorLog item and format it as a JSON paragraph

        $paragraphs = @(
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Time Failed: $($errorLog.timeToFail)"
                    }
                )
            },
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = "Reason Failed: $($errorLog.reasonFailed)"
                    }
                )
            }
        )
        
        $jbody += $paragraphs


    # Create the final JSON payload
    $jsonPayload = @{
        body = @{
            type = "doc"
            version = 1
            content = $jbody
        }
        properties = @(
            @{
                key = "sd.public.comment"
                value = @{
                    internal = $true
                }
            }
        )
    }
    # Convert the PowerShell object to a JSON string
    $jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10
    # Perform the API call
    try {
        $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $jiraHeader
        if ($response){
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] Internal Comment Successfully Made with Error Details"
        }
    } catch {
        Write-Output "API call failed: $($_.Exception.Message)"
        Write-Output "Payload: $jsonPayload"
    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | Failed. Details Below:"
    Write-Output $errorLog
    switch ($Continue){
        $False {exit 1}
        Default {$null}
    }
}
function Set-PublicErrorJira{
[CmdletBinding()]
param(
[Parameter(ParameterSetName = 'Full', Position = 0)]
[switch]$Continue,
[Parameter(Position = 1, HelpMessage = "Enter the message to include with your Jira Ticket!")]
[string] $publicErrorMessage,
[Parameter(Position = 2 , HelpMessage = "Enter the Ticket Key. Example: GHD-44881`n`nEnter")]
[string] $key,
[Parameter(Position = 3 , HelpMessage = "Enter your Jira Header here")]
[hashtable] $jiraHeader
)
    $jsonPayload = @"
    {
    "update": {
        "comment": [
            {
                "add": {
                    "body": "$publicErrorMessage"
                }
            }
        ]
    },
    "transition": {
    "id": "981"
    }
}
"@
        Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $jiraHeader
        
    switch ($Continue){
    $False {$null}
    Default {Continue}
    }
}

function Set-SuccessfulCommentRunbook {
[CmdletBinding()]
param(
[Parameter(ParameterSetName = 'Full', Position = 0)]
[switch]$Continue,
[Parameter(Position = 1, HelpMessage = "Enter the message to include with your Jira Ticket!")]
[string] $successMessage,
[Parameter(Position = 2 , HelpMessage = "Enter the Ticket Key. Example: GHD-44881`n`nEnter")]
[string] $key,
[Parameter(Position = 3 , HelpMessage = "Enter your Jira Header here")]
[hashtable] $jiraHeader
)
$jsonPayload = @"
{
"update": {
"comment": [
    {
        "add": {
            "body": "$successMessage"
        }
    }
]
},
"transition": {
"id": "961"
}
}
"@
try {
    $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $jiraHeader
    if ($response){
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | Internal Comment Successfully Made with Error Details"
}
} 
catch{
    Write-Output "API call failed: $($_.Exception.Message)"
    Write-Output "Payload: $jsonPayload"
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | Failed. Details Below:"
    Write-Output $errorLog
}
switch ($Continue){
    $False {exit 1}
    Default {Continue}
}
}

function Format-Name {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, HelpMessage = "Enter the Input Name to Format", Mandatory = $true)]
        [string]$inputName
    )
    # Trim leading and trailing spaces
    $inputName = $inputName.Trim()
    $inputNameFormatted = $null

    # Handle names with spaces
    if ($inputName -match " ") {
        $splitInputName = $inputName.Split(" ") | Where-Object { $_ -ne "" } # Remove empty strings caused by extra spaces
        $runningStringPre = $null
        foreach ($splitName in $splitInputName) {
            # Format each part of the name
            if ($splitName.Length -gt 1) {
                $formattedString = $splitName.Substring(0, 1).ToUpper() + $splitName.Substring(1).ToLower()
            } else {
                $formattedString = $splitName.ToUpper() # Handle single-character cases
            }

            # Combine formatted strings
            if ($null -ne $runningStringPre) {
                $runningStringPre = $runningStringPre + " " + $formattedString
            } else {
                $runningStringPre = $formattedString
            }
        }
        $runningStringPost = $runningStringPre
        return $runningStringPost
    }
    # Handle hyphenated names
    if ($inputName -match "-") {
        $splitInputName = $inputName.Split("-")
        if ($splitInputName.Count -eq 2) {
            $formattedString = $splitInputName[0].Substring(0, 1).ToUpper() + $splitInputName[0].Substring(1).ToLower() + "-" +
                               $splitInputName[1].Substring(0, 1).ToUpper() + $splitInputName[1].Substring(1).ToLower()
            return $formattedString
        } else {
            Write-Error "Hyphenated name format is invalid."
        }
    }
    # Handle single-part names
    if ($inputName.Length -gt 1) {
        $inputNameFormatted = $inputName.Substring(0, 1).ToUpper() + $inputName.Substring(1).ToLower()
    } else {
        $inputNameFormatted = $inputName.ToUpper() # Handle single-character names
    }
    return $inputNameFormatted
}

Import-module Az.Accounts
Import-Module Az.KeyVault
Connect-AzAccount -subscription $subscriptionID -Identity
Connect-MGGraph -NoWelcome -Identity

#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText

$hybridWorkerGroup      = $null
$hybridWorkerCred       = $null
$paramsFromTicket = @{}
$extensionAttributes = @{}


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
#Pull the values from Jira
$TicketNum = $Key
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $jiraHeader


$jiraUserToModify   = $form.fields.customfield_10781.emailAddress
$newFirstName       = $form.fields.customfield_10722
$newSurName         = $form.fields.customfield_10723
$newSupervisor      = $form.fields.customfield_10765.emailaddress
$newJobTitle        = $form.fields.customfield_10695
$newCompany         = $form.fields.customfield_10756.value
$shopOrOffice       = $form.fields.customfield_10698.value
$isTransfer         = $form.fields.customfield_10988.value
$officeAppNeeds     = $form.fields.customfield_10751.ID
$officeAppBitType   = $form.fields.customfield_10986.value
$referenceUser = Get-MgBetaUser -userid $jiraUserToModify -property "displayName, userprincipalname, givenname, surname","id","Department","CompanyName" , "JobTitle" , "OfficeLocation", "OnPremisesSyncEnabled", "OnPremisesDomainName" , "OnPremisesSamAccountName" , "OnPremisesExtensionAttributes" | Select-Object *
$originGraphUserID = $referenceUser.ID

#if the user selects 'NO' for 'Is Transfer' there still might be some items that require a transfer to occur.
if ($isTransfer -eq "NO"){
    if ($null -eq $form.fields.customfield_10698.value){
        Write-Output "Determining if Shop or Office, nothing selected in the Jira Ticket."
        If ($null -ne $referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute1){
            $shopOrOffice = $referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute1
            Write-Output "$($referenceUser.DisplayName) is going to be $shopOrOffice, pulled from their existing User Account"
        }
        Else{
            Write-OUtput "$($referenceUser.DisplayName) had nothing selected or configured. We have defaulted to shop"
            $shopOrOffice = "Shop"
        }
    }
    else{
        $ShopOrOffice = $form.fields.customfield_10698.value
        if ($shopOrOffice -eq "Shop"){
            if($officeAppNeeds -eq '10775'){
                $shopOrOffice = "Shop Office"
                if ($referenceUser.OnPremisesSyncEnabled -eq $true){
                $isTransfer = "NO"
                }
                else{
                    $isTransfer = "YES"
                }
            }
        }
        ElseIf(($shopOrOffice -eq 'Office') -and ($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute1 -eq 'Shop')){
            $isTransfer = "Yes"
        }
        Write-Output "Is Transfer: $isTransfer"
        Write-output "$($referenceUser.DisplayName) is going to be $shopOrOffice per their jira ticket"
    }
}

#Pull the existing user from Graph to determine their type.
$originGraphUserID = $referenceUser.ID
switch ($isTransfer) {
    "YES" {Write-Output "This is a Transfer: $isTransfer"
    $newOfficeLocation  =   $form.fields.customfield_10987.value
    $newDepartment      =   $form.fields.customfield_10987.child.value
    $originLocation =          $referenceUser.OfficeLocation
    $originParametersUser = @{}
    $originParametersObject = @{}
    $destinationLADParameters = @{}
    $destinationGraphParameters = @{}
    $destinationLADExtensionAttributes = @{}

    If ($referenceUser.OnPremisesSyncEnabled -ne $False){
        if ($null -ne $referenceUser.OnPremisesDomainName){
            Write-Output "User is Synching"
            Write-Output "User To Modify:       $jiraUserToModify"
            $samAccountName = $referenceUser.OnPremisesSAMAccountName
            $refUserSynching = $true
            $originSynching = $true
            switch ($isTransfer){
                "Yes"{
                    $originRunbook = "User-Transfer-2-Origin-72"
                    $destinationRunbook = "User-Transfer-2-Destination"
                }
                Default{
                    $runbook = "User-Change-2-LocalAD-72"
                }
            }
        }
    else{
        Write-Output "User is Graph Only"
        Write-Output "User To Modify:       $jiraUserToModify"
        switch ($isTransfer){
            "Yes"{
                $originRunbook = "User-Transfer-2-Origin-72"
                $destinationRunbook = "User-Transfer-2-Destination"
            }
            Default{
                $runbook = "User-Change-2-Graph"  
            }
        }
        $refUserSynching = $false
        $originSynching = $false
        }
    }
    else{
        Write-Output "User is Graph Only"
        Write-Output "User To Modify:       $jiraUserToModify"
        $refUserSynching = $false
        $originSynching = $false
        switch ($isTransfer){
            "Yes"{
                $originRunbook = "User-Transfer-2-Origin-72"
                $destinationRunbook = "User-Transfer-2-Destination"
            }
            Default {
                $runbook = "User-Change-2-Graph"
            }
        }
    }

    #For specific variables related to their origin location if they are synching and need modified.
    switch ($originLocation) {
        "unique-Office-Location-0"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup  = "Azure-DC01"
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.COM")
                    $originParametersObject.Add("Server","uniqueParentCompany.COM")
                    $originParametersObject.Add("TargetPath","OU=XXX-Closed Accounts,DC=uniqueParentCompany,DC=COM")
    
                 }
                $false {
                    $null
                }
            }
        }
        "unique-Office-Location-1"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = "US-CA-VS-DC01"
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyWest.COM")
                    $originParametersObject.Add("Server","uniqueParentCompanyWest.COM")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")
                 }
                $false {
                $null
                }
            }
        }
        "unique-Office-Location-2"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyMW.COM")
                    $originParametersObject.Add("Server","uniqueParentCompanyMW.COM")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")

                 }
                $false {
                    $null
                }
            }
        }
        "unique-Office-Location-3"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyIA.COM")
                    $originParametersObject.Add("Server","uniqueParentCompanyIA.COM")  
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")
                 }
                $false {
                    $null
                }
            }
        }
        "unique-Company-Name-20"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","anonSubsidiary-1CORP.COM")
                    $originParametersObject.Add("Server","anonSubsidiary-1CORP.COM")  
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")  
                    
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-7"{
            switch ($refUserSynching) {
                $true { 
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.BE")
                    $originParametersObject.Add("Server","uniqueParentCompany.BE") 
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")  
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-6"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.IT")
                    $originParametersObject.Add("Server","uniqueParentCompany.IT") 
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")
                 }
                $false {
                    $null
                }
            }
        }
        "uniqueParentCompany (Sondrio) Europe, S.rl.l."{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.IT")
                    $originParametersObject.Add("Server","uniqueParentCompany.IT")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU") 
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-8"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyCHINA.com")
                    $originParametersObject.Add("Server","uniqueParentCompanyCHINA.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU") 
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-9"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyCHINA.com")
                    $originParametersObject.Add("Server","uniqueParentCompanyCHINA.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU") 
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-3"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.com.au")
                    $originParametersObject.Add("Server","uniqueParentCompany.com.au")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")  
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-18"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","anonSubsidiary-1.com") 
                    $originParametersObject.Add("Server","anonSubsidiary-1.com") 
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")  
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-5"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "DryCooling-Hybrid-Worker"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyDC.com")
                    $originParametersObject.Add("Server","uniqueParentCompanyDC.com") 
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")  
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-21"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = "US-NC-VS-DC01"
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@Domain.extension2")
                    $originParametersObject.Add("Server","@Domain.extension2") 
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")   
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-27"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompanyMW.com")
                    $originParametersObject.Add("Server","uniqueParentCompanyMW.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")     

                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-6"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.DK")
                    $originParametersObject.Add("Server","uniqueParentCompany.DK")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")   
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-4"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","uniqueParentCompany.com.br")
                    $originParametersObject.Add("Server","uniqueParentCompany.com.br")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")     
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-16"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","anonSubsidiary-1.com")
                    $originParametersObject.Add("Server","anonSubsidiary-1.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")   
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-2"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "Alcoil-Hybrid-Worker"
                    $originParametersUser.Add("Identity",$SAMAccountNAme) 
                    $originParametersUser.Add("Server","@uniqueParentCompany-alcoil.com")
                    $originParametersObject.Add("Server","@uniqueParentCompany-alcoil.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")    
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-18"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@uniqueParentCompanyacs.cn")   
                    $originParametersObject.Add("Server","@uniqueParentCompanyacs.cn")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")  
                    
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-10"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = "US-MN-VS-DC01"
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@uniqueParentCompanymn.com")    
                    $originParametersObject.Add("Server","@uniqueParentCompanymn.com")  
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-11"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@uniqueParentCompanylmp.ca")  
                    $originParametersObject.Add("Server","@uniqueParentCompanylmp.ca")   
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Office-Location-21"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@uniqueParentCompanyselect.com")
                    $originParametersObject.Add("Server","@uniqueParentCompanyselect.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")   
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-8"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "$origCred"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@uniqueParentCompany.de")
                    $originParametersObject.Add("Server","@uniqueParentCompany.de")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")        
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-17"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@anonSubsidiary-1.com")
                    $originParametersObject.Add("Server","@anonSubsidiary-1.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")    
                 }
                 $false {
                    $null
                }
            }
        }
        "unique-Company-Name-16"{
            switch ($refUserSynching) {
                $true {
                    $currentUserID = $jiraUserToModify
                    $originHybridWorkerGroup = $null
                    $originHybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                    $originParametersUser.Add("Identity",$SAMAccountNAme)
                    $originParametersUser.Add("Server","@anonSubsidiary-1.com")
                    $originParametersObject.Add("Server","@anonSubsidiary-1.com")
                    $originParametersObject.Add("TargetPath","$OriginLocationNonSyncOU")     
                 }
                 $false {
                    $null
                }
            }
        }
        Default {Write-Output "There is no matching location."}
    }
    #For Specific Variables at the new AD they will be created on
    switch ($newOfficeLocation) {
        "unique-Office-Location-0"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup  = "Azure-DC01"
                    $destinationHybridWorkerCred   = "Credential"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.COM")
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","14107562600")
                    $destinationGraphParameters.Add("UsageLocation","US")
    
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","14107562600")
                    $destinationGraphParameters.Add("UsageLocation","US")
                    $upnSuffix = "@uniqueParentCompany.com"
                }
            }
        }
        "unique-Office-Location-1"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = "US-CA-VS-DC01"
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyWest.COM")
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanywest.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber2")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanywest.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber2")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-2"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyMW.COM")
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","phoneNumber3")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","phoneNumber3")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-3"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyIA.COM") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyia.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber4")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyia.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber4")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-20"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "anonSubsidiary-1-Hybrid-Worker"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","anonSubsidiary-1CORP.COM")  
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1corp.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber5")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1corp.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber5")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-7"{
            switch ($shopOrOffice) {
                "Office" { 
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.BE")
                    $destinationLADExtensionAttributes.Add("co","Belgium")
                    $destinationLADExtensionAttributes.Add("countryCode","056")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.be"
                    $destinationGraphParameters.Add("Country","BE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber6")
                    $destinationGraphParameters.Add("UsageLocation","BE")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.be"
                    $destinationGraphParameters.Add("Country","BE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber6")
                    $destinationGraphParameters.Add("UsageLocation","BE")
                }
            }
        }
        "unique-Office-Location-6"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.IT")
                    $destinationLADExtensionAttributes.Add("co","Italy")
                    $destinationLADExtensionAttributes.Add("countryCode","380")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                }
            }
        }
        "uniqueParentCompany (Sondrio) Europe, S.rl.l."{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.IT") 
                    $destinationLADExtensionAttributes.Add("co","Italy")
                    $destinationLADExtensionAttributes.Add("countryCode","380")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                    
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                }
            }
        }
        "unique-Office-Location-8"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyCHINA.com")
                    $destinationLADExtensionAttributes.Add("co","CN")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","8.61E+11")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","8.61E+11")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        "unique-Office-Location-9"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyCHINA.com")
                    $destinationLADExtensionAttributes.Add("co","CN")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        "unique-Company-Name-3"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.com.au") 
                    $destinationLADExtensionAttributes.Add("co","AU")
                    $destinationLADExtensionAttributes.Add("countryCode","036")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.au"
                    $destinationGraphParameters.Add("Country","AU")
                    $destinationGraphParameters.Add("BusinessPhones","6.10E+11")
                    $destinationGraphParameters.Add("UsageLocation","AU")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.au"
                    $destinationGraphParameters.Add("Country","AU")
                    $destinationGraphParameters.Add("BusinessPhones","6.10E+11")
                    $destinationGraphParameters.Add("UsageLocation","AU")
                }
            }
        }
        "unique-Company-Name-18"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "anonSubsidiary-1-Hybrid-Worker"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","anonSubsidiary-1.com") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber9")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber9")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-5"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "DryCooling-Hybrid-Worker"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyDC.com") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanydc.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber10")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanydc.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber10")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-21"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = "US-NC-VS-DC01"
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@Domain.extension2") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@Domain.extension2"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber11")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@Domain.extension2"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber11")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-27"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompanyMW.com")  
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber12")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber12")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-6"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.DK")  
                    $destinationLADExtensionAttributes.Add("co","Denmark")
                    $destinationLADExtensionAttributes.Add("countryCode","208")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.dk"
                    $destinationGraphParameters.Add("Country","DK")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber13")
                    $destinationGraphParameters.Add("UsageLocation","DK")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.dk"
                    $destinationGraphParameters.Add("Country","DK")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber13")
                    $destinationGraphParameters.Add("UsageLocation","DK")
                }
            }
        }
        "unique-Company-Name-4"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","uniqueParentCompany.com.br")  
                    $destinationLADExtensionAttributes.Add("co","Brazil")
                    $destinationLADExtensionAttributes.Add("countryCode","076")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.br"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.br"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                }
            }
        }
        "unique-Office-Location-16"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","anonSubsidiary-1.com")  
                    $destinationLADExtensionAttributes.Add("co","Brazil")
                    $destinationLADExtensionAttributes.Add("countryCode","076")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                }
            }
        }
        "unique-Company-Name-2"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "Alcoil-Hybrid-Worker"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme) 
                    $destinationLADParameters.Add("Server","@uniqueParentCompany-alcoil.com")   
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany-alcoil.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber15")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany-alcoil.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber15")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-18"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@uniqueParentCompanyacs.cn")   
                    $destinationLADExtensionAttributes.Add("co","China")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyacs.cn"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber16")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyacs.cn"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber16")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        "unique-Company-Name-10"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = "US-MN-VS-DC01"
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@uniqueParentCompanymn.com")    
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymn.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber17")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymn.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber17")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-11"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@uniqueParentCompanylmp.ca")  
                    $destinationLADExtensionAttributes.Add("co","Canada")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanylmp.ca"
                    $destinationGraphParameters.Add("Country","CA")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber18")
                    $destinationGraphParameters.Add("UsageLocation","CA")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanylmp.ca"
                    $destinationGraphParameters.Add("Country","CA")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber18")
                    $destinationGraphParameters.Add("UsageLocation","CA")
                }
            }
        }
        "unique-Office-Location-21"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@uniqueParentCompanyselect.com")   
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyselect.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber19")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyselect.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber19")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-8"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "$destCred"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@uniqueParentCompany.de")     
                    $destinationLADExtensionAttributes.Add("co","Germany")
                    $destinationLADExtensionAttributes.Add("countryCode","276")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.de"
                    $destinationGraphParameters.Add("Country","DE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber20")
                    $destinationGraphParameters.Add("UsageLocation","DE")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.de"
                    $destinationGraphParameters.Add("Country","DE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber20")
                    $destinationGraphParameters.Add("UsageLocation","DE")
                }
            }
        }
        "unique-Company-Name-17"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "anonSubsidiary-1-Hybrid-Worker"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@anonSubsidiary-1.com")    
                    $destinationLADExtensionAttributes.Add("co","Malaysia")
                    $destinationLADExtensionAttributes.Add("countryCode","458")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","MY")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber21")
                    $destinationGraphParameters.Add("UsageLocation","MY")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","MY")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber21")
                    $destinationGraphParameters.Add("UsageLocation","MY")
                }
            }
        }
        "unique-Company-Name-16"{
            switch ($shopOrOffice) {
                "Office" {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerCred   = "anonSubsidiary-1-Hybrid-Worker"
                    $destinationLADParameters.Add("Identity",$SAMAccountNAme)
                    $destinationLADParameters.Add("Server","@anonSubsidiary-1.com")    
                    $destinationLADExtensionAttributes.Add("co","China")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        Default {Write-Output "There is no matching location."}
    }
    <#
    #To Handle Shop/Office Transfers
    switch ($originLocation) {
        "unique-Office-Location-0"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup  = "Azure-DC01"
                    $destinationHybridWorkerUser = "$userNameAdmin@uniqueParentCompany.com"
                    $destinationHybridWorkerKeyVault = "TTWorker"
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.COM")
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","14107562600")
                    $destinationGraphParameters.Add("UsageLocation","US")
    
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","14107562600")
                    $destinationGraphParameters.Add("UsageLocation","US")
                    $upnSuffix = "@uniqueParentCompany.com"
                }
            }
        }
        "unique-Office-Location-1"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = "US-CA-VS-DC01"
                    $destinationHybridWorkerUser = "uniqueParentCompanyadmin@uniqueParentCompany-West.uniqueParentCompanyW.com"
                    $destinationHybridWorkerKeyVault = "US-CA-VS-DC01"
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyWest.COM")
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanywest.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber2")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanywest.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber2")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-2"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyMW.COM")
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","phoneNumber3")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","phoneNumber3")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-3"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyIA.COM") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyia.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber4")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyia.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber4")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-20"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","anonSubsidiary-1CORP.COM")  
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1corp.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber5")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1corp.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber5")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-7"{
            switch ($shopOrOffice) {
                Default { 
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.BE")
                    $destinationLADExtensionAttributes.Add("co","Belgium")
                    $destinationLADExtensionAttributes.Add("countryCode","056")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.be"
                    $destinationGraphParameters.Add("Country","BE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber6")
                    $destinationGraphParameters.Add("UsageLocation","BE")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.be"
                    $destinationGraphParameters.Add("Country","BE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber6")
                    $destinationGraphParameters.Add("UsageLocation","BE")
                }
            }
        }
        "unique-Office-Location-6"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.IT")
                    $destinationLADExtensionAttributes.Add("co","Italy")
                    $destinationLADExtensionAttributes.Add("countryCode","380")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                }
            }
        }
        "uniqueParentCompany (Sondrio) Europe, S.rl.l."{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.IT") 
                    $destinationLADExtensionAttributes.Add("co","Italy")
                    $destinationLADExtensionAttributes.Add("countryCode","380")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                    
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.it"
                    $destinationGraphParameters.Add("Country","IT")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber7")
                    $destinationGraphParameters.Add("UsageLocation","IT")
                }
            }
        }
        "unique-Office-Location-8"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyCHINA.com")
                    $destinationLADExtensionAttributes.Add("co","CN")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","8.61E+11")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","8.61E+11")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        "unique-Office-Location-9"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyCHINA.com")
                    $destinationLADExtensionAttributes.Add("co","CN")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanychina.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        "unique-Company-Name-3"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.com.au") 
                    $destinationLADExtensionAttributes.Add("co","AU")
                    $destinationLADExtensionAttributes.Add("countryCode","036")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.au"
                    $destinationGraphParameters.Add("Country","AU")
                    $destinationGraphParameters.Add("BusinessPhones","6.10E+11")
                    $destinationGraphParameters.Add("UsageLocation","AU")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.au"
                    $destinationGraphParameters.Add("Country","AU")
                    $destinationGraphParameters.Add("BusinessPhones","6.10E+11")
                    $destinationGraphParameters.Add("UsageLocation","AU")
                }
            }
        }
        "unique-Company-Name-18"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","anonSubsidiary-1.com") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber9")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber9")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-5"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyDC.com") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanydc.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber10")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanydc.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber10")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-21"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = "US-NC-VS-DC01"
                    $destinationHybridWorkerUser = "uniqueParentCompanyadmin@Domain.extension2"
                    $destinationHybridWorkerKeyVault = "US-NC-VS-DC01"
                    
                    $destinationLADParameters.Add("Server","@Domain.extension2") 
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@Domain.extension2"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber11")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@Domain.extension2"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber11")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-27"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompanyMW.com")  
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber12")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymw.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber12")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-6"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.DK")  
                    $destinationLADExtensionAttributes.Add("co","Denmark")
                    $destinationLADExtensionAttributes.Add("countryCode","208")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.dk"
                    $destinationGraphParameters.Add("Country","DK")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber13")
                    $destinationGraphParameters.Add("UsageLocation","DK")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.dk"
                    $destinationGraphParameters.Add("Country","DK")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber13")
                    $destinationGraphParameters.Add("UsageLocation","DK")
                }
            }
        }
        "unique-Company-Name-4"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","uniqueParentCompany.com.br")  
                    $destinationLADExtensionAttributes.Add("co","Brazil")
                    $destinationLADExtensionAttributes.Add("countryCode","076")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.br"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.com.br"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                }
            }
        }
        "unique-Office-Location-16"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","anonSubsidiary-1.com")  
                    $destinationLADExtensionAttributes.Add("co","Brazil")
                    $destinationLADExtensionAttributes.Add("countryCode","076")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","BR")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber14")
                    $destinationGraphParameters.Add("UsageLocation","BR")
                }
            }
        }
        "unique-Company-Name-2"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                     
                    $destinationLADParameters.Add("Server","@uniqueParentCompany-alcoil.com")   
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany-alcoil.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber15")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany-alcoil.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber15")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Office-Location-18"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","@uniqueParentCompanyacs.cn")   
                    $destinationLADExtensionAttributes.Add("co","China")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyacs.cn"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber16")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyacs.cn"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber16")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        "unique-Company-Name-10"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = "US-MN-VS-DC01"
                    $destinationHybridWorkerUser = "uniqueParentCompanyadmin@uniqueParentCompany.mn"
                    $destinationHybridWorkerKeyVault = "US-MN-VS-DC01"
                    
                    $destinationLADParameters.Add("Server","@uniqueParentCompanymn.com")    
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymn.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber17")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanymn.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber17")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-11"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","@uniqueParentCompanylmp.ca")  
                    $destinationLADExtensionAttributes.Add("co","Canada")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanylmp.ca"
                    $destinationGraphParameters.Add("Country","CA")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber18")
                    $destinationGraphParameters.Add("UsageLocation","CA")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanylmp.ca"
                    $destinationGraphParameters.Add("Country","CA")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber18")
                    $destinationGraphParameters.Add("UsageLocation","CA")
                }
            }
        }
        "unique-Office-Location-21"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","@uniqueParentCompanyselect.com")   
                    $destinationLADExtensionAttributes.Add("co","United States")
                    $destinationLADExtensionAttributes.Add("countryCode","840")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyselect.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber19")
                    $destinationGraphParameters.Add("UsageLocation","US")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompanyselect.com"
                    $destinationGraphParameters.Add("Country","US")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber19")
                    $destinationGraphParameters.Add("UsageLocation","US")
                }
            }
        }
        "unique-Company-Name-8"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","@uniqueParentCompany.de")     
                    $destinationLADExtensionAttributes.Add("co","Germany")
                    $destinationLADExtensionAttributes.Add("countryCode","276")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.de"
                    $destinationGraphParameters.Add("Country","DE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber20")
                    $destinationGraphParameters.Add("UsageLocation","DE")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@uniqueParentCompany.de"
                    $destinationGraphParameters.Add("Country","DE")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber20")
                    $destinationGraphParameters.Add("UsageLocation","DE")
                }
            }
        }
        "unique-Company-Name-17"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","@anonSubsidiary-1.com")    
                    $destinationLADExtensionAttributes.Add("co","Malaysia")
                    $destinationLADExtensionAttributes.Add("countryCode","458")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","MY")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber21")
                    $destinationGraphParameters.Add("UsageLocation","MY")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","MY")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber21")
                    $destinationGraphParameters.Add("UsageLocation","MY")
                }
            }
        }
        "unique-Company-Name-16"{
            switch ($shopOrOffice) {
                Default {
                    $currentUserID = $jiraUserToModify
                    $destinationHybridWorkerGroup = $null
                    $destinationHybridWorkerUser = $null
                    $destinationHybridWorkerKeyVault = $null
                    
                    $destinationLADParameters.Add("Server","@anonSubsidiary-1.com")    
                    $destinationLADExtensionAttributes.Add("co","China")
                    $destinationLADExtensionAttributes.Add("countryCode","156")
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                 }
                "Shop" {
                    $destinationGraphParameters.Add("UserID",$jiraUserToModify)
                    $upnSuffix = "@anonSubsidiary-1.com"
                    $destinationGraphParameters.Add("Country","CN")
                    $destinationGraphParameters.Add("BusinessPhones","PhoneNumber22")
                    $destinationGraphParameters.Add("UsageLocation","CN")
                }
            }
        }
        Default {Write-Output "There is no matching location."}
    }#>
    #Pull their Graph User Attributes
    if (($newSupervisor -ne "") -and ($null -ne $newSupervisor)){
        $managerSync = (Get-MgBetaUser -userid $newSupervisor | Select-Object -Property OnPremisesDomainName).OnPremisesDomainName

    }


    Write-Output "The following values will be modified:"
    if ($newCompany -ne $($referenceUser.CompanyName) -and ($newCompany -ne "")-and ($null -ne $newCompany)){
        Write-Output "New Company:          $newCompany"
        $destinationGraphParameters.Add("CompanyName","$newCompany")
  
    }

    if ($newOfficeLocation -ne $($referenceUser.OfficeLocation) -and ($newOfficeLocation -ne "")-and ($null -ne $newOfficeLocation)){
        Write-Output "New Office Location:  $newOfficeLocation"
        $destinationGraphParameters.Add("OfficeLocation","$newOfficeLocation")

    }

    If ($newDepartment -ne $($referenceUser.Department) -and ($newDepartment -ne '') -and ($null -ne $newDepartment)){
        Write-Output "New Department:       $newDepartment"
        $destinationGraphParameters.add("Department","$newDepartment")
    }

    If ($newJobTitle -ne $($referenceUser.JobTitle) -and ($newJobTitle -ne '') -and ($null -ne $newJobTitle)){
        Write-Output "New Job Title:        $newJobTitle"
        $destinationGraphParameters.Add("JobTitle","$newJobTitle")

    }


    If (($newSupervisor -ne $manager) -and ($newSupervisor -ne "") -and ($null -ne $newSupervisor)){
        switch ($refUserSynching) {
            $true {
                if ($isTransfer -eq "No"){
                    If ($managerSync -eq $referenceUser.OnPremisesDomainName){
                        Write-Output "Supervisor:           $newSupervisor"
                        $newManagerUPN = $newSupervisor
                    }
                    Else{
                        Write-Output "Manager is not supported in this case as they are synching from different domains"
                    }
                }
                else{
                    If ($managerSync -eq $referenceUser.OnPremisesDomainName){
                        Write-Output "Manager is not supported in this case as they are synching from different domains"
                    }
                    Else{    
                        Write-Output "Supervisor:           $newSupervisor"
                        $newManagerUPN = $newSupervisor
                    }
                    
                }
            }
            $false {
                    $newManagerUPN = $newSupervisor
            }
    }
    }

    If ($newFirstName -ne $($referenceUser.GivenName) -and ($newFirstName -ne "") -and ($null -ne $newFirstName)){
        $newFormattedFirstName = Format-Name -inputName $newFirstName
        Write-Output "New FirstName:        $newFormattedFirstName"
        $destinationGraphParameters.Add("GivenName","$newFormattedFirstName")
    }
    else{
        $newFormattedFirstName = Format-Name -InputName $referenceUser.GivenName
        Write-Output "New FirstName:        $newFormattedFirstName"
        $destinationGraphParameters.Add("GivenName","$newFormattedFirstName")
    }

    If ($newSurName -ne $($referenceUser.Surname) -and ($newSurName -ne "") -and ($null -ne $newSurName)){
        $newFormattedLastName = Format-Name -inputName $newSurName
        Write-Output "New LastName:         $newFormattedLastName"
        $destinationGraphParameters.add("Surname","$newFormattedLastName")
    }
    else{
        $newFormattedLastName = Format-Name -InputName $referenceUser.Surname
        Write-Output "New LastName:         $newFormattedLastName"
        $destinationGraphParameters.add("Surname","$newFormattedLastName")
    }
    if ($shopOrOffice -ne $($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute1) -and ($shopOrOffice -ne "")-and ($null -ne $shopOrOffice)){
        Write-Output "New Work Location:  $shopOrOffice"
        $destinationGraphParameters.Add("ExtensionAttribute1","$shopOrOffice")
    }
    if ($officeAppBitType -ne $($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute3)){
        if ($officeAppBitType -eq "32"){
            if(($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute3 -ne "") -and ($null -ne $referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute3)){
                Write-Output "$($referenceUser.DisplayName) requires a modification to their Office Apps"
                $destinationGraphParameters.add("ExtensionAttribute3",$null)
            }
            Else{
                Write-Output "$($referenceUser.DisplayName) does not require a modification to their Office Apps"

            }
        }
        Else{
            $destinationGraphParameters.Add("ExtensionAttribute3","$officeAppBitType")
        }
    }
    $newUPN = $destinationGraphParameters.givenname , "." , $destinationGraphParameters.surname , $upnSuffix -join ""
    $destinationGraphParameters.Remove("UserPrincipalName")
    $destinationGraphParameters.Add("UserPrincipalName",$newUPN)
    If ($refUserSynching){
        Write-Output "I am on line 2286, this is a user who is synching."
        Write-Output "`n`SAMAccountName: $SAMAccountName"
        Write-Output "Origin Hybrid Worker Runbook: $originRunbook"
        Write-Output "Origin User Synching Status: $originUserSynching"
        Write-Output "Origin Hybrid Worker Group Performing this Operation: $originHybridWorkerGroup"
        Write-Output "Origin Hybrid Worker Credential Object: $originHybridWorkerCred"
        Write-Output "Origin Parameters from the Ticket for the User:"
        $originParametersUser | Format-Table 
        Write-Output "Origin Parameters from the Ticket for the User as an AD Object:"
        $originParametersObjectv2 = @{}
        # Iterate through each key-value pair in the Ordered Dictionary
        foreach ($entry in $originParametersObject.Keys){
                $stringValue = ($originParametersObject[$entry]).Replace(",","~")
                $originParametersObjectv2.add("$entry","$stringValue") 
        }

        # Output the modified Ordered Dictionary
        $originParametersObject = $originPArametersObjectv2
        $originParametersObject | Format-Table
        Write-Output "NOTE: ',' have been replaced with '~' due to system issues with Runbooks. They are fixed on the Hybrid Worker."
        Write-Output "`n`n`nDestination Graph Parameters:"
        $destinationGraphParameters | Format-Table

        Write-Output "`n`n`Destination Hybrid Worker Runbook: $destinationRunbook"
        Write-Output "Destination Hybrid Worker Group Performing this Operation: $destinationHybridWorkerGroup"
        Write-Output "Destination Hybrid Worker Credential Object: $destinationHybridWorkerCred"
        Write-Output "Destination Local AD Parameters Ticket:"
        $destinationLADParameters | Format-Table 

        Write-Output "`n`Destination On Premises Extension Attributes:"
        $destinationLADExtensionAttributes | Format-Table

        
        #Starting the Origin Runbook
        if (($refUserSynching) -and ($null -ne $originHybridWorkerGroup)){
            Write-Output "I am on line 2323, this is a user who is synching and there are Hybrid Workers Configured to Modify the Origin Account."
            Write-Output "Executing: '$originRunbook'"  
            $originRunbookParameters = [ordered]@{"Key"="$key";"originParametersUser"=$originParametersUser;"originParametersObject"=$originParametersObject;"originHybridWorkerCred"="$originHybridWorkerCred";"currentUserID"="$currentUserID";"originSynching"=$originSynching}
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name $originRunbook -ResourceGroupName "uniqueParentCompanyGIT"  -RunOn $originHybridWorkerGroup -Parameters $originRunbookParameters -wait
            $restoreRunbookParameters = [ordered]@{"Key"="$key";"originGraphUserID"="$originGraphUserID"}
            Write-Output "Executing: 'User-Transfer-3-Restore'" 
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-3-Restore" -ResourceGroupName "uniqueParentCompanyGIT" -Parameters $restoreRunbookParameters -Wait
            $graphModRunbook = [ordered]@{"Key"="$key";"originUPN"="$jiraUserToModify";"ParamsFromTicket"=$destinationGraphParameters;"newManagerUPN" = $newManagerUPN; "newUPN" = "$newUPN";"isTransfer" = "$isTransfer"}
            Write-Output "Executing: 'User-Transfer-4-Modify-Entra-Account'" 
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-4-Modify-Entra-Account" -ResourceGroupName "uniqueParentCompanyGIT"  -Parameters $graphModRunbook -Wait
            if ($null -ne $destinationHybridWorkerGroup){
                $destinationRunbookParameters = [ordered]@{"Key"="$key";"destinationLADParameters"=$destinationLADParameters;"destinationHybridWorkerCred" = "$destinationHybridWorkerCred";"newUPN" = "$newUPN";"currentUserID" = "$originGraphUserID"}
                Write-Output "Executing: 'User-Transfer-5-Create-Local-From-Graph-72'"
                start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-5-Create-Local-From-Graph-72" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn $destinationHybridWorkerGroup  -Parameters $destinationRunbookParameters -Wait
                Write-Output "Executing: 'Invoke-uniqueParentCompany-Sync'"
                start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "Invoke-uniqueParentCompany-Sync" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Azure-DC01" -Wait
                $date = get-date
                $DoW = $date.DayOfWeek.ToString()
                $Month = (Get-date $date -format "MM").ToString()
                $Day = (Get-date $date -format "dd").ToString()
                $pw = $DoW+$Month+$Day+"!"
                Set-SuccessfulCommentRunbook -successMessage "$newUPN has been created on $($destinationLADPArameters.Server) with password '$pw', and this has been resolved by Automation!" -key $key -jiraHeader $jiraHeader
                exit 0
            }
            Else{
                Write-Output "I am on line 2343, this is a user who is synching but there are no Hybrid Workers Configured to Modify the Destination Account."  
                $publicErrorMEssage = "$newOfficeLocation is not configured for a Hybrid Worker Runbook. Their Local Account will need to be done manually"
                Set-PublicErrorJira -key $key -publicErrorMessage $publicErrorMEssage -jiraHeader $jiraHeader
                exit 0
            }
            exit 0
        }
        Else{
            Write-Output "I am on line 2351, this is a user who is synching but there are no Hybrid Workers Configured to Modify the Origin Account."  
            $publicErrorMEssage = "$originLocation is not configured for a Hybrid Worker Runbook. This will need to be done manually"
            Set-PublicErrorJira -key $key -publicErrorMessage $publicErrorMEssage -jiraHeader $jiraHeader
            exit 0
        }
    }
    Else{
        Write-Output "I am on line 2358, this is for a non-synching, Graph Only User"
        Write-Output "I would have changed the user on Graph here"
        Write-Output "UPN: $jiraUserToModify"
        Write-Output "Origin User Synching Status: $originUserSynching"
        Write-Output "Origin Hybrid Worker Group Performing this Operation: $originHybridWorkerGroup"
        Write-Output "Origin Hybrid Worker Credential Item: $originHybridWorkerCred"
        Write-Output "Origin Parameters from the Ticket:"
        $originParametersUser | Format-Table 

        Write-Output "`n`n`nDestination Hybrid Worker Group Performing this Operation: $destinationHybridWorkerGroup"
        Write-Output "Destination Hybrid Worker Credential Item: $destinationHybridWorkerCred"  
        Write-Output "Destination Parameters from the Ticket:"
        $destinationGraphParameters | Format-Table 

        Write-Output "`n`nExtension Attributes:"
        $destinationLADExtensionAttributes | Format-Table

        #Starting the Origin Runbook
        $graphModRunbook = [ordered]@{"Key"="$key";"originUPN"="$jiraUserToModify";"ParamsFromTicket"=$destinationGraphParameters;"newManagerUPN" = $newManagerUPN; "newUPN" = "$newUPN";"isTransfer" = "$isTransfer"}
        Write-Output "Executing: 'User-Transfer-4-Modify-Entra-Account'"
        start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-4-Modify-Entra-Account" -ResourceGroupName "uniqueParentCompanyGIT"  -Parameters $graphModRunbook -Wait
        if ($null -ne $destinationHybridWorkerGroup){
            $destinationRunbookParameters = [ordered]@{"Key"="$key";"destinationLADParameters"=$destinationLADParameters;"destinationHybridWorkerCred" = "$destinationHybridWorkerCred"; "newUPN" = "$newUPN";"currentUserID" = "$originGraphUserID"}
            Write-Output "Executing: 'User-Transfer-5-Create-Local-From-Graph-72'"
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-5-Create-Local-From-Graph-72" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn $destinationHybridWorkerGroup  -Parameters $destinationRunbookParameters  -Wait
            Write-Output "Executing: 'Invoke-uniqueParentCompany-Sync'"
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "Invoke-uniqueParentCompany-Sync" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Azure-DC01" -Wait        
            $date = get-date
            $DoW = $date.DayOfWeek.ToString()
            $Month = (Get-date $date -format "MM").ToString()
            $Day = (Get-date $date -format "dd").ToString()
            $pw = $DoW+$Month+$Day+"!"
            Set-SuccessfulCommentRunbook -successMessage "$newUPN has been created on $($destinationLADPArameters.Server) with password '$pw', and this has been resolved by Automation!" -key $key -jiraHeader $jiraHeader
            exit 0
        }
        Else{
            Write-Output "I am on line 2391 and a Hybrid Worker is either not configured, or required, for this."  
            $publicMessage = "User Update: $newUPN Successfully Completed! Their Local Account, if required, will need to be done manually."
            Set-SuccessfulCommentRunbook -successMessage $publicMessage -jiraHeader $jiraHeader -key $key
            exit 0
        }
        exit 0
    }
    
    }
    Default {Write-Output "This is a User Change"
        $newOfficeLocation  = $form.fields.customfield_10787.value
        $newDepartment      = $form.fields.customfield_10787.child.value
        $locationKey        = $referenceUser.OfficeLocation
            
        #Pull their Graph User Attributes
        if (($newSupervisor -ne "") -and ($null -ne $newSupervisor)){
            $managerSync = (Get-MgBetaUser -userid $newSupervisor | Select-Object -Property OnPremisesDomainName).OnPremisesDomainName
        
        }
        
        If ($referenceUser.OnPremisesSyncEnabled -eq $true){
            if ($null -ne $referenceUser.OnPremisesDomainName){
                Write-Output "User is Synching"
                Write-Output "User To Modify:       $jiraUserToModify"
                $samAccountName = $referenceUser.OnPremisesSAMAccountName
                $refUserSynching = $true
                $originSynching = $true
                $runbook = "User-Change-2-LocalAD-72"
            }
    
            else{
                Write-Output "User is Graph Only"
                Write-Output "User To Modify:       $jiraUserToModify"
                $runbook = "User-Change-2-Graph"  
                $refUserSynching = $false
                $originSynching = $false
            }
        }
        else{
            Write-Output "User is Graph Only"
            Write-Output "User To Modify:       $jiraUserToModify"
            $refUserSynching = $false
            $originSynching = $false
            $runbook = "User-Change-2-Graph"
        }
        
        
        
        
        Write-Output "The following values will be modified:"
        if ($newCompany -ne $($referenceUser.CompanyName) -and ($newCompany -ne "")-and ($null -ne $newCompany)){
            Write-Output "New Company:          $newCompany"
            switch ($refUserSynching) {
                $true {
                    $paramsFromTicket.add("Company","$newCompany")
                    
                }
                $false {
                    $paramsFromTicket.Add("CompanyName","$newCompany")
                }
            }
        }
        
        if ($newOfficeLocation -ne $($referenceUser.OfficeLocation) -and ($newOfficeLocation -ne "")-and ($null -ne $newOfficeLocation)){
            Write-Output "New Office Location:  $newOfficeLocation"
            switch ($refUserSynching) {
                $true {
                    $paramsFromTicket.add("Office","$newOfficeLocation")
                    
                }
                $false {
                    $paramsFromTicket.Add("OfficeLocation","$newOfficeLocation")
                }
            }
        }
        
        If ($newDepartment -ne $($referenceUser.Department) -and ($newDepartment -ne '') -and ($null -ne $newDepartment)){
            Write-Output "New Department:       $newDepartment"
            $paramsFromTicket.add("Department","$newDepartment")
        }
        
        If ($newJobTitle -ne $($referenceUser.JobTitle) -and ($newJobTitle -ne '') -and ($null -ne $newJobTitle)){
            Write-Output "New Job Title:        $newJobTitle"
            switch ($refUserSynching) {
                $true {
                    $paramsFromTicket.add("Title","$newJobTitle")
                    
                }
                $false {
                    $paramsFromTicket.Add("JobTitle","$newJobTitle")
                }
            }
        }
        
        
        If (($newSupervisor -ne $manager) -and ($newSupervisor -ne "") -and ($null -ne $newSupervisor)){
            switch ($refUserSynching) {
                $true {
                    if ($isTransfer -eq "No"){
                        If ($managerSync -eq $referenceUser.OnPremisesDomainName){
                            Write-Output "Supervisor:           $newSupervisor"
                            $newManagerUPN = $newSupervisor
                        }
                        Else{
                            Write-Output "Manager is not supported in this case as they are synching from different domains"
                        }
                    }
                    else{
                        If ($managerSync -eq $referenceUser.OnPremisesDomainName){
                            Write-Output "Manager is not supported in this case as they are synching from different domains"
                        }
                        Else{    
                            Write-Output "Supervisor:           $newSupervisor"
                            $newManagerUPN = $newSupervisor
                        }
                        
                    }
                }
                $false {
                        $newManagerUPN = $newSupervisor
                }
        }
        }
        
        If ($newFirstName -ne $($referenceUser.GivenName) -and ($newFirstName -ne "") -and ($null -ne $newFirstName)){
            $newFormattedFirstName = Format-Name -inputName $newFirstName
            Write-Output "New FirstName:        $newFormattedFirstName"
            $paramsFromTicket.Add("GivenName","$newFormattedFirstName")
        }
        
        If ($newSurName -ne $($referenceUser.Surname) -and ($newSurName -ne "") -and ($null -ne $newSurName)){
            $newFormattedLastName = Format-Name -inputName $newSurName
            Write-Output "New LastName:         $newFormattedLastName"
            $paramsFromTicket.add("Surname","$newFormattedLastName")
        }

        if (($null -ne $newFormattedFirstName) -or ($null -ne $newFormattedLastName)){
            $newDisplayName = $newFormattedFirstName , $newFormattedLastName -join " "
            if ($newDisplayName -cne $($referenceUser.DisplayName)){
                Write-Output "New DisplayName:  $newDisplayName"
                $paramsFromTicket.add("DisplayName","$newDisplayName")
            }
        }
        
        if ($shopOrOffice -ne $($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute1) -and ($shopOrOffice -ne "")-and ($null -ne $shopOrOffice)){
            Write-Output "New Work Location:  $shopOrOffice"
            switch ($refUserSynching) {
                $true {
                    $extensionAttributes.add("ExtensionAttribute1","$shopOrOffice")
                    
                }
                $false {
                    $paramsFromTicket.Add("ExtensionAttribute1","$shopOrOffice")
                }
            }
        }
        if ($officeAppBitType -ne $($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute3)){
            if ($officeAppBitType -eq "32"){
                if(($referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute3 -ne "") -and ($null -ne $referenceUser.OnPremisesExtensionAttributes.ExtensionAttribute3)){
                    Write-Output "$($referenceUser.DisplayName) requires a modification to their Office Apps"
                    switch ($refUserSynching) {
                        $true {
                            $extensionAttributes.add("ExtensionAttribute3",$null)
                            
                        }
                        $false {
                            $paramsFromTicket.Add("ExtensionAttribute3",$null)
                        }
                    }
                }
                Else{
                    Write-Output "$($referenceUser.DisplayName) does not require a modification to their Office Apps"
    
                }
            }
            Else{
                Write-Output "New Office App Configuration:  $officeAppBitType"
                switch ($refUserSynching) {
                    $true {
                        $extensionAttributes.add("ExtensionAttribute3","$officeAppBitType")
                        
                    }
                    $false {
                        $paramsFromTicket.Add("ExtensionAttribute3","$officeAppBitType")
                    }
                }
            }
        }
        
        switch ($locationKey) {
            "unique-Office-Location-0"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup  = "Azure-DC01"
                        $hybridWorkerCred = "Credential"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.COM")
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","14107562600")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
        
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","14107562600")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Office-Location-1"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = "US-CA-VS-DC01"
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyWest.COM")
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber2")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber2")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Office-Location-2"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyMW.COM")
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","phoneNumber3")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","phoneNumber3")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Office-Location-3"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyIA.COM") 
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber4")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber4")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-20"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","anonSubsidiary-1CORP.COM")  
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber5")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber5")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-7"{
                switch ($refUserSynching) {
                    $true { 
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.BE")
                        $paramsFromTicket.Add("Country","BE")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber6")
                        $extensionAttributes.Add("co","Belgium")
                        $extensionAttributes.Add("countryCode","056")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","BE")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber6")
                        $paramsFromTicket.Add("UsageLocation","BE")
                    }
                }
            }
            "unique-Office-Location-6"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.IT")
                        $paramsFromTicket.Add("Country","IT")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber7")
                        $extensionAttributes.Add("co","Italy")
                        $extensionAttributes.Add("countryCode","380")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","IT")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber7")
                        $paramsFromTicket.Add("UsageLocation","IT")
                    }
                }
            }
            "uniqueParentCompany (Sondrio) Europe, S.rl.l."{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.IT") 
                        $paramsFromTicket.Add("Country","IT")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber7")
                        $extensionAttributes.Add("co","Italy")
                        $extensionAttributes.Add("countryCode","380")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","IT")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber7")
                        $paramsFromTicket.Add("UsageLocation","IT")
                    }
                }
            }
            "unique-Office-Location-8"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyCHINA.com")
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("OfficePhone","8.61E+11")
                        $extensionAttributes.Add("co","CN")
                        $extensionAttributes.Add("countryCode","156")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("BusinessPhones","8.61E+11")
                        $paramsFromTicket.Add("UsageLocation","CN")
                    }
                }
            }
            "unique-Office-Location-9"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                       $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyCHINA.com")
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber22")
                        $extensionAttributes.Add("co","CN")
                        $extensionAttributes.Add("countryCode","156")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber22")
                        $paramsFromTicket.Add("UsageLocation","CN")
                    }
                }
            }
            "unique-Company-Name-3"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.com.au") 
                        $paramsFromTicket.Add("Country","AU")
                        $paramsFromTicket.Add("OfficePhone","6.10E+11")
                        $extensionAttributes.Add("co","AU")
                        $extensionAttributes.Add("countryCode","036")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","AU")
                        $paramsFromTicket.Add("BusinessPhones","6.10E+11")
                        $paramsFromTicket.Add("UsageLocation","AU")
                    }
                }
            }
            "unique-Company-Name-18"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","anonSubsidiary-1.com") 
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber9")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber9")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-5"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "DryCooling-Hybrid-Worker"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyDC.com") 
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber10")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber10")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-21"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = "US-NC-VS-DC01"
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("Server","@Domain.extension2") 
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber11")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber11")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Office-Location-27"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompanyMW.com")  
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber12")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber12")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-6"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.DK")  
                        $paramsFromTicket.Add("Country","DK")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber13")
                        $extensionAttributes.Add("co","Denmark")
                        $extensionAttributes.Add("countryCode","208")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","DK")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber13")
                        $paramsFromTicket.Add("UsageLocation","DK")
                    }
                }
            }
            "unique-Company-Name-4"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","uniqueParentCompany.com.br")  
                        $paramsFromTicket.Add("Country","BR")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber14")
                        $extensionAttributes.Add("co","Brazil")
                        $extensionAttributes.Add("countryCode","076")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","BR")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber14")
                        $paramsFromTicket.Add("UsageLocation","BR")
                    }
                }
            }
            "unique-Office-Location-16"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","anonSubsidiary-1.com")  
                        $paramsFromTicket.Add("Country","BR")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber14")
                        $extensionAttributes.Add("co","Brazil")
                        $extensionAttributes.Add("countryCode","076")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","BR")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber14")
                        $paramsFromTicket.Add("UsageLocation","BR")
                    }
                }
            }
            "unique-Company-Name-2"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme) 
                        $paramsFromTicket.Add("Server","@uniqueParentCompany-alcoil.com")   
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber15")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber15")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Office-Location-18"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@uniqueParentCompanyacs.cn")   
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber16")
                        $extensionAttributes.Add("co","China")
                        $extensionAttributes.Add("countryCode","156")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber16")
                        $paramsFromTicket.Add("UsageLocation","CN")
                    }
                }
            }
            "unique-Company-Name-10"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = "US-MN-VS-DC01"
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@uniqueParentCompanymn.com")    
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber17")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber17")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-11"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@uniqueParentCompanylmp.ca")  
                        $paramsFromTicket.Add("Country","CA")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber18")
                        $extensionAttributes.Add("co","Canada")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","CA")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber18")
                        $paramsFromTicket.Add("UsageLocation","CA")
                    }
                }
            }
            "unique-Office-Location-21"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@uniqueParentCompanyselect.com")   
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber19")
                        $extensionAttributes.Add("co","United States")
                        $extensionAttributes.Add("countryCode","840")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","US")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber19")
                        $paramsFromTicket.Add("UsageLocation","US")
                    }
                }
            }
            "unique-Company-Name-8"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "$localCred"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@uniqueParentCompany.de")     
                        $paramsFromTicket.Add("Country","DE")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber20")
                        $extensionAttributes.Add("co","Germany")
                        $extensionAttributes.Add("countryCode","276")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","DE")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber20")
                        $paramsFromTicket.Add("UsageLocation","DE")
                    }
                }
            }
            "unique-Company-Name-17"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@anonSubsidiary-1.com")    
                        $paramsFromTicket.Add("Country","MY")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber21")
                        $extensionAttributes.Add("co","Malaysia")
                        $extensionAttributes.Add("countryCode","458")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","MY")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber21")
                        $paramsFromTicket.Add("UsageLocation","MY")
                    }
                }
            }
            "unique-Company-Name-16"{
                switch ($refUserSynching) {
                    $true {
                        $currentUserID = $jiraUserToModify
                        $hybridWorkerGroup = $null
                        $hybridWorkerCred = "anonSubsidiary-1-Hybrid-Worker"
                        $paramsFromTicket.Add("Identity",$SAMAccountNAme)
                        $paramsFromTicket.Add("Server","@anonSubsidiary-1.com")    
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("OfficePhone","PhoneNumber22")
                        $extensionAttributes.Add("co","China")
                        $extensionAttributes.Add("countryCode","156")
                     }
                    $false {
                        $paramsFromTicket.Add("UserID",$jiraUserToModify)
                        $paramsFromTicket.Add("Country","CN")
                        $paramsFromTicket.Add("BusinessPhones","PhoneNumber22")
                        $paramsFromTicket.Add("UsageLocation","CN")
                    }
                }
            }
            Default {Write-Output "There is no matching location."}
        }
        
        
        If ($refUserSynching){
            
            Write-Output "I am on line 3161 before I run the commands to modify a user on their Local AD and sync`n`n"
            Write-Output "Hybrid Worker Group Performing this Operation: $hybridWorkerGroup"
            Write-Output "Hybrid Worker User Credential Object is $hybridWorkerCred" 
        
            Write-Output "`n`SAMAccountName: $SAMAccountName"
        
            Write-Output "Parameters from the Ticket:`n"
            $ParamsFromTicket | Format-Table 
            Write-Output "`n$($paramsFromTicket.GetType()) is the type of the parameter block paramsFromTicket`n"
            
            Write-Output "`n`nExtension Attributes:"
            $extensionAttributes | Format-Table
            Write-Output "`n$($extensionAttributes.GetType()) is the type of the parameter block extensionAttributes`n"

            $runbookParameters = [ordered]@{"Key"="$key";ParamsFromTicket=$paramsFromTicket;"extensionAttributes"=$extensionAttributes;"hybridWorkerCred"="$hybridWorkerCred";"currentUserID"="$currentUserID";"newManagerUPN"=$newManagerUPN}
            try{
            Write-Output "Executing: 'User-Change-3-LicenseUpdate'"
            $licenseParameters = [ordered]@{"paramsFromTicket" = $extensionAttributes; "currentUserID" = "$currentUserID"}
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Change-3-LicenseUpdate" -ResourceGroupName "uniqueParentCompanyGIT" -Parameters $licenseParameters -wait -ErrorAction Stop
            Write-Output "Executing: 'User-Change-2-LocalAD-72'"
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Change-2-LocalAD-72" -ResourceGroupName "uniqueParentCompanyGIT"  -RunOn $hybridWorkerGroup -Parameters $runbookParameters -wait -ErrorAction Stop
            Write-Output "Executing: 'Invoke-uniqueParentCompany-Sync'"
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "Invoke-uniqueParentCompany-Sync" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Azure-DC01" -Wait -ErrorAction Stop
            
            Set-SuccessfulCommentRunbook -successMessage "This has been resolved by Automation!" -key $key -jiraHeader $jiraHeader -ErrorAction Stop
            exit 0
            }
            catch {
                $errorMessage = $_
                Write-Output $errorMessage    
                Set-PrivateErrorJiraRunbook
                Set-PublicErrorJira
                $ErrorActionPreference = "Stop"
                exit 1
        }
        }
        Else{
            Write-Output "I am on line 3199 before I run the commands to modify a user on Graph`n`n"
            Write-Output "UPN: $jiraUserToModify"
            $ParamsFromTicket | Format-Table
            if ($null -ne $newManagerUPN){
                Write-Output "New Manger UPN: $newManagerUPN"
            } 
            $runbookParameters = [ordered]@{"Key"="$key";"OriginUPN" = "$jiraUserToModify";"ParamsFromTicket"=$ParamsFromTicket;"newManagerUPN" = $newManagerUPN}
            Write-Output "Executing: '$Runbook'"
            try{
            start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name $Runbook -ResourceGroupName "uniqueParentCompanyGIT"  -Parameters $runbookParameters -wait -ErrorAction Stop
            if($officeAppNeeds -eq '10755'){
                Write-Output "This user requires a local account created and their license changed to E5. This is a WIP!"
            }
            Set-SuccessfulCommentRunbook -successMessage "This has been resolved by Automation!" -key $key -jiraHeader $jiraHeader -ErrorAction Stop
            exit 0
            }
            catch{
                $errorMessage = $_
                Write-Output $errorMessage
                Set-PrivateErrorJiraRunbook
                Set-PublicErrorJira
                $ErrorActionPreference = "Stop"  
                exit 1
            }
        }
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






























































