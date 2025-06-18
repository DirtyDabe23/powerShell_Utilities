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
    $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $jiraHeader -ContentType "application/json"
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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Import-module Az.Accounts
Import-Module Az.KeyVault
Connect-ExchangeOnline -ManagedIdentity -Organization uniqueParentCompany.onmicrosoft.com
Connect-AzAccount -subscription $subscriptionID -Identity
#Connect to: Graph / Via: Secret

#The Tenant ID from App Registrations
$graphTenantId      = $tenantIDString

# Construct the authentication URL
$graphURI           = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$graphAppClientId   = $appIDString

$graphRetrSecret    = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText

# Construct the body to be used in Invoke-WebRequest
$graphAuthBody    = @{
    client_id     = $graphAppClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret =  $graphRetrSecret
    grant_type    = "client_credentials"
}

# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
$now = Get-Date -Format "HH:mm"
Write-Output "[$now] | Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop
#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText

$hybridWorkerGroup      =   $null
$hybridWorkerCred       =   $null
$extensionAttributes    =   @{}


#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret){
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else{
    $null
}



#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader         = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type"  = "application/json"
}
#Pull the values from Jira
$TicketNum = $Key
$form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $jiraHeader


<#CustomField_10787 is "New Departments" which is a select list (cascading) in Jira. 
#$LocationHired is the first selectable value, the $DepartmentString is the second value, for departments at the hired location. 
#The trim subexpressions are just to ensure that there are no trailing spaces.
#Customfield_10738 is the Jira CustomField "Work Location", which assigns the user to Office or Shop. This is also used for License / Group Assignment#>
$companyHired           =   $form.fields.customfield_10756.value
$locationHired          =   $form.fields.customfield_10787.value.Trim()
$department             =   $form.fields.customfield_10787.child.value.Trim()
$workLocation           =   $form.fields.customfield_10738.value
$shopOrOffice           =   $workLocation
$employeeType           =   $form.fields.customfield_10736.value
$softwareNeeds          =   $form.fields.customfield_10747.value
$officeAppNeeds         =   $form.fields.customfield_10751.ID


#Proper casing for job title
$jobtitle               =   $form.fields.customfield_10695.substring(0,1).toUpper()+$form.fields.customfield_10695.substring(1).toLower()
$jobtitle               =   $jobtitle.trim()
$TextInfo               =   (Get-Culture).TextInfo
$jobtitle               =   $TextInfo.ToTitleCase($jobtitle)

#As we allow for someone to use a different preferred First Name instead of their Given Name, we account for that here.
if (($null -eq $form.fields.customfield_10743) -or ($form.fields.customfield_10743 -eq ' ') -or ($form.fields.customfield_10743 -eq '')){
    $givenName          =   $form.fields.customfield_10722
}
else{
    $givenName          =   $form.fields.customfield_10743
}
$surName                =   $form.fields.customfield_10723
$formattedGivenName     =   Format-Name -inputName $givenName
$formattedSurName       =   Format-Name -inputName $surName
$displayName            =   $formattedGivenName , $formattedSurName -join " "
$mailNickName           =   ($formattedGivenName , $formattedSurName -join ".").replace(' ','')

$managerUPN             =   $form.fields.customfield_10765.emailaddress

#Get a token to make the various edits for the user and the manager
$tokenRequest           =   Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
$baseToken              =   ($tokenRequest.content | convertfrom-json).access_token
$graphAPIHeader         =   @{
    "Authorization"     =   "Bearer $baseToken"
    "Content-Type"      =   "application/JSON"
    grant_type          =   "client_credentials"
}

#Retreive the Manager and create the hashtable to assign to the user later.
$baseGraphAPI           =   "https://graph.microsoft.com/"
$APIVersion             =   "v1.0/"
$userEndPoint           =   "users/"
$managerGraphURI        =   $baseGraphAPI , $APIVersion , $userEndPoint , $managerUPN -join ""
$apiResponse            =   Invoke-RestMethod -Method Get -uri $managerGraphURI -Headers $graphAPIHeader
$managerID              =   $apiResponse.ID
$managerURI             =   $baseGraphAPI , $APIVersion , $userEndPoint , $managerID -join ""

$managerSetBody         =   @{
    '@odata.id'         =  "$managerURI"
  } | ConvertTo-JSON -Depth 2



if ($shopOrOffice -eq "Shop"){
    if($officeAppNeeds -eq '10775'){
        $shopOrOffice   =   "Shop Office"
    }
}
<#
    Variable Construction: This pulls all location specific variables for the next items.    
#>
<#  ShopOrOffice:
    Shop Office Users and Office Users should be Hybrid Synching Users with E5 Licenses
        A Shop Office User is any Shop User who requires 'Local Office Apps'
    Shop Users should have an F3 license, non-synching.
#>
<#  Work Location:
    Shop Office Users and Shop Users should be members of the same groups
    Office Users Belong to Specific Groups
#>

switch ($locationHired) {
    "unique-Office-Location-0"{
        $usageLoc                           =   "US"
        [string] $officePhone               =   "PhoneNumber24"
        $upnSuffix                          =   "uniqueParentCompany.com"
        switch ($shopOrOffice) {
            "Shop"{
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default{
                $hybridWorkerGroup          =   "Azure-DC01"
                $hybridWorkerCred           =   "Credential"
                $defaultOU                  =   'OU=New User Default - Synching,DC=uniqueParentCompany,DC=COM'
                $server                     =   "uniqueParentCompany.com"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                     = "Group1"
                $group2                     = "Location-Shop"
                $group3                     = "Location Shop Distro"
                }
            "Office"{
                $group1                     =   "Group1"
                $group2                     =   "Location-Office"
                $group3                     =   "Location Office Distro"
            }
        }
    }
    "unique-Office-Location-1"{
        $usageLoc                           =   "US"
        [string] $officePhone               =   "PhoneNumber2"
        $upnSuffix                          =   "uniqueParentCompanywest.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default {
                $hybridWorkerGroup          =   "Azure-DC01"
                $hybridWorkerCred           =   "Credential"
                $defaultOU                  =   $null
                $server                     =   "uniqueParentCompanyWest.com"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                     =   "Antigena-uniqueParentCompanyWest"
                $group2                     =   "unique-Office-Location-1 - General"
                $group3                     =   "unique-Office-Location-1 Distro"
            }
            "Office"{
                $group1                     =   "Antigena-uniqueParentCompanyWest"
                $group2                     =   "unique-Office-Location-1 - General"
                $group3                     =   "unique-Office-Location-1 Distro"
            }
        }
    }
    "unique-Office-Location-2"{
        $usageLoc                           =   "US"
        [string] $officePhone               =   "phoneNumber3"
        $upnSuffix                          =   "uniqueParentCompanymw.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default {
                $hybridWorkerGroup          =   "Azure-DC01"
                $hybridWorkerCred           =   "Credential"
                $defaultOU                  =   'OU=New Users,OU=End Users,OU=AD-Midwest,DC=Location3,DC=uniqueParentCompany,DC=com'
                $server                     =   "uniqueParentCompanyMW.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                     =   "Antigena-uniqueParentCompanyMW"
                $group2                     =   "Location3"
                $group3                     =   "unique-Office-Location-2 Distro"
            }
            "Office"{
                $group1                     =   "Antigena-uniqueParentCompanyMW"
                $group2                     =   "Location3"
                $group3                     =   "unique-Office-Location-2 Distro"
            }
        }
    }
    "unique-Office-Location-3"{
        $usageLoc                           =   "US"
        [string] $officePhone               =   "PhoneNumber4"
        $upnSuffix                          =   "uniqueParentCompanyia.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                $defaultOU                  =   $null
                $server                     =   "uniqueParentCompanyIA.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                     =   "Group4"
                $group2                     =   "Iowa"
                $group3                     =   "unique-Office-Location-3 Distro"
                }
            "Office"{
                $group1                     =   "Group4"
                $group2                     =   "Iowa"
                $group3                     =   "unique-Office-Location-3 Distro"
            }
        }
    }
    "unique-Company-Name-20"{
        $usageLoc                           =   "US"
        [string] $officePhone               =   "PhoneNumber5"
        $upnSuffix                          =   "anonSubsidiary-1corp.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default {
                $hybridWorkerGroup          =   "Azure-DC01"
                $hybridWorkerCred           =   "Credential"
                $defaultOU                  =   'OU=New User Default - Synching,OU=anonSubsidiary-1,DC=anonSubsidiary-1CORP,DC=LOCAL'
                $server                     =   "anonSubsidiary-1Corp.com"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                     =   "Antigena-anonSubsidiary-1"
                $group2                     =   "anonSubsidiary-1"
                $group3                     =   "anonSubsidiary-1 Shop Staff"
                }
            "Office"{
                $group1                     =   "Antigena-anonSubsidiary-1"
                $group2                     =   "anonSubsidiary-1"
                $group3                     =   "anonSubsidiary-1 Office Staff"
            }
        }
    }
    "unique-Company-Name-7"{
        $usageLoc                           =   "BE"
        [string] $officePhone               =   "PhoneNumber6"
        $upnSuffix                          =   "uniqueParentCompany.be"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                $defaultOU                  =   $null
                $server                     =   "uniqueParentCompany.BE"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                     =   $null
                $group2                     =   $null
                $group3                     =   $null
                }
            "Office"{
                $group1                     =   $null
                $group2                     =   $null
                $group3                     =   $null
            }
        }
    }
    "unique-Office-Location-6"{
        $usageLoc                           =   "IT"
        [string] $officePhone               =   "PhoneNumber7"
        $upnSuffix                          =   "uniqueParentCompany.it"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                }
            Default {
                $hybridWorkerGroup          =   $null
                $hybridWorkerCred           =   $null
                $defaultOU                  =   $null
                $server                     =   "uniqueParentCompany.IT"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                      =   $null
                $group2                      =   $null
                $group3                      =   $null
                }
            "Office"{
                $group1                      =   $null
                $group2                      =   $null
                $group3                      =   $null
            }
        }
    }
    "uniqueParentCompany (Sondrio) Europe, S.rl.l."{
        $usageLoc                            =   "IT"
        [string] $officePhone                =   "PhoneNumber7"
        $upnSuffix                           =   "uniqueParentCompany.it"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup           =   $null
                $hybridWorkerCred            =   $null
                }
            Default {
                $hybridWorkerGroup           =   $null
                $hybridWorkerCred            =   $null
                $defaultOU                   =   $null
                $server                      =   "uniqueParentCompany.IT"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                      =   $null
                $group2                      =   $null
                $group3                      =   $null
                }
            "Office"{
                $group1                      =   $null
                $group2                      =   $null
                $group3                      =   $null
            }
        }
    }
    "unique-Office-Location-8"{
        $usageLoc                            =  "CN"
        [string] $officePhone                =  "PhoneNumber8"
        $upnSuffix                           =  "uniqueParentCompanychina.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup           =  $null
                $hybridWorkerCred            =  $null
                }
            Default {
                $hybridWorkerGroup           =  $null
                $hybridWorkerCred            =  $null
                $defaultOU                   =  $null
                $server                      =  "uniqueParentCompanyCHINA.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                       = $null
                $group2                       = $null
                $group3                       = $null
                }
            "Office"{
                $group1                       = $null
                $group2                       = $null
                $group3                       = $null
            }
        }
    }
    "unique-Office-Location-9"{
        $usageLoc                             = "CN"
        [string] $officePhone                 = "PhoneNumber8"
        $upnSuffix                            = "uniqueParentCompanychina.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup            = $null
                $hybridWorkerCred             = $null
                }
            Default {
                $hybridWorkerGroup            = $null
                $hybridWorkerCred             = $null
                $defaultOU                    = $null
                $server                      =  "uniqueParentCompanyCHINA.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                       = $null
                $group2                       = $null
                $group3                       = $null
                }
            "Office"{
                $group1                       = $null
                $group2                       = $null
                $group3                       = $null
            }
        }
    }
    "unique-Company-Name-3"{
        $usageLoc                             =   "AU"
        [string] $officePhone                 =   "PhoneNumber8"
        $upnSuffix                            =   "uniqueParentCompany.com.au"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup            =   $null
                $hybridWorkerCred             =   $null
                }
            Default {
                $hybridWorkerGroup            =   $null
                $hybridWorkerCred             =   $null
                $defaultOU                    =   $null
                $server                       =   "uniqueParentCompany.COM.AU"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                       =   $null
                $group2                       =   $null
                $group3                       =   $null
                }
            "Office"{
                $group1                       =   $null
                $group2                       =   $null
                $group3                       =   $null
            }
        }
    }
    "unique-Company-Name-18"{
        $usageLoc                              =  "US"
        [string] $officePhone                  =  "PhoneNumber9"
        $upnSuffix                             =  "anonSubsidiary-1.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup             =  $null
                $hybridWorkerCred              =  $null
                }
            Default {
                $hybridWorkerGroup             =  "Azure-DC01"
                $hybridWorkerCred              =  "Credential"
                $defaultOU                     =  'OU=New User Default - Synching,OU=Users,OU=anonSubsidiary-1,DC=anonSubsidiary-1inc,DC=lan'
                $server                        =  "anonSubsidiary-1.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                        =  "{anonSubsidiary-1 Direct Benefit Employees}"
                $group2                        =  "{anonSubsidiary-1 KS Office}"
                $group3                        =  "{anonSubsidiary-1 Staff}"
                }
            "Office"{
                $group1                        =  "{anonSubsidiary-1 Direct Benefit Employees}"
                $group2                        =  "{anonSubsidiary-1 KS Office}"
                $group3                        =  "{anonSubsidiary-1 Staff}"
            }
        }
    }
    "unique-Company-Name-5"{
        $usageLoc                               =  "US"
        [string] $officePhone                   =  "PhoneNumber10"
        $upnSuffix                              =  "uniqueParentCompanydc.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompanyDC.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "Antigena-uniqueParentCompanyDC"
                $group2                         =  "uniqueParentCompany Dry Cooling"
                $group3                         =  "uniqueParentCompany Dry Cooling Distro"
                }
            "Office"{
                $group1                         =  "Antigena-uniqueParentCompanyDC"
                $group2                         =  "uniqueParentCompany Dry Cooling"
                $group3                         =  "uniqueParentCompany Dry Cooling Distro"
            }
        }
    }
    "unique-Company-Name-21"{
        $usageLoc                               =  "US"
        [string] $officePhone                   =  "PhoneNumber11"
        $upnSuffix                              =  "Domain.extension2"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  "Azure-DC01"
                $hybridWorkerCred               =  "Credential"
                $defaultOU                      =  OU4
                $server                         =  "Domain.extension2"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "Antigena-anonSubsidiary-1"
                $group2                         =  "anonSubsidiary-1"
                $group3                         =  "anonSubsidiary-1 Shop Distro"
                }
            "Office"{
                $group1                         =  "Antigena-anonSubsidiary-1"
                $group2                         =  "anonSubsidiary-1"
                $group3                         =  "anonSubsidiary-1 Office Distro"
            }
        }
    }
    "unique-Office-Location-27"{
        $usageLoc                               =  "US"
        [string] $officePhone                   =  "PhoneNumber12"
        $upnSuffix                              =  "uniqueParentCompanymw.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompanyMW.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "Antigena-uniqueParentCompanyMW"
                $group2                         =  "anonSubsidiary-1"
                $group3                         =  "unique-Office-Location-2 Distro"
                }
            "Office"{
                $group1                         =  "Antigena-uniqueParentCompanyMW"
                $group2                         =  "anonSubsidiary-1"
                $group3                         =  "unique-Office-Location-2 Distro"
            }
        }
    }
    "unique-Company-Name-6"{
        $usageLoc                               =  "DK"
        [string] $officePhone                   =  "PhoneNumber13"
        $upnSuffix                              =  "uniqueParentCompany.DK"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompany.DK"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Company-Name-4"{
        $usageLoc                               =  "BR"
        [string] $officePhone                   =  "PhoneNumber14"
        $upnSuffix                              =  "uniqueParentCompany.COM.BR"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompany.COM.BR"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Office-Location-16"{
        $usageLoc                               =  "BR"
        [string] $officePhone                   =  "PhoneNumber14"
        $upnSuffix                              =  "anonSubsidiary-1.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "anonSubsidiary-1.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Company-Name-2"{
        $usageLoc                               =  "US"
        [string] $officePhone                   =  "PhoneNumber15"
        $upnSuffix                              =  "uniqueParentCompany-alcoil.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  "Azure-DC01"
                $hybridWorkerCred               =  "Credential"
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompany-ALCOIL.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "Group6"
                $group2                         =  "uniqueParentCompany-Alcoil"
                $group3                         =  "uniqueParentCompany Alcoil Shop Distro"
                }
            "Office"{
                $group1                         =  "Group6"
                $group2                         =  "uniqueParentCompany-Alcoil"
                $group3                         =  "uniqueParentCompany Alcoil Office Distro"
            }
        }
    }
    "unique-Office-Location-18"{
        $usageLoc                               =  "CN"
        [string] $officePhone                   =  "PhoneNumber16"
        $upnSuffix                              =  "uniqueParentCompanyacs.cn.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompanyACS.CN"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Company-Name-10"{
        $usageLoc                               =  "US"
        [string] $officePhone                   =  "PhoneNumber17"
        $upnSuffix                              =  "uniqueParentCompanymn.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompanyMN.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "Group7"
                $group2                         =  "uniqueParentCompany Minnesota Distro"
                $group3                         =  "Minnesota"
                }
            "Office"{
                $group1                         =  "Group7"
                $group2                         =  "uniqueParentCompany Minnesota Distro"
                $group3                         =  "Minnesota"
            }
        }
    }
    "unique-Company-Name-11"{
        $usageLoc                               =  "CA"
        [string] $officePhone                   =  "PhoneNumber18"
        $upnSuffix                              =  "uniqueParentCompanylmp.ca"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompanyLMP.CA"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  $null
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Office-Location-21"{
        $usageLoc                               =  "US"
        [string] $officePhone                   =  "PhoneNumber19"
        $upnSuffix                              =  "uniqueParentCompanyselect.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompanySELECT.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "Antigena-uniqueParentCompanySelect"
                $group2                         =  "uniqueParentCompany Select Distro"
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  "Antigena-uniqueParentCompanySelect"
                $group2                         =  "uniqueParentCompany Select Distro"
                $group3                         =  $null
            }
        }
    }
    "unique-Company-Name-8"{
        $usageLoc                               =  "DE"
        [string] $officePhone                   =  "PhoneNumber20"
        $upnSuffix                              =  "uniqueParentCompany.de"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                $defaultOU                      =  $null
                $server                         =  "uniqueParentCompany.DE"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "unique-Company-Name-8 Distro"
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  "unique-Company-Name-8 Distro"
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Company-Name-17"{
        $usageLoc                               =  "MY"
        [string] $officePhone                   =  "PhoneNumber21"
        $upnSuffix                              =  "anonSubsidiary-1.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  "Azure-DC01"
                $hybridWorkerCred               =  "Credential"
                $defaultOU                      =  'OU=New User Default - Synching,OU=Users,OU=anonSubsidiary-1,DC=anonSubsidiary-1inc,DC=lan'
                $server                         =  "anonSubsidiary-1.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "{anonSubsidiary-1 Asia-Pacific}"
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  "{anonSubsidiary-1 Asia-Pacific}"
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    "unique-Company-Name-16"{
        $usageLoc                               =  "CN"
        [string] $officePhone                   =  "PhoneNumber22"
        $upnSuffix                              =  "anonSubsidiary-1.com"
        switch ($shopOrOffice) {
            "Shop" {
                $hybridWorkerGroup              =  $null
                $hybridWorkerCred               =  $null
                }
            Default {
                $hybridWorkerGroup              =  "Azure-DC01"
                $hybridWorkerCred               =  "Credential"
                $defaultOU                      =  'OU=New User Default - Synching,OU=Users,OU=anonSubsidiary-1,DC=anonSubsidiary-1inc,DC=lan'
                $server                         =  "anonSubsidiary-1.COM"
            }
        }
        switch ($workLocation) {
            "Shop"{
                $group1                         =  "{anonSubsidiary-1 Asia-Pacific}"
                $group2                         =  $null
                $group3                         =  $null
                }
            "Office"{
                $group1                         =  "{anonSubsidiary-1 Asia-Pacific}"
                $group2                         =  $null
                $group3                         =  $null
            }
        }
    }
    Default {
            $now = Get-Date -Format "HH:mm"
            Write-Output "[$now] | There is no matching location."
        }
}
<#
    UsageLocation: As Usage Location is used to identify where their data resides, we use this to set the user's Country Attributes across AD and EID
#>
switch ($usageLoc) {
    "US"{
        $countryString            =     "United States" 
        $countryCode              =     840
    }
    "CA"{
        $countryString            =     "Canada" 
        $countryCode              =     124
    }
    "IT"{
        $countryString            =     "Italy" 
        $countryCode              =     380
    }
    "BR"{
        $countryString            =     "Brazil" 
        $countryCode              =     076
    }
    "DK"{
        $countryString            =     "Denmark" 
        $countryCode              =     208
    }
    "MY"{
        $countryString            =     "Malaysia" 
        $countryCode              =     458
    }
    "BE"{
        $countryString            =     "Belgium" 
        $countryCode              =     056
    }
    "CN"{
        $countryString            =     "China" 
        $countryCode              =     156
    }
    "AU"{
        $countryString            =     "Australia" 
        $countryCode              =     036
    }
    "DE"{
        $countryString            =     "Germany" 
        $countryCode              =     276
    }
    
    Default {
        $now = Get-Date -Format "HH:mm"
        Write-Output "[$now] | There is no matching location."
    }
}

$now = Get-Date -Format "HH:mm"
$generatedUPN = ($mailNickName , $upnSuffix -join '@').replace(' ','')
Write-output "[$now] | Variable Review: `
`nUserPrincipalName: $generatedUPN `
`ndisplayName: $displayName `
`nmailNickName: $mailNickName `
`ngivenName: $formattedGivenName `
`nsurName: $formattedSurName `
`nLocationHired: $locationHired `
`nUsageLocation: $usageLoc `
`nCountryString: $countryString `
`nCountyCode: $countryCode `
`nCompanyHired: $companyHired `
`nDepartment: $department `
`nWorkLocation: $workLocation | ShopOrOffice: $shopOrOffice `
`nEmployeeType: $employeeType `
`nsoftwareNeeds: $softwareNeeds `
`nOfficeAppNeeds: $officeAppNeeds `
`njobTitle: $jobTitle `
`nbyridWorkerGroup: $hybridWorkerGroup `
`nhybridWorkerCred: $hybridWorkerCred `
`ngroup1: $group1 `
`ngroup2: $group2 `
`ngroup3: $group3 `
`ndefaultOU: $defaultOU `n`n`n"





$date = get-date $form.fields.customfield_10613
$DoW = $date.DayOfWeek.ToString()
$Month = (Get-date $date -format "MM").ToString()
$Day = (Get-date $date -format "dd").ToString()
$pw = $DoW+$Month+$Day+"!"

$PasswordProfile = @{
    Password = $pw
}
$extensionAttributes = @{
    extensionAttribute1	     = $shopOrOffice
} | ConvertTo-JSON -Depth 3

$newUserHashTable = @{
    accountEnabled                      =   $true
    ShowInAddressList                   =   $true
    country                             =   $countryString
    businessPhones                      =   @($officePhone)
    department                          =   $department
    displayName                         =   $displayName
    givenName                           =   $formattedGivenName
    jobTitle                            =   $jobtitle
    mailNickname                        =   $mailNickName
    passwordProfile                     =   $PasswordProfile
    officeLocation                      =   $locationHired
    surname                             =   $formattedSurName
    usageLocation                       =   $usageLoc
    userPrincipalName                   =   $generatedUPN
    <# 
    The following are Parameters that can be utilized in the API
    City / Postal Code / Preferred Language / State could have utility

    Preferred Language: User Selected
    Street Address / Postal Code / City / State: Derived from Office Location

    Mobile Phone is a privacy risk.

    streetAddress                       =   "$streetAddress"
    postalCode                          =   "$zipCode"
    city                                =   "$city"
    state                               =   "$state"
    preferredLanguage                   =   "$preferredLanguage"
    mobilePhone                         =   "$mobilePhone"
    #>
}
$newUserJSON        =       $newUserHashTable | ConvertTo-JSON -depth 5
$createNewUserURI   =       $baseGraphAPI , $APIVersion , $userEndPoint.trim('/') -join ""
#Create the New User and get their ID
$createResponse     =       Invoke-RestMethod -uri $createNewUserURI -Method Post -Body $newUserJSON -Headers $graphAPIHeader 
$newUserID          =       $createResponse.ID
$newUserGraphURI    =       $baseGraphAPI , $APIVersion , $userEndPoint , $newUserID -join ""

#The below should be refactored into a POST/PATCH/PUT whenever the API starts accepting the attributes
Update-MGBetaUser -UserId $newUserID -OnPremisesExtensionAttributes $extensionAttributes -CompanyName $companyHired
#Assign the User to a Manager
$assignManagerURI   =       $newUserGraphURI , "/manager/`$ref" -join ""
$assignResponse     =       Invoke-RestMethod -Method Put -uri $assignManagerURI -body $managerSetBody -Headers $graphAPIHeader 
$assignResponse     |       Out-Null
#This is where License Assignment Occurs
switch ($shopOrOffice){
    "Shop" {
        $licenses   =   @("SPE_F1","POWER_BI_STANDARD")
        $licStr     =   @("F3","Power BI Standard")
    }
    Default {
        $licenses   =   "SPE_E5"
        $licStr     =   "E5"
    }
}
$now = Get-Date -Format "HH:mm"
Write-Output "[$now] | License to add: $license | License String: $licStr"


ForEach ($license in $licenses){
    $sku = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $license
    $remLisc = $sku.prepaidunits.enabled - $sku.consumedunits 
    if ($remlisc -le 0){ 
        $now = Get-Date -Format "HH:mm"
        Write-Output "[$now] $licStr Needs Purchased"
        Set-LicenseNeedPurchased -Continue=$true -license $licStr
    }
    Else{
        $newSKU = $sku.skuID
        $addLicenseJSONBody = @{
            addLicenses = @(
                @{
                disabledPlans   = @()
                skuId           = $newSKU
            }
            )
            removeLicenses = @()
        } | ConvertTo-JSON -depth 10
        $addLicenseJSONBody
        $addLicenseURI = $newUserGraphURI , "/assignLicense" -join ""
        Invoke-RestMethod -uri $addLicenseURI -Body $addLicenseJSONBody -Headers $graphAPIHeader -Method Post
    }
}

$noMailbox = $true
while ($noMailbox){
    $now = Get-Date -Format "HH:mm"
    Write-Output "[$now] | Checking for $generatedUPN"
    $newMailbox = Get-Mailbox -Identity $generatedUPN -errorAction SilentlyContinue
    if(!($newMailbox)){
        $now = Get-Date -Format "HH:mm"
        Write-Output "[$now] | $generatedUPN does not yet exist as a mailbox"
        Start-Sleep -Milliseconds 500
    }
    else{
        $now = Get-Date -Format "HH:mm"
        Write-Output "[$now] | $generatedUPN has a mailbox!"
        $noMailbox = $false
    }
}



#This is where the users get added to their Specific Groups
#ID Security Group
if ($Department -eq "Executive"){
    $group4 = "Group9"
}
Elseif ($usageLoc -in "IT","BE","DE","DK","GB"){
$null
}
Else{
    if ($licStr.count -ge 2){
        $licStr = "F3"
    }
$group4 = "IDSecurity-"+$licStr+"-"+$usageLoc
}

$groups = @($group1,$group2,$group3,$group4)
ForEach ($group in $groups){
    if ($group -eq "" -or $null -eq $group){
        $now = Get-Date -Format "HH:mm"
        Write-Output "[$now] | Group is null"
    } 
    else{
        $groupObjID = (Get-MGGroup -Search "displayname:$group" -ConsistencyLevel:eventual -top 1).ID
        try{
            New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $newUserID -erroraction stop
        } 
        catch {
                $now = Get-Date -Format "HH:mm"
                Write-Output "[$now] | An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
            try{
                $distro = Get-DistributionGroup -Identity $group
                Add-DistributionGroupMember -Identity $distro.ID -member $newUserID -BypassSecurityGroupManagerCheck -erroraction stop
            }
            catch{
                $now = Get-Date -Format "HH:mm"
                Write-Output "[$now] | Unable to add $displayName to $group. Please do this manually."
            }
        }
    }
}
#Adds the User to the MFA Enabled Group
New-MgGroupMember -GroupId "Group10" -DirectoryObjectId $newUserID

#The following creates the user on their Local AD if they require a local AD account.
if ($shopOrOffice -ne 'Shop'){
    if ($null -ne $hybridWorkerGroup){
        $createLADParameters = @{}
        $now                                        =  Get-Date -Format "HH:mm"
        Write-Output "[$now] | $displayName requires a Local Domain Account."    
        $formattedOU = $defaultOU.Replace(",","~")
        $createLADParameters.Add('TargetPath',$formattedOU)
        $createLADParameters.Add('Server',$server)
        $localADParameters                          =  [ordered]@{
            "Key"                                   =  "$key";`
            "destinationLADParameters"              =  $createLADParameters; `
            "destinationHybridWorkerCred"           =  "$hybridWorkerCred"; `
            "newUPN"                                =  "$generatedUPN"
        }
        $localADParameters
        $now                                        =  Get-Date -Format "HH:mm"
        Write-Output "[$now] | Executing: 'User-Transfer-5-Create-Local-From-Graph-72'"
        start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-5-Create-Local-From-Graph-72" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn $hybridWorkerGroup -Parameters $localADParameters -Wait
        $now                                        =  Get-Date -Format "HH:mm"
        Write-Output "[$now] | Executing: 'Invoke-uniqueParentCompany-Sync'"
        start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "Invoke-uniqueParentCompany-Sync" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Azure-DC01" -Wait
    }
    Else{
        $now                                        =  Get-Date -Format "HH:mm"
        $publicErrorMEssage                         = "[$now] | $locationHired is not configured for a Hybrid Worker Runbook.",`
                                                    " $displayName Local Account will need to be done manually" -join ""
        Write-output $publicErrorMEssage
        #Set-PublicErrorJira -key $key -publicErrorMessage $publicErrorMEssage -jiraHeader $jiraHeader
    }
}

<#For CoPilot, as this is fully a manual process, a comment is made on a subtask for the CoPilot Team
to add the required users into whatever groups are required.
#>
If (($softwareNeeds -contains 'CoPilot') -or ($workLoc -eq "Shop")){
    $subTaskKey = ($form.fields.subtasks | Where-Object {($_.Fields -like "*CoPilot*")}).key


    $payload = @{
        "update" = @{
            "customfield_10718" = @(@{
                "set" = "$emailAddr"
            })
        }
    }
# Convert the payload to JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($subTaskKey)" -Method Put -Body $jsonPayload -Headers $headers
}

<#From the above, the user is created either on both Entra ID and Local AD, or just Entra ID
We then evaluate their software needs. If a user has 'Sage' or 'Doclink' as required software
we add their user account to two Active Directory Groups on unique-Office-Location-0's Domain, 'uniqueParentCompany.com'
Group 1:Citrix Cloud W11M Desktop Users
Group 2: DocLink Users

If a user is NOT an unique-Office-Location-0 Employee, with their primary account on said domain controller:
The most critical thing is that their primary UPN must be set as their email attribute.
Name:               Primary Account Display Name
Country:            US 
DisplayName:        Primary Account Display Name
UserPrincipalName:  The same as their standard UPN, except with @uniqueParentCompany.com instead of their specific domain suffix. 
OfficePhone:        14107562600
Company:            Not Affiliated 
Title:              DocLink User
AccountPassword:    The same as their intial Standard User Account Password prior to reset. 
Department:         Service Account
GivenName:          GivenName
Office:             unique-Office-Location-0
Path:               "OU=CompuData - External Sage Users - Non-Synching,DC=uniqueParentCompany,DC=COM" `
Surname:            Surname
Server:             uniqueParentCompany.COM
EmailAddress:       !!!Their Primary Email Address!!!
#>
If (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')){
    $now = Get-Date -Format "HH:mm"
    Write-Output "[$now] | $displayName requires CompuData Access"
    $compuDataHybridWorkerGroup                 =  "Azure-DC01"
    if($locationHired -eq 'unique-Office-Location-0'){
        $existingCitrixUser                     =  $true
    }
    else{
        $existingCitrixUser                     =  $false
    }
    $now = Get-Date -Format "HH:mm"
    Write-Output "[$now] | Executing: 'User-New-2-Citrix-Doclink-Sage'"
    $citrixADParameters                             =  [ordered]@{ `
        "existingCitrixUser"                        =  $existingCitrixUser;`
        "destinationHybridWorkerCred"               =  "$hybridWorkerCred"; `
        "originUPN"                                 =  "$generatedUPN"; `
        "mailNickName"                              =  "$mailNickName"; `
        "startDate"                                 =  "$date"; `
        "displayName"                               =  "$displayName"; `
        "firstName"                                 =  "$formattedGivenName"; `
        "lastName"                                  =  "$formattedSurName"

    }
    start-azautomationrunbook -AutomationAccountName "AutomationAccount1" -Name "User-New-2-Citrix-Doclink-Sage" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "$compuDataHybridWorkerGroup" -Parameters $citrixADParameters -Wait
    Set-SuccessfulCommentRunbook -successMessage "New User Has been Created! UPN: $generatedUPN Password: $pw  CompuData Account: " -jiraHeader $jiraHeader -key $Key
}
else{
    $now = Get-Date -Format "HH:mm"
    Write-output "[$now] | Compudata and Citrix Not needed"
    Set-SuccessfulCommentRunbook -successMessage "New User Has been Created! UPN: $generatedUPN Password: $pw " -key $key -jiraHeader $jiraHeader
}
# SIG # Begin signature block#Script Signature# SIG # End signature block














































































