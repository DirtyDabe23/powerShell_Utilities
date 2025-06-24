function Add-Alias{
    <#
    .SYNOPSIS
    Adds or modifies an email alias for a specified user in Active Directory or via Microsoft Graph.
    .DESCRIPTION
    This function allows you to add or modify an email alias for a specified user in Active Directory or via Microsoft Graph.
    .Component
    ActiveDirectory, MicrosoftGraph
    .PARAMETER inputAlias
    The email alias to add or modify. Use "smtp:" for secondary aliases and "SMTP:" for primary aliases.
    .PARAMETER graphOrLocal
    Specify 'Graph' to modify the alias using Microsoft Graph or 'Local' to modify it in local Active Directory.
    .PARAMETER LocalADCred
    A PSCredential object for an account with permissions to modify users in local Active Directory.
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the user whose alias you want to modify.
    .EXAMPLE
    Add-Alias -inputAlias "smtp:e.User@exampleEmail.com" -graphOrLocal "Local" -LocalADCred $cred -UserPrincipalName "email.user@exampleEmail.com"
    .EXAMPLE
    Add-Alias -inputAlias "SMTP:e.user@exampleEmail.com" -graphOrLocal "Graph" -UserPrincipalName "email.user@exampleEmail.com" 
    .NOTES
    Ensure you have the necessary permissions to modify user aliases in Active Directory or via Microsoft Graph.

    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Alias to add. `nExample: smtp:exampleEmail@domain.com will set a secondary alias for that email address`n`
    Example: SMTP:exampleEmail@domain.com will the primary email address to said example email`nEnter",Mandatory = $true)]
    [string]$inputAlias,
    [Parameter(Position = 1, HelpMessage = "Enter 'Graph' to modify on Graph, 'Local' to Modify on Local",Mandatory = $true)]
    [string]$graphOrLocal,
    [Parameter(Position=2,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to create users",Mandatory = $true)]
    [System.Management.Automation.Credential()]
    [PSCredential]$LocalADCred,
    [Parameter(Position=3,HelpMessage ="Enter the UserPrincipalName of the User to modify",Mandatory = $true)]
    [string]$UserPrincipalName
    )
    $currentAliases = Get-ADUSEr -Filter "UserPrincipalname -eq '$userPrincipalName'" -properties proxyAddresses | Select-Object -ExpandProperty proxyAddresses
    $returnAlias = @()
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
        $returnAlias += [PSCustomObject]@{
            alias       =   $inputAlias
            aliasType   =   $aliasType
        }
        return $returnAlias
}
SignatureBlock

