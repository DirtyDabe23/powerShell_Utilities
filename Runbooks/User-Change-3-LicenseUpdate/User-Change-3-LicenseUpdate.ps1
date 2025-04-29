param(
        [Parameter(Position = 0 , HelpMessage = "The Ticket Parameters should be passed off here")]
        [PSCustomObject]$paramsFromTicket,
        [Parameter (Position = 1, HelpMessage = "If this is a transfer, and will change the UPN Suffix, pass it along here.")]
        [String] $currentUserID
)
function Set-PrivateErrorJiraRunbook{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [switch]$Continue
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
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    switch ($Continue){
        $False {exit 1}
        Default {$null}
    }
}
function Set-PublicErrorJira{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    [switch]$Continue
    ) 
    $jsonPayload = @"
    {
    "update": {
        "comment": [
            {
                "add": {
                    "body": "Automation Failed. GIT will review Internal Logs and report back"
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
function Set-LicenseNeedPurchased{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory = $true)]
        [string]$license,
        [Parameter(Position=1)]
        [switch]$Continue
        
    )
    $jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation failed, $license licenses need purchased"
                    }
                }
            ]
        },
    "transition": {
        "id": "991"
    }
}
"@ 
                    try {
                        $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
                        if ($response){
                            $currTime = Get-Date -format "HH:mm"
                            Write-Output "[$($currTime)] | [$process] | [$procProcess] Internal Comment Successfully Made with Error Details"
                        }
                    } catch {
                        Write-Output "API call failed: $($_.Exception.Message)"
                        Write-Output "Payload: $jsonPayload"
                    }
                    $currTime = Get-Date -format "HH:mm"
                    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
                    Write-Output $errorLog
                    $errorLogFull.add({$errorLog | select-object -last 1})
                    switch ($Continue){
                        $False {exit 1}
                        Default {Continue}
                    }
                
}

Import-module Az.Accounts
Import-Module Az.KeyVault
Import-Module Microsoft.Graph.Users
#onPremConnection and Data Review
try {
    # Read from Azure Key Vault using managed identity
    connect-azaccount -subscription $subscriptionID -Identity | out-null
    
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
try{
    #Connect to: Graph / Via: Secret
    #The Tenant ID from App Registrations
    $graphTenantId = $tenantIDString

    # Construct the authentication URL
    $graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
    
    #The Client ID from App Registrations
    $graphAppClientId = $appIDString
    
    $graphRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText
    
    # Construct the body to be used in Invoke-WebRequest
    $graphAuthBody = @{
        client_id     = $graphAppClientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret =  $graphRetrSecret
        grant_type    = "client_credentials"
    }
    
    
# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
Write-Output "Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop
#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText
#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}
$originUser = Get-MgUser -UserId $currentUserID -property * | Select-Object -Property * 
Write-Output "Origin User:"
$originUser | Format-List
$originID = $originUser.ID
$ParamsForRunbook = @{}
$Parameters = Get-Member -InputObject $paramsFromTicket | Where-Object {($_.MemberType -like "*Property*")}

#Building the URI for the user update
$baseGraphAPI = "https://graph.microsoft.com/"
$APIVersion = "v1.0/"
$endPoint = "users/"
$target = "$originID"
$userGraphURI = $baseGraphAPI , $APIVersion , $endpoint , $target -join ""



Write-Output "$`paramsFromTicket is $($paramsFromTicket.GetType())"
Write-Output "Params From Ticket Prior to Sanitization:"
$paramsFromTicket | Format-List

if ($Parameters.Name -like "*ExtensionAttribute*"){
    $extensionAttributes = @{}
    # Extract only properties that match "ExtensionAt*" and convert them into a hashtable
    $paramsFromTicket.PSObject.Properties | ForEach-Object {
        if ($_.Name -like "ExtensionAt*"){
            $extensionAttributes[$_.Name] = $_.Value
        }
    }
    $paramsFromTicket = $paramsFromTicket | Select-Object -ExcludeProperty "ExtensionAt*"
    $paramsFromTicket.psobject.properties | ForEach-Object { $ParamsForRunbook[$_.Name] = $_.Value }
    Write-Output "Extension Attributes:"
    $extensionAttributes | Format-List

    
    switch ($extensionAttributes.ExtensionAttribute1){
        "Shop" {
            $license1 = "SPE_F1"
            $licStr="F3"
            $removingLicense = "SPE_E5"
        }
        "Office" {
            $license1 = "SPE_E5"
            $licStr = "E5"
            $removingLicense = "SPE_F1"
        }
        "Shop Office" {
            $license1 = "SPE_E5"
            $licStr = "E5"
            $removingLicense = "SPE_F1"
        }
        Default{
            Write-Output "No License Change Required!"
            Exit 0
        }
    }
    Write-Output "License to add: $license1"
    Write-Output "License String: $licStr"
    Write-Output "Removing License: $removingLicense"
    $sku1 = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $license1
    $remLisc = $sku1.prepaidunits.enabled - $sku1.consumedunits 
    if ($remlisc -le 0){ 
        Write-Output "$licStr Needs Purchased"
        Set-LicenseNeedPurchased -Continue=$true -license $licStr
    }
    Else{
        Write-Output "Assessing $($originUser.DisplayName) for $license1"
    }
    $assignedLicenses = Get-MgUserLicenseDetail -userid $currentUserID
    if ($null -eq $assignedLicenses){
        Write-Output "$($originUser.DisplayName) does not have any licenses assigned."
        Set-MgUserLicense -UserId $currentUserID -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()
    }
    ElseIf ($assignedLicenses.SkuPartNumber -notcontains $license1){
        $removalLicense = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $removingLicense
        Set-MgUserLicense -UserId $currentUserID -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @($removalLicense.SkuId)
    }
    Else{
        Write-Output "$($originUser.DisplayName) has the proper license assigned!"
    }
    if($extensionAttributes.ExtensionAttribute1 -eq 'Shop'){
        $license2 = "POWER_BI_Standard"
        $licStr2 = "Power BI Standard"
        $sku2 = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $license2
        $remLisc = $sku2.prepaidunits.enabled - $sku2.consumedunits 
        if ($remlisc -le 0){ 
            Write-Output "$licStr2 Needs Purchased"
            Set-LicenseNeedPurchased -Continue=$true -license $licStr2
        }
        Else{
            Write-Output "Assessing $($originUser.DisplayName) for $license2"
        }
        $assignedLicenses = Get-MgUserLicenseDetail -userid $currentUserID
        if ($assignedLicenses.SkuPartNumber -notcontains $license2){
            Write-Output "$($originUser.DisplayName)"
            Set-MgUserLicense -UserId $currentUserID -AddLicenses @{SkuId = $sku2.SkuId} -RemoveLicenses @()
        }
        Else{
            Write-Output "$($originUser.DisplayName) has the proper license assigned!"
        }
    }
    else{
        $removingLicense2 = "Power_BI_Standard"
        $removalLicense2String = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $removingLicense2
        Set-MgUserLicense -UserId $currentUserID -AddLicenses @{} -RemoveLicenses @($removalLicense2String.SkuId)

    }
}
Exit 0
}
catch{
    $errorMessage = $_
    Write-Output $errorMessage    
    Set-PrivateErrorJiraRunbook
    Set-PublicErrorJira
    $ErrorActionPreference = "Stop"
    Exit 1
}
# SIG # Begin signature block#Script Signature# SIG # End signature block













