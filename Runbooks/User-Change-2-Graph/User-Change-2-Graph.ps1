param(
        [Parameter (Position = 0, HelpMessage = "Enter the Jira Key, Example: GHD-44619")]
        [string]$Key,
        [Parameter (Position = 1, HelpMessage = "Enter the Origin UPN of the user prior to modifications")]
        [string]$originUPN,
        [Parameter(Position = 2 , HelpMessage = "The Ticket Parameters should be passed off here")]
        [PSCustomObject]$paramsFromTicket,
        [Parameter(Position = 3, HelpMessage = "Enter the UPN of the Manager")]
        [String] $newManagerUPN,
        [Parameter (Position = 4, HelpMessage = "If this is a transfer, and will change the UPN Suffix, pass it along here.")]
        [String] $newUPN,
        [Parameter (Position = 5 , HelpMessage = "If this is a transfer, it should be true, otherwise, it should be false")]
        [string] $isTransfer
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

function Set-SuccessfulCommentRunbook {
[CmdletBinding()]
param(
[Parameter(ParameterSetName = 'Full', Position = 0)]
[switch]$Continue
)
$jsonPayload = @"
{
"update": {
"comment": [
    {`
            "body": "Resolved via automated process."
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
    Write-Output $errorLog
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
function Rename-uniqueParentCompanyUser {
    <#
    .SYNOPSIS
    This renames a specified user, either on local AD or Graph.


    .DESCRIPTION
    This function renames an uniqueParentCompany User either on Graph, or their Local AD server.
    It will update their UPN, Mail Nickname, DisplayName, DistinguishedName, CannonicalName, GivenName, SurName, and ProxyAddresses

    .PARAMETER CurrentUserName
    The current UPN of the user to modify

    .EXAMPLE
    #The following will rename a user with the UPN matching TTestUserLast@domain.extension
    #If their domain is different from the account running, you are required to have delegated permissions.
    Rename-uniqueParentCompanyUser -CurrentUserName "TTestUserLast@domain.extension"

    .EXAMPLE
    #The following will update the user to the 'FirstName.LastName' format, without confirmation.
    Rename-uniqueParentCompanyUser -currentUserName "testUser@domain.extension" -Auto
    
    .EXAMPLE
    #The following will rename a testUser@domain.extension and set the following properties
    Rename-uniqueParentCompanyUser -currentUserName "testUser@domain.extension" -Auto -custom -newUPN "TestName.TestLast-NewLast@domain.extension" -firstName "tName" -lastName "lastName"
    #Properties Changed:
    #UPN + Email:                                   TestName.TestLast-NewLast@domain.extension
    #MailNickName , DisplayName, CannonicalName:    Tname Lname 
    #FirstName:                                     Tname
    #LastName:                                      Lastname
    #SamAccountName:                                TestName.TestLast-Ne
    #Classic Logon Format in this case would be:    DOMAIN\TestName.TestLast-Ne
    #oldAlias:                                      smtp:testUser@domain.extension
    #primaryAlias:                                  SMTP:TestName.TestLast-NewLast@domain.extension
    
    .NOTES
    If you are not authenticated with Connect-MgGraph and Connect-ExchangeOnline you will be prompted to do so every time.
    You will need Graph: 'User.ReadWrite.All' permissions
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the User Principal Name for the user to modify",Mandatory = $true)]
    [ValidatePattern( "[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?")]
    [string]$currentUserName,
    [Parameter(Position = 1,HelpMessage = "Enter the path to the user's data directory.`nExample:\\uniqueParentCompanyusers\users\`nEnter")]
    [string]$userDataDirectory ="\\uniqueParentCompanyusers\users\",
    [Parameter(ParameterSetName="Auto",Position =3,HelpMessage = "Use this Switch to Bypass all Confirmations and Process Changes in Bulk")]
    [Parameter(ParameterSetName="Custom",Position =3,HelpMessage = "Use this Switch to Bypass all Confirmations and Process Changes in Bulk")]
    [switch]$auto,
    [Parameter(ParameterSetName="Auto",Position =4,HelpMessage = "Use this Switch to Bypass all Confirmations and Process Changes in Bulk")]
    [Parameter(ParameterSetName="Custom",Position =4,HelpMessage = "Use this switch to be able to pass 'newUPN' 'firstName' and 'lastName' in programmatically for bulk use.")]
    [switch]$custom,
    [Parameter(ParameterSetName="Custom",Position =5,HelpMessage = "Enter the New UPN",Mandatory = $true)]
    [ValidatePattern( "[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?")]
    [string]$newUPN,
    [Parameter(ParameterSetName="Custom",Position =6,HelpMessage = "Enter the User's Preferred Given Name",Mandatory = $true)]
    [string]$firstName,
    [Parameter(ParameterSetName="Custom",Position =7,HelpMessage = "Enter the User's Surname",Mandatory = $true)]
    [string]$lastName
    
    )

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
    
    function Add-Alias{
        [CmdletBinding()]
        param(
        [Parameter(Position = 0, HelpMessage = "Enter the Alias to add. `nExample: smtp:exampleEmail@domain.com will set a secondary alias for that email address`n`
        Example: SMTP:exampleEmail@domain.com will the primary email address to said example email`nEnter",Mandatory = $true)]
        [string]$inputAlias,
        [Parameter(Position = 1, HelpMessage = "Enter 'Graph' to modify on Graph, 'Local' to Modify on Local",Mandatory = $true)]
        [string]$graphOrLocal
        )
        $aliasType = $null
        switch ($inputAlias -clike "smtp:*") {
            ($true){$aliasType = "Secondary"}
            Default {$aliasType = "Primary"}
        }
        
        If ($inputAlias -in $currentAliases){
            Write-Output "`n`n$inputAlias is already applied"
            if ($inputAlias -cin $currentAliases){
                Write-Output "$aliasType Alias Already $inputAlias"
            }
            Else{
                Write-Output "$aliasType Alias needs set to $aliasType"
                switch ($graphOrLocal) {
                    "Graph"{
                        $null
                    }
                    "Local"{
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $true{Set-AdUser $usertoModify -remove @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                            Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop}
                            $false{Set-AdUser $usertoModify -remove @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop -Server $upnSuffix
                            Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop}
                        }
                    }
                }

                Write-Output "$aliasType Alias now $inputAlias"
            }
        }
        Else{
            Write-Output "Alias $inputAlias Type $aliasType does not exist, adding"
            switch ($graphOrLocal){
                'Graph'{ 
                    $null
                }
                'Local'{
                    switch ($runningUserDomainSuffix -eq $upnSuffix){
                        $True{Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop}
                        $false{Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop -Server $upnSuffix -ErrorAction Stop}
                    }
                }
            }
            Write-Output "$aliasType Alias now $inputAlias"
        }
    }
    function Invoke-uniqueParentCompanySync{
        [CmdletBinding()]
        param(
        [Parameter(Position = 2, HelpMessage = "Enter the name of the sever that syncs devices. Example: PREFIX-VS-AADC01.uniqueParentCompany.com`n`nEnter")]
        [string] $syncServer = "PREFIX-VS-AADC01.uniqueParentCompany.com"
        )
        #Ensures you aren't going to wait over 5 minutes for a sync, if it takes over 5 minutes, something is wrong.
        $waitedTime = 0
        try{
            Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -erroraction Stop
            Write-Output "Sync started! It can take up to 5 minutes to apply"
        }
        catch{
            $busySync = $true
            while ($busySync -or ($waitedTime -lt 50))
            {
                $syncErrorMessage = ($error[0] | Select-Object exception).exception
                If (Select-String -InputObject $syncErrorMessage -Pattern "The user name or password is incorrect.")
                {
                    Write-Output "Your entered credentials are invalid!"
                    $uniqueParentCompanyCred = Get-Credential -Message "Enter your uniqueParentCompany Admin Account Credentials that can remote into the AADC server.  The notation to use is Test.User@uniqueParentCompany.com"
                    $error.Clear()
                }
                else
                {
                    Write-Output "Waiting 10 seconds for Sync to Finish at $(Get-Date -Format HH:mm:ss)"
                    $waitedTime++
                    Start-Sleep -Seconds 6
                    $syncResult = Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $uniqueParentCompanyCred -ErrorAction SilentlyContinue
                    if ($syncResult.Result -eq "Success")
                    {
                        $busySYnc = $false
                    }
                }
            }
            if($waitedTime -eq 50){Write-Output "Somethning is wrong with the sync."}
            else{Write-Output "Sync ran at $(Get-Date -Format HH:mm:ss), it will take up to 5 minutes for all changes to replicate"}
        }
    }
    function Set-NewUserDataPath {
        [CmdletBinding()]
        param(
        [Parameter(Position = 0, HelpMessage = "Enter the Path of the Current User Data Drive Directory, leading up to their user account. `nExample: \\directory\share\`nEnter",Mandatory = $true)]
        [string]$userDataPath,
        [Parameter(Position = 1, HelpMessage = "Enter the Previous Username`nExample: testUser`nEnter",Mandatory = $true)]
        [string]$previousName,
        [Parameter(Position = 2, HelpMessage = "Enter the New Username`nExample: Test.User`nEnter",Mandatory = $true)]
        [string]$newUserName
        )
        if ($userDataPath.EndsWith("\")){
                $confirmedTerminatingUserPath = $userDataPath
            }
        else{
            $confirmedTerminatingUserPath = $userDataPath , "\" -join ""
        }
        if(!(Test-Path $confirmedTerminatingUserPath -ErrorAction SilentlyContinue)){Write-Warning "No User Directory Found, no rename has occured."}
        Else{
            $oldUserPath = $confirmedTerminatingUserPath , $previousName -join ""
            if(!(Test-Path $oldUserPath)){Write-Warning "Failed to find $oldUserPath, no rename has occured."}
            else{
                try{
                    $newUserPath = $confirmedTerminatingUserPath , $newUserName -join ""
                    Rename-Item -Path $userDataPath -NewName $newUserPath
                    Write-Output "Verify $newUserName can access $newUserPath"
                }
                catch{
                    Write-Warning "Failed to rename $oldUserPath to $newUserPath, perform manual troubleshooting."
                }
            }
        }
    }

    $isFinished = $False
    Write-Output "Welcome $($env:USERNAME) to the uniqueParentCompany User Renamer!"
    Do{
    $runningUserDomainSuffix = "@" , $env:USERDNSDOMAIN -join ""
    # Output the domain suffix

    $GRAPHOrLocal = $null
    $userExists = $false
    $usertoModify = $null
    $scopes = $null
    $contexts = $null
    $contexts = Get-MGContext
    If ($null -eq $contexts){
    Write-Output "Attempting to connect to Graph"
    $graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

    # Extract the Access Token
    $graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
    Write-Output "Attempting to connect to Graph"
    Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop
    }
    $scopes = Get-MGcontext | Select-Object -ExpandProperty Scopes
    If ($scopes -notcontains 'User.ReadWrite.All'){
        Throw 'Insufficient privileges. Please PIM, use a different account, or contact GHD'
    }
    try{
    $graphUser = Get-MGBetaUser -userid $currentUserName -ErrorAction Stop | select-object *
    if ($graphUser.OnPremisesSyncEnabled){$graphOrLocal =2}
    else{$graphOrLocal = 1}
    }
    catch{
        $graphOrLocal = 2
    }

    If ($graphOrLocal -eq 2){
        do{
            $userToModify = Get-ADUser -Filter "UserPrincipalName -eq '$currentUserName'" -properties * -erroraction SilentlyContinue
            if ($null -ne $userToModify)
            {
                $userExists = $true
                Write-Output "User Mapped. Proceeding"
            }
            Else
            {
                switch ($auto) {
                    $true {Throw "Attempting to find $currentUserName Failed"
                    }
                    Default {
                        Write-Output "No user found with Username: $currentUserName Please try again`n`n`n"
                        $currentUserName = Read-Host -Prompt "Enter the UPN of the user to fix"
                    }
                }
            }
        } While ($userExists -eq $false)
        $upnSuffix = ($usertoModify.userPrincipalName -replace '^[^@]+', '').ToUpper()
        Write-Output "User Information is as follows:"
        Write-Output "User's FirstName: $($usertoModify.GivenName)"
        Write-Output "User's LastName: $($usertoModify.Surname)"
        Write-Output "User's DisplayName: $($usertoModify.DisplayName)"
        Write-Output "User's UPN: $($usertoModify.UserPrincipalName)"
        Write-Output "User's UPN Suffix: $upnSuffix"
        Write-Output "User's Aliases: $($usertoModify.proxyAddresses)"
        Write-Output "User's SAM Account Name: $($usertoModify.SamAccountName)"
        Write-Output "User's Distinguished Name: $($usertoModify.DistinguishedName)"
        

        $givenName = $userToModify.GivenName
        $surName = $usertoModify.Surname
        $oldSAM = $userToModify.SamAccountName
        $oldUPN = $userToModify.UserPrincipalName
        $currentAliases = $usertomodify.proxyAddresses
        $newAlias = "smtp:"+$oldUPN
        $firstNameFormatted = Format-Name -inputName $givenName
        $lastNameFormatted = Format-NAme -inputName $surName
        write-output "First Name Formatted: $firstNameFormatted `nLast Name Formatted: $lastNameFormatted"
        $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
        $mailNN = ($firstNameFormatted + "." +$lastNameFormatted).replace(" ","")
        $mailNN = $mailNN.trim()
        [string]$testNewUPN = $mailNN , $upnSuffix -join ""
        If ($mailNN.length -gt 20)
        {
            $newSAMName = $mailNN.substring(0,20)
        }

        Else
        {
            $newSAMName = $mailNN
        }

        Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
        Write-Output "User's NEW FirstName:         $firstNameFormatted"
        Write-Output "User's NEW LastName:          $lastNameFormatted"
        Write-Output "User's NEW DisplayName:       $newDisplayName"
        Write-Output "User's NEW UPN:               $testNewUPN"
        Write-Output "User's NEW SAM Account Name:  $newSAMName"
        Write-Output "User's ADDED Aliases:         $newAlias"
        Write-Output "User's Redirected Drive:      $userDataDirectory"

        if (($auto) -and ($custom)){$confirmation = "E"}
        elseif (($auto) -and (!($custom))){$confirmation = "Y"}
        else{$confirmation = Read-Host "`n`nWould you like to process these changes? Y for Yes, N, for No, E to Edit Manually"}

        #Auto Accept
        If($confirmation.substring(0,1) -eq 'Y'){
                [string]$newUPN = $mailNN , $upnSuffix -join ""
                $primaryAlias = "SMTP:"+$newUPN
                try{
                    if ($primaryAlias -eq $newAlias){
                        $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -ErrorAction Stop}
                    }
                    else{
                        $newAlias , $primaryAlias| ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -ErrorAction Stop}
                    }
                }
                catch{
                    Throw $error[0].exception.message   
                }
                try{
                    switch ($runningUserDomainSuffix -eq $upnSuffix){
                        $True{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -ErrorAction Stop}
                        $false{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -Server $upnSuffix -ErrorAction Stop}
                    }
                }
                catch{
                    Throw $error[0].exception.message
                }
                try{
                    switch ($runningUserDomainSuffix -eq $upnSuffix){
                        $True{$userChanged = Get-ADUser $newSAMName -properties * -ErrorAction Stop
                            Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -ErrorAction Stop
                            $userChanged = Get-ADUser $newSAMName -properties * -ErrorAction Stop}
                        $false{$userChanged = Get-ADUser $newSAMName -properties * -Server $upnSuffix -ErrorAction Stop
                            Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Server $upnSuffix -ErrorAction Stop
                            $userChanged = Get-ADUser $newSAMName -properties * -Server $upnSuffix -ErrorAction Stop}
                    }
                    Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                    Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                    Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                    Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                    Write-Output "User's Distinguished NAme: $($userChanged.DistinguishedName)"
                    Invoke-uniqueParentCompanySync
                }
                catch{
                    Throw $error[0].exception.message
                }    
            }
        
                #Manual Edits
                ElseIf ($confirmation.substring(0,1) -eq 'E'){
                    try{
                        switch("" -eq $newUPN){
                            $true {$newUPN = Read-Host "Enter the New UPN"}
                            Default {$null}
                        }
                        switch ("" -eq $firstName) {
                             $true {$firstName = Read-Host "Enter the User's Preferred Given Name"}
                            Default {$null}
                        }
                        switch ("" -eq $lastName) {
                            $true {$lastName = Read-Host "Enter the User's Surname"}
                            Default {$null}
                        }                        
                        
                        #nameFunctionality
                        $oldSAM = $userToModify.SamAccountName
                        $oldUPN = $userToModify.UserPrincipalName
                        $currentAliases = $usertomodify.proxyAddresses
                        $newAlias = "smtp:"+$oldUPN
                        $firstNameFormatted = Format-Name -inputName $firstName
                        $lastNameFormatted  = Format-Name -inputName $lastName
                        $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
                        $newSAMName = $newUPN.Split('@')[0]
                        If ($newSAMName.length -gt 20){
                            $newSAMName = $newSAMName.substring(0,20)
                        }
                        Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
                        Write-Output "User's NEW FirstName:     $firstNameFormatted"
                        Write-Output "User's NEW LastName:      $firstNameFormatted"
                        Write-Output "User's NEW DisplayName:   $newDisplayName"
                        Write-Output "User's NEW UPN:           $newUPN"
                        Write-Output "User's NEW SAM Account Name: $newSAMName"
                        Write-Output "User's ADDED Aliases:     $newAlias"
                        
                        $primaryAlias = "SMTP:"+$newUPN
                        if ($primaryAlis -eq $newAlias){
                            $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -ErrorAction Stop}
                        }
                        else{
                            $newAlias , $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -ErrorAction Stop}
                        }
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $True{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -ErrorAction Stop}
                            $false{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -Server $upnSuffix -ErrorAction Stop}
                        }
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $True{$userChanged = Get-ADUser $newSAMName -properties * -ErrorAction Stop
                                Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -ErrorAction Stop
                                $userChanged = Get-ADUser $newSAMName -properties * -ErrorAction Stop}
                            $false{$userChanged = Get-ADUser $newSAMName -properties * -Server $upnSuffix -ErrorAction Stop
                                Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Server $upnSuffix -ErrorAction Stop
                                $userChanged = Get-ADUser $newSAMName -properties * -Server $upnSuffix -ErrorAction Stop}
                            }

                        Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                        Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                        Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                        Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                        Write-Output "User's Distinguished NAme: $($userChanged.DistinguishedName)"
                        Set-NewUserDataPath -userDataPath $userDataDirectory -previousName $oldSAM -newUserName $newSAMName
                    }
                    catch{  
                        Throw $error[0]
                    }
                }
                #Exit
                ElseIf ($confirmation.substring(0,1) -eq 'N')
                {
                    Throw "Aborting Changes."
                }
                #Invalid Entries
                ElseIf (($confirmation.substring(0,1) -ne 'E') -and ($confirmation.substring(0,1) -ne 'Y') -and ($confirmation.substring(0,1) -ne 'N'))
                {
                    Write-Output "Invalid Selection, Aborting Changes"
                }
    
    }
    elseIf ($graphOrLocal -eq 1)
    {
        $contexts = Get-MGContext
        If ($null -eq $contexts)
        {
        $graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

        # Extract the Access Token
        $graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
        Write-Output "Attempting to connect to Graph"
        Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop
        }
        $scopes = Get-MGcontext | Select-Object -ExpandProperty Scopes
        If ($scopes -notcontains 'User.ReadWrite.All')
        {
            Throw 'Insufficient privileges. Please PIM, use a different account, or contact GHD'
        }
        Else{
            do{
                $userToModify = Get-MGBetaUser -userid "$currentUserName" -property * -erroraction SilentlyContinue
                if ($null -ne $userToModify)
                {
                    $userExists = $true
                    Write-Output "User Mapped. Proceeding"
                }
                Else
                {
                    switch ($auth) {
                        $true {Throw "No user found with Username: $currentUserNAme on Microsoft Graph"}
                        Default {Write-Output "No user found with Username: $currentUserName Please try again`n`n`n"
                        $currentUserName = Read-Host -Prompt "Enter the UPN of the user to fix"}
                    }

                }
            } While ($userExists -eq $false)


            Write-Output "User Information is as follows:"
            Write-Output "User's UPN: $($usertoModify.UserPrincipalName)"
            Write-Output "User's Aliases: $($usertoModify.proxyAddresses)"

            $givenName = $userToModify.GivenName
            $surName = $usertoModify.Surname
            $oldUPN = $userToModify.UserPrincipalName
            $currentAliases = $usertomodify.proxyAddresses
            $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
            $newAlias = "smtp:"+$oldUPN
            $upnSuffix ="@" +$usertoModify.userPrincipalName.Split('@')[1]
            $firstNameFormatted = Format-Name -inputName $givenName
            $lastNameFormatted  = Format-Name -inputName $surName
            $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
            $mailNN = ($firstNameFormatted + "."+$lastNameFormatted).replace(" ","")
            $mailNN = $mailNN.trim()
            [string]$testNewUPN = $mailNN , $upnSuffix -join ""
            Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
            Write-Output "User's NEW UPN: $testNewUPN"
            Write-Output "User's ADDED Aliases: $newAlias"

            if (($auto) -and ($custom)){$confirmation = "E"}
            elseif(!($auto) -and ($custom)){$confirmation = "E"}
            elseif (($auto) -and (!($custom))){$confirmation = "Y"}
            else{$confirmation = Read-Host "`n`nWould you like to process these changes? Y for Yes, N, for No, E to Edit Manually"}
                 
            If ($confirmation.substring(0,1) -eq 'Y'){
                $newUPN = $testNewUPN
                $primaryAlias = "SMTP:"+$newUPN
                if ($primaryAlis -eq $newAlias){
                        $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Graph" -ErrorAction Stop}
                    }
                    else{
                        $newAlias , $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Graph" -ErrorAction Stop}
                    }
                    $graphUserID = $usertoModify.Id

                    #Request a Token for the Graph API Pushes
                    $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
                    # Extract the Access Token
                    $baseToken = ($tokenRequest.content | convertfrom-json).access_token
    
                    $graphAPIHeader = @{
                        "Authorization" = "Bearer $baseToken"
                        "Content-Type" = "application/JSON"
                        grant_type    = "client_credentials"
                    }
    
    
                    $uniqueParentCompanyRenameHashtable = @{
                        UserPrincipalName   =   "$newUPN"
                        GivenName           =   "$firstNameFormatted"
                        SurName             =   "$lastNameFormatted"
                        DisplayName         =   "$newDisplayName"
                        MailNickName        =   "$mailNN"
                    }
                $uniqueParentCompanyRenameJSON = $uniqueParentCompanyRenameHashTable | ConvertTo-JSON -Depth 1
                #Building the URI for the user update
                $baseGraphAPI = "https://graph.microsoft.com/"
                $APIVersion = "v1.0/"
                $endPoint = "users/"
                $target = "$graphUserID"
                $userGraphURI = $baseGraphAPI , $APIVersion , $endpoint , $target -join ""
                #Performs the update to the users for all non-extension attributes
                Invoke-RestMethod -uri $userGraphURI -Method Patch -Body $uniqueParentCompanyRenameJSON -Headers $graphAPIHeader -Verbose -Debug
                $userChanged = Get-MGBetaUser -UserId $newUPN | Select-Object *
                Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                }
                ElseIf ($confirmation.substring(0,1) -eq 'E'){
                    switch("" -eq $newUPN){
                        $true {$newUPN = Read-Host "Enter the New UPN"}
                        Default {$null}
                    }
                    switch ("" -eq $firstName) {
                        $true {$firstName = Read-Host "Enter the User's Preferred Given Name"}
                        Default {$null}
                    }
                    switch ("" -eq $lastName) {
                        $true {$lastName = Read-Host "Enter the User's Surname"}
                        Default {$null}
                    }
                $newSAMName = $newUPN.split('@')[0]
                If ($newSAMName.length -gt 20){
                    $newSAMName = $newSAMName.substring(0,20)
                }
                $firstNameFormatted = Format-Name -inputName $firstName
                $lastNameFormatted  = Format-Name -inputName $lastName
                $newdisplayName = $firstNameFormatted , $lastNameFormatted -join " "
                $mailNN = ($firstNameFormatted , $lastNameFormatted -join ".").replace(" ","")
                $primaryAlias = "SMTP:"+$newUPN
                $graphUserID = $usertoModify.Id

                #Request a Token for the Graph API Pushes
                $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
                # Extract the Access Token
                $baseToken = ($tokenRequest.content | convertfrom-json).access_token

                $graphAPIHeader = @{
                    "Authorization" = "Bearer $baseToken"
                    "Content-Type" = "application/JSON"
                    grant_type    = "client_credentials"
                }


                $uniqueParentCompanyRenameHashtable = @{
                    UserPrincipalName   =   "$newUPN"
                    GivenName           =   "$firstNameFormatted"
                    SurName             =   "$lastNameFormatted"
                    DisplayName         =   "$newDisplayName"
                    MailNickName        =   "$mailNN"
                }
                $uniqueParentCompanyRenameJSON = $uniqueParentCompanyRenameHashTable | ConvertTo-JSON -Depth 1
                #Building the URI for the user update
                $baseGraphAPI = "https://graph.microsoft.com/"
                $APIVersion = "v1.0/"
                $endPoint = "users/"
                $target = "$graphUserID"
                $userGraphURI = $baseGraphAPI , $APIVersion , $endpoint , $target -join ""
                #Performs the update to the users for all non-extension attributes
                Invoke-RestMethod -uri $userGraphURI -Method Patch -Body $uniqueParentCompanyRenameJSON -Headers $graphAPIHeader -Verbose -Debug
                if ($primaryAlis -eq $newAlias){
                    $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Graph" -ErrorAction Stop}
                }
                else{
                    $newAlias , $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Graph" -ErrorAction Stop}
                }
                $userChanged = Get-MGBetaUser -userid $newUPN -property *
                Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                }
                ElseIf ($confirmation.substring(0,1) -eq 'N'){
                    Write-Output "Aborting Changes."
                }
                ElseIf(($confirmation.substring(0,1) -ne 'E') -and ($confirmation.substring(0,1) -ne 'Y') -and ($confirmation.substring(0,1) -ne 'N')){
                    Write-Output "Invalid Selection, Aborting Changes"
                }
        }
    }

    Elseif (($graphOrLocal -ne 1) -and ($graphOrLocal -ne 2))
    {
        Write-Output 'Invalid Selection'
    }
                
                switch ($auto){
                    $true{$rerun = "N"}
                    Default{$rerun = Read-Host "Would you like to rerun the script? Y for Yes, N, or any other Letter, for No"}
                }
                If ($rerun.substring(0,1) -eq 'Y')
                {
                    $userToModify = $null
                    $currentUserName = $null
                    $newUPN = $null
                    $firstName = $null
                    $lastName = $null
                    $graphOrLocal = $null
                    $isFinished = $False
                }
                Else
                {
                    $isFinished = $True
                }

    $graphOrLocal = $null
    }
    while ($isFinished -ne $True)
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
$originUser = Get-MgUser -UserId $originUPN -property * | Select-Object -Property * 
Write-Output "Origin User:"
$originUser | Format-List
$originID = $originUser.ID
$ParamsForRunbook = @{}
$parameters = Get-Member -InputObject $paramsFromTicket | Where-Object {($_.MemberType -like "*Property*")} | Select-Object Name , MemberType

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
    $assignedLicenses = Get-MgUserLicenseDetail -userid $originUPN
    if ($null -eq $assignedLicenses){
        Write-Output "$($originUser.DisplayName) does not have any licenses assigned."
        Set-MgUserLicense -UserId $originUPN -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @()
    }
    ElseIf ($assignedLicenses.SkuPartNumber -notcontains $license1){
        $removalLicense = Get-MgSubscribedSku -All | Where-Object -Property SkuPartNumber -eq $removingLicense
        Set-MgUserLicense -UserId $originUPN -AddLicenses @{SkuId = $sku1.SkuId} -RemoveLicenses @($removalLicense.SkuId)
    }
    Else{
        Write-Output "$($originUser.DisplayName) has the proper license assigned!"
    }
}


if($parameters.Name -like "*BusinessPhones*"){ 
    $businessPhones = @{}
   $paramsFromTicket.PSObject.Properties | ForEach-Object {
        if ($_.Name -like "*BusinessPhones*"){
            $businessPhones[$_.Name] = $_.Value
        }
    }
    $updateBody = @{
        businessPhones = @($businessPhones.businessPhones)  # Replace the existing phone number
    } | ConvertTo-Json -Depth 2
    #Request a Token for the Graph API Pushes
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
    # Extract the Access Token
    $baseToken = ($tokenRequest.content | convertfrom-json).access_token

    $graphAPIHeader = @{
        "Authorization" = "Bearer $baseToken"
        "Content-Type" = "application/JSON"
        grant_type    = "client_credentials"
    }
    Invoke-RestMethod -Method Patch -uri $userGraphURI -Body $updateBody -Headers $graphAPIHeader
    
    $paramsFromTicket = $paramsFromTicket | Select-Object -ExcludeProperty "BusinessPhones*"
    $paramsFromTicket.psobject.properties | ForEach-Object { $ParamsForRunbook[$_.Name] = $_.Value }
}
if($parameters.Name -notlike "*UPNSUffix*" -and $parameters.Name -notlike "*ExtensionAttribute*" -and $parameters.Name -notlike "*BusinessPhones*"){ 
        $paramsFromTicket.psobject.properties | ForEach-Object { $ParamsForRunbook[$_.Name] = $_.Value }
}
$paramsForRunbook.remove("UserID")
Write-Output "This is post santization"
Write-Output "$`paramsForRunbook is $($paramsForRunbook.GetType())"
Write-Output "The Passed Parameters are as Follows:"
$ParamsForRunbook | Select-Object * | Format-List


If (($newManagerUPN -ne "") -and ($null -ne $newManagerUPN))
{
Write-Output "`nThe New Manager UPN is: $newManagerUPN"
$managerID = (Get-MGUser -Search "UserPrincipalName:$($newManagerUPN)" -ConsistencyLevel:eventual -top 1).ID 

#Sets the Manager ID
$managerJSON = @{
"@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
} | ConvertTo-JSON -Depth 1
$updateManagerURI = $userGraphURI , "/Manager/$","ref" -join ""

Invoke-RestMethod -uri $updateManagerURI -Method Put -Body $managerJSON -Headers $graphAPIHeader -Verbose -Debug


}

Write-Output "Writing the Splat:`n"
Write-Output @ParamsForRunbook

try{
    #Request a Token for the Graph API Pushes
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
    # Extract the Access Token
    $baseToken = ($tokenRequest.content | convertfrom-json).access_token

    $graphAPIHeader = @{
        "Authorization" = "Bearer $baseToken"
        "Content-Type" = "application/JSON"
        grant_type    = "client_credentials"
    }
    $paramsForRunbookJSON = $ParamsForRunbook | ConvertTo-JSON
    #Performs the update to the users for all non-extension attributes
    Invoke-RestMethod -uri $userGraphURI -Method Patch -Body $paramsForRunbookJSON -Headers $graphAPIHeader -Verbose -Debug
    if ($extensionAttributes)
    {
        Update-MgBetaUser -userid $originID -OnPremisesExtensionAttributes $extensionAttributes -errorAction Stop
        $updatedGraphUser = Get-MGBetaUser -userid $originID -errorAction Stop
        $updatedUserLicenses = Get-MGUserLicenseDetail -userid $updatedGraphUser.UserPRincipalName -erroraction Stop
        if (($updatedGraphUser.UsageLocation -in "IT","CA","BE","AU","DE","DK","VN","AE","MY","GB","ZA") -and ($updatedUserLicenses.SkuPartNumber -notcontains 'OFFICE365_MULTIGEO')){
        $sku3 = Get-MgSubscribedSku -All |  Where-Object -Property SkuPartNumber -eq 'OFFICE365_MULTIGEO'
        $remLisc = $sku3.prepaidunits.enabled - $sku3.consumedunits
            if ($remlisc -le 0)
            { 
                WRite-Output "OFFICE365_MULTIGEO Needs Purchased $displayName"
                Set-LicenseNeedPurchased -license "OFFICE365_MULTIGEO" -Continue:$true
            }
            Else
            {
                    Set-MgUserLicense -UserId $updatedGraphUser.id -AddLicenses @{SkuId = $sku3.SkuId} -RemoveLicenses @()
            }
        }
        Else{
            Write-Output "A Multi-Geo License is Not Required for $($updatedGraphUser.DisplayName)"
        }
    }
    #Renames the user, changing their UPN, email, and display names
    Rename-uniqueParentCompanyUser -currentUserName $originUPN -auto -ErrorAction Stop
    if ($isTransfer -eq "Yes"){
        Write-Output "This is a transfer and one more step remains"
    }
    else{
    Set-SuccessfulCommentRunbook
    }
    }
    catch {
        $errorMessage = $_
        Write-Output $errorMessage    
        $ErrorActionPreference = "Stop"
        Set-PrivateErrorJiraRunbook
        Set-PublicErrorJira
}
# SIG # Begin signature block#Script Signature# SIG # End signature block













