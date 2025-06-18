function Rename-uniqueParentCompanyUser {
    <#
    .SYNOPSIS
    This renames a specified user, either on local AD or Graph.


    .DESCRIPTION
    This function renames an uniqueParentCompany User either on Graph, or their Local AD server.
    It will update their UPN, Mail Nickname, DisplayName, DistinguishedName, CannonicalName, GivenName, SurName, and ProxyAddresses

    .PARAMETER CurrentUserName
    The current UPN of the user to modify

    .PARAMETER LocalADCred
    Create a Credential Via $LocalADCred = Get-Credential
    Then use this -LocalADCred $LocalADCred 
    The Credential should be entered as UserPrincipalName, and the password that corresponds with the account.

    .PARAMETER SyncServerCred
    Create a Credential Via $SyncServerCred = Get-Credential
    Then use this SyncServerCred $SyncServerCred 
    The Credential should be entered as UserPrincipalName, and the password that corresponds with the account to connect to the synching server

    .EXAMPLE
    #The following will rename a user with the UPN matching TTestUserLast@domain.extension
    #This is assuming your user account has the required permissions to invoke a sync, and modify a user on their domain.
    $cred = Get-Credential
    Rename-uniqueParentCompanyUser -CurrentUserName "TTestUserLast@domain.extension" -LocalADCred $cred -SyncServerCred $cred

    .EXAMPLE
    #The following will update the user to the 'FirstName.LastName' format, without confirmation.
    Rename-uniqueParentCompanyUser -currentUserName "testUser@domain.extension" -Auto -LocalADCred $cred -SyncServerCred $cred
    
    .EXAMPLE
    #The following will rename a testUser@domain.extension and set the following properties
    Rename-uniqueParentCompanyUser -currentUserName "testUser@domain.extension" -Auto -custom -newUPN "TestName.TestLast-NewLast@domain.extension" -firstName "tName" -lastName "lastName" -LocalADCred $cred -SyncServerCred $cred
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
    If you are not authenticated with Connect-MgGraph you will be prompted to do so every time.
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
    [string]$lastName,
    [Parameter(Position=8,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to create users",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$LocalADCred,
    [Parameter(Position=9,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to invoke a sync",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$SyncServerCred
    
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
        [string]$graphOrLocal,
        [Parameter(Position=2,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to create users",Mandatory = $true)]
        [System.Management.Automation.Credential()]
        [PSCredential]$LocalADCred
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
                        try{
                            Set-AdUser $usertoModify -remove @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                            Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                        }
                        catch{
                            try{
                                Set-AdUser $usertoModify -remove @{"proxyAddresses"="$($inputAlias)"} -Credential $LocalADCred -ErrorAction Stop
                                Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -Credential $LocalADCred -ErrorAction Stop
                            }
                            catch{
                                Throw $error[0]
                            }
                        }
                        }
                    }
                }

                Write-Output "$aliasType Alias now $inputAlias"
            }
        Else{
            Write-Output "Alias $inputAlias Type $aliasType does not exist, adding"
            switch ($graphOrLocal){
                'Graph'{ 
                    $null
                }
                'Local'{
                    try{
                    Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -ErrorAction Stop
                    }
                    catch{
                        try{
                        Set-AdUser $usertoModify -add @{"proxyAddresses"="$($inputAlias)"} -Credential $LocalADCred -ErrorAction Stop
                        }
                        catch{
                            Throw $error[0]
                        }

                    }
                }
                }
            }
            Write-Output "$aliasType Alias now $inputAlias"
        }
    function Invoke-uniqueParentCompanySync{
        [CmdletBinding()]
        param(
        [Parameter(Position = 2, HelpMessage = "Enter the name of the sever that syncs devices. Example: PREFIX-VS-AADC01.uniqueParentCompany.com`n`nEnter")]
        [string] $syncServer = "PREFIX-VS-AADC01.uniqueParentCompany.com",
        [Parameter(Position=3,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to invoke a sync",Mandatory = $true)]
        [System.Management.Automation.Credential()]
        [PSCredential]$SyncServerCred
        )
        #Ensures you aren't going to wait over 5 minutes for a sync, if it takes over 5 minutes, something is wrong.
        $waitedTime = 0
        try{
            Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -credential $SyncServerCred -erroraction Stop
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
                    Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $SyncServerCred -erroraction Stop
                }
                else
                {
                    Write-Output "Waiting 10 seconds for Sync to Finish at $(Get-Date -Format HH:mm:ss)"
                    $waitedTime++
                    Start-Sleep -Seconds 6
                    $syncResult = Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $SyncServerCred -ErrorAction SilentlyContinue
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
        [string]$newUserName,
        [Parameter(Position=3,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to create users",Mandatory = $true)]
        [System.Management.Automation.Credential()]
        [PSCredential]$LocalADCred
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
                    Rename-Item -Path $userDataPath -NewName $newUserPath -Credential $LocalADCred
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
    
    Connect-MGGRaph -NoWelcome -ErrorAction Stop
    $contexts = Get-MGContext
    $scopes = Get-MGcontext | Select-Object -ExpandProperty Scopes
    If ($scopes -notcontains 'User.ReadWrite.All'){
        Write-Output "Contexts are as follows:"
        Write-Output $contexts
        Write-output "`nScopes are as follows: "
        Write-Output $Scopes
        
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
            $userToModify = Get-ADUser -Filter "UserPrincipalName -eq '$currentUserName'" -properties * -erroraction SilentlyContinue -Credential $LocalADCred
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
        $mailNN = $firstNameFormatted + "." +$lastNameFormatted
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
                        Write-Output "Line 641: Attempting to add the Primary Alias $primaryAlias"
                        Add-Alias -inputAlias $primaryAlias -GraphOrLocal "Local" -LocalADCred $LocalADCred -ErrorAction Stop
                    }
                    else{
                        Write-Output "Line 645: attempting to add both New Alias $newAlias and $primaryAlias"
                        $newAlias , $primaryAlias| ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -ErrorAction Stop}
                    }
                }
                catch{
                    Throw $error[0] 
                }
                try{
                Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -ErrorAction Stop
                }
                catch{
                    try{
                        Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Replace @{"MailNickName"="$newDisplayName"} -Credential $LocalADCred -ErrorAction Stop
                    }
                    catch{
                        Throw $error[0]  
                    }
                }
                try{
                    $userChanged = Get-ADUser $newSAMName -properties * -ErrorAction Stop -Credential $LocalADCred
                    Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Credential $LocalADCred -ErrorAction Stop
                    $userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -ErrorAction Stop
                    Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                    Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                    Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                    Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                    Write-Output "User's Distinguished NAme: $($userChanged.DistinguishedName)"
                    Invoke-uniqueParentCompanySync -SyncServerCred $SyncServerCred
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
                        Write-Output "Users NEW "
                        $primaryAlias = "SMTP:"+$newUPN
                        if ($primaryAlis -eq $newAlias){
                            $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -LocalADCred $LocalADCred -ErrorAction Stop}
                        }
                        else{
                            $newAlias , $primaryAlias | ForEach-Object {Add-Alias -inputAlias $_ -GraphOrLocal "Local" -LocalADCred $LocalADCred -ErrorAction Stop}
                        }
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $True{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Credential $LocalADCred -Replace @{"MailNickName"="$newDisplayName"} -ErrorAction Stop}
                            $false{Set-AdUser $usertoModify -userprincipalname $newUPN -SamAccountName $newSAMName -emailAddress $newUPN -DisplayName $newDisplayName -GivenName $firstNameFormatted -Surname $lastNameFormatted -Credential $LocalADCred -Replace @{"MailNickName"="$newDisplayName"} -Server $upnSuffix -ErrorAction Stop}
                        }
                        switch ($runningUserDomainSuffix -eq $upnSuffix){
                            $True{$userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -ErrorAction Stop
                                Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Credential $LocalADCred -ErrorAction Stop
                                $userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -ErrorAction Stop}
                            $false{$userChanged = Get-ADUser $newSAMName -properties * -Credential $LocalADCred -Server $upnSuffix -ErrorAction Stop
                                Rename-ADObject -Identity $userChanged.DistinguishedName -NewName $newDisplayName -Server $upnSuffix -Credential $LocalADCred -ErrorAction Stop
                                $userChanged = Get-ADUser $newSAMName -properties * -Server $upnSuffix -Credential $LocalADCred -ErrorAction Stop}
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
            Connect-MgGraph -NoWelcomec-ErrorAction Stop
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
            $mailNN = $firstNameFormatted + "."+$lastNameFormatted
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
                Update-MGBetaUser -userid $usertoModify.Id -userprincipalname $newUPN -GivenName $firstNameFormatted -Surname $lastNameFormatted -DisplayName $newdisplayName -MailNickname $mailNN -ErrorAction Stop
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
                $mailNN = $firstNameFormatted , $lastNameFormatted -join "."
                Update-MGBetaUser -userid $usertoModify.Id -userprincipalname $newUPN -GivenName $firstNameFormatted -Surname $lastNameFormatted -DisplayName $newdisplayName -MailNickname $mailNN -ErrorAction Stop
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
# SIG # Begin signature block#Script Signature# SIG # End signature block





