param(
    [Parameter (Position = 0, HelpMessage = "Enter the Jira Key, Example: GHD-44619")]
    [string]$Key,
    [Parameter(Position = 1 , HelpMessage = "The Ticket Parameters should be passed off here")]
    [PSCustomObject]$destinationLADParameters,
    [Parameter(Position = 2 , HelpMessage = "Pass along the name of the object to retrieve")]
    [string] $destinationHybridWorkerCred,
    [Parameter(Position = 3 , HelpMessage = "Enter the UPN of the user to modify")]
    [String] $newUPN,
    [Parameter (Position = 4, HelpMessage = "Enter the current UPN of the user")]
    [String] $currentUserID
)
function Set-SuccessfulComment {
[CmdletBinding()]
param(
[Parameter(ParameterSetName = 'Full', Position = 0)]
[switch]$Continue
)
$jsonPayload = @"
{
"update": {
"comment": [
    {
        "add": {
            "body": "Resolved via automated process. New UPN is $emailAddr New Password is $pw"
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
Write-Output "[$($currTime)] | [$process] | [$procProcess] Internal Comment Successfully Made with Error Details"
}
} catch {
Write-Output "API call failed: $($_.Exception.Message)"
Write-Output "Payload: $jsonPayload"
}
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
switch ($Continue){
$False {exit 1}
Default {Continue}
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
function Set-PrivateErrorJira{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    [switch]$Continue
    )
    $currTime = Get-Date -format "HH:mm"
    $errorLog = [PSCustomObject]@{
    processFailed                   = $procProcess
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
                    text = "Process Failed: $($errorLog.processFailed)"
                }
            )
        },
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
    Default {Continue}
    }
}
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
#Test Hybrid Worker Testing
Import-Module Orchestrator.AssetManagement.Cmdlets -ErrorAction SilentlyContinue
Import-module Az.Accounts
Import-Module Az.KeyVault
Connect-AzAccount -subscription $subscriptionID -Identity
Connect-MGGraph -Identity -NoWelcome
#Connect to Jira via the API Secret in the Key Vault
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "JiraAPI" -AsPlainText
#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}
Write-Output "The Key is: $key"
Write-Output "The Destination Hybrid Worker Credential Object: $destinationHybridWorkerCred"
Write-Output "The UserID is $newUPN"
Write-Output "The Passed Parameters are as Follows:"
$destinationLADParameters | Select-Object -Property * | Format-List
Write-Output "The Type for destinationLADParameters is $($destinationLADParameters.gettype())"

$paramsForRunbookHashTable = @{}
if ($destinationLADParameters.GetType().Name -eq 'String'){
    $string = $destinationLADParameters
    $stringNOLeft = $string.replace('{','')
    $stringNoBrackets = $stringNOLeft.replace('}','')
    $splits = $stringNoBrackets.Split(",")
    ForEach ($split in $splits){
     $splitKey = $split.split(":")[0]
     $splitValue = $split.split(":")[1]
     $paramsForRunbookHashTable.add($splitKey,$splitValue)
    }
 }

Write-Output "The Generated Parameters are as Follows:"

Write-Output "The Variable Name: $`paramsForRunbookHashTable"
Write-Output "The Variable Type: $($paramsForRunbookHashTable.GetType())"
Write-Output "The Variable Value: $paramsForRunbookHashTable"
$paramsForRunbookHashTable | Format-Table

$localADAdmin = Get-AutomationPSCredential -Name $destinationHybridWorkerCred
Write-Output "The Credential is: $localADAdmin"
Write-Output "The Credential - UserName is $($localADAdmin.Username)"
Write-Output "The Credential - Password is $($localADAdmin.Password)"
$userName = $localADAdmin.UserName
$securePassword = $localADAdmin.Password
$password = $localADAdmin.GetNetworkCredential().Password
$password | Out-Null
$myPsCred = New-Object System.Management.Automation.PSCredential ($userName,$securePassword)

do {
    $mgUSer = GEt-MGBetaUser -userid $newUPN -erroraction SilentlyContinue -Property * | Select-Object -property *
    If ($mgUser)
    {
        Write-Output "$($mgUser.DisplayName) detected, pulling down to make on Local AD"
        $condition = $true
    }
} while (
    !($condition) 
)


$managerID = Get-MGUserManager -userid $mgUser.id
$manager = Get-MGBetaUser -userid $managerId.ID
$path = $manager.OnPremisesDistinguishedName
$splitPath = $path.Split(',')
$i = 1
While ($i -lt $splitPath.count)
{
    Write-output "$i in the split"
    $newUserPath += $splitPath[$i]+","
    $i++
}
$newUserPath = $NewUserPath.trim(',')

$date = get-date


$DoW = $date.DayOfWeek.ToString()
$Month = (Get-date $date -format "MM").ToString()
$Day = (Get-date $date -format "dd").ToString()
$pw = $DoW+$Month+$Day+"!"
$password = ConvertTo-SecureString -string "$pw" -AsPlainText -Force




$displayName = $mgUser.DisplayName 
$usageLoc = $mgUser.UsageLocation 
$emailAddr = $mgUser.UserPrincipalName 
$businessPhone = $mgUser.BusinessPhones[0] 
$company = $mgUser.CompanyName
$jobtitle = $mgUser.JobTitle 
$DepartmentString = $mgUser.Department 
$firstName = $mgUser.GivenName 
$locationHired = $mgUser.OfficeLocation 
$Manager = $path
$newUserOU = $newUserPath 
$surName = $mgUser.Surname 
$acctSamName = $mgUser.GivenName + "."+$mgUser.Surname


Write-Output "Server: $($paramsForRunbookHashTable.Server)"

           #Standardizes and Sanitizes the User Information 
            $firstName = $firstName.trim()

            #This is to handle last names with a space or hyphen
            If ($firstName -match " ")
                {
                    Write-Output "First Name is: $firstName"
	                Write-Output "This has a space"
                    $firstName = $firstName.split(" ")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+" "+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.Replace(" ","").Trim()
                    Write-Output "First Name for UPN is $firstNameUPN"
	            }
		
		
            ElseIf($firstName -match "-")
                {
	                Write-Output "This is hyphenated"
                    $firstName = $firstName.split("-")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+"-"+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.trim()
                    Write-Output "Last Name for UPN is $firstNameUPN"
	            }
            #If their First Name is not Hyphenated or does not contain a space, it does not get modified.
            Else
            {
            $firstNameUPN = $firstName.SubString(0,1) +$FirstName.SubString(1).ToLower()
            }
		



            $lastName = $surName.trim()
            #This is to handle last names with a space or hyphen
            If ($lastName -match " ")
                {
                    Write-Output "Last Name is: $lastName"
	                Write-Output "This has a space"
                    $lastName = $lastName.split(" ")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+" "+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
	            }
		
		
            ElseIf($lastName -match "-")
                {
	                Write-Output "This is hyphenated"
                    $lastName = $lastName.split("-")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+"-"+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
	            }
            Else
            {
            $lastNameUPN = $lastName.SubString(0,1) +$lastName.SubString(1).ToLower()
            }
		


            #Proper casing for job title
            $jobtitle = $jobtitle.substring(0,1).toUpper()+$jobtitle.substring(1).toLower()
            $jobtitle = $jobtitle.trim()
            $TextInfo = (Get-Culture).TextInfo
            $jobtitle = $TextInfo.ToTitleCase($jobtitle)




            #Set their mail nickname with proper casing
            $mailNN = $firstnameUPN + "."+$lastNameUPN
            $mailNN = $mailNN.trim()

            #Set their displayname with proper casing 
            $displayName = $firstname + " " +$lastname
            $displayName = $displayName.trim()
            $displayName = $TextInfo.ToTitleCase($displayName)

            

            try{
                $locADUser = Get-ADUser -Identity $acctSamName -Server $paramsForRunbookHashTable.Server -Credential $myPsCred
                Write-Output "$acctSAMName already exists. Modifying."
                    Set-ADUser -Identity $acctSamName `
                    -name $displayName `
                    -Country $usageLoc `
                    -DisplayName $displayName `
                    -UserPrincipalName $emailAddr `
                    -OfficePhone $businessPhone `
                    -Company $company `
                    -Title $jobtitle `
                    -Department $DepartmentString `
                    -GivenName $firstName `
                    -Office $locationHired `
                    -Manager $manager `
                    -Path $newUserOU `
                    -Surname $lastName `
                    -erroraction Stop -Server $paramsForRunbookHashTable.Server -Credential $myPsCred
                    $locADUser = Get-ADUser -Identity $acctSamName -Server $paramsForRunbookHashTable.Server -Credential $myPsCred
                }
                catch{
                    Write-Output "Creating: $acctSAMName"
                    New-ADUser -Enabled $true `
                    -name $displayName `
                    -EmailAddress $emailAddr `
                    -Country $usageLoc `
                    -DisplayName $displayName `
                    -UserPrincipalName $emailAddr `
                    -OfficePhone $businessPhone `
                    -Company $company `
                    -Title $jobtitle `
                    -AccountPassword $password `
                    -Department $DepartmentString `
                    -GivenName $firstName `
                    -Office $locationHired `
                    -Manager $manager `
                    -Path $newUserOU `
                    -Surname $lastName `
                    -SamAccountName $acctSAMName -erroraction Stop -Server $paramsForRunbookHashTable.Server -Credential $myPsCred
                    $locADUser = Get-ADUser $acctSamName -Server $paramsForRunbookHashTable.Server -Credential $myPsCred
                }


$extensionAttributes = $mgUser.OnPremisesExtensionAttributes
$extAttr1 = $extensionAttributes.ExtensionAttribute1

If ($null -ne $extAttr1)
{
    try{
    set-aduser $locADUser -add @{"extensionAttribute1"=$extAttr1} -Server $paramsForRunbookHashTable.Server -Credential $myPsCred -ErrorAction Stop
    }
    catch{
        set-aduser $locADUser -add @{"extensionAttribute1"=$extAttr1}
    }
}
Else
{
    Write-Output "Nothing is set for their Extension Attribute 1 which determines if they are a shop or office user"
}
$extAttr3 = $extensionAttributes.ExtensionAttribute3

If ($null -ne $extAttr3)
{
    try{
        set-aduser $locADUser -add @{"extensionAttribute3"=$extAttr3} -Server $paramsForRunbookHashTable.Server -Credential $myPsCred -ErrorAction Stop
    }
    catch{
        set-aduser $locADUser -add @{"extensionAttribute3"=$extAttr3}

    }
}
Else
{
    Write-Output "Nothing is set for their Extension Attribute 3 which determines their office install type"
}

ForEach ($proxyAddress in $mailbox.EmailAddresses)
{
    try{
        set-aduser $locADUser -add @{"proxyAddresses"="smtp:$proxyAddress"} -Server $paramsForRunbookHashTable.Server -Credential $myPsCred -ErrorAction Stop
    }
    catch{
        set-aduser $locADUser -add @{"proxyAddresses"="smtp:$proxyAddress"}
    }
}

switch ($usageLoc) {
    "US" {
        $country = "United States"
        $countryCode = "840"

    }
    "BR" {
        $country = "Brazil"
        $countryCode = "076"

    }
    "CA" {
        $country = "Canada"
        $countryCode = "124"

    }
    "ZA" {
        $country = "South Africa"
        $countryCode = "710"

    }
    "MY" {
        $country = "Malaysia"
        $countryCode = "458"

    }
    "IT"{
        $country = "Italy"
        $countryCode = "380"

    }
    "ES" {
        $country = "Spain"
        $countryCode = "724"

    }
    "CN" {
        $country = "China"
        $countryCode = "156"

    }
    "BE" {
        $country = "Belgium"
        $countryCode = "056"

    }
    "AU" {
        $country = "Australia"
        $countryCode = "036"

    }
    "DE" {
        $country = "Germany"
        $countryCode = "276"

    }
    "DK" {
        $country = "Denmark"
        $countryCode = "208"

    }
    "VN" {
        $country = "Vietnam"
        $countryCode = "704"

    }
    "AE" {
        $country = "United Arab Emirates"
        $countryCode = "784"

    }
    "GB" {
        $country = "United Kingdom"
        $countryCode = "826"

    }
    "AT" {
        $country = "Austria"
        $countryCode = "040"

    }
    Default {$null}
}
try{
set-aduser $locADUser -Replace @{c="$usageLoc";co="$country";countrycode=$countryCode} -Server $paramsForRunbookHashTable.Server -Credential $myPsCred -ErrorAction Stop
Get-ADUser $acctSamName -Properties * -Server $paramsForRunbookHashTable.Server -Credential $myPsCred -ErrorAction Stop
#Set-SuccessfulComment
}
catch{
    set-aduser $locADUser -Replace @{c="$usageLoc";co="$country";countrycode=$countryCode}
    Get-ADUser $acctSamName -Properties *
    Set-PrivateErrorJira

}
# SIG # Begin signature block#Script Signature# SIG # End signature block








