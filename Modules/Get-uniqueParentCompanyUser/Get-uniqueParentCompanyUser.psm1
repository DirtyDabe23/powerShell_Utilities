function Get-uniqueParentCompanyUser{
    <#
    .SYNOPSIS
    This function will allow you to search a local domain, graph, or both, for the user information.
    
    .DESCRIPTION
    This function will allow you to search a local domain, graph, or both, for the user information.
    
    .PARAMETER UserPrincipalName
    The user's UserPrincipalName
    Example: TestUser.LastName@uniqueParentCompany.com
    
    .PARAMETER Graph
    Requires runnning Connect-MgGraph and the permissions for User.Read.All
    It will search the graph tenant by UPN to look for the user.
    
    .PARAMETER LocalAD
    Requires a connection to a local domain, and for the current executing user to have permissions used to review the user as they exist on the specified domain controller.
    It will search the entire Active Directory Structure for a user with the UserPrincipalName matching the input.

    .PARAMETER Full
    The default. 
    Requires runnning Connect-MgGraph and the permissions for User.Read.All
    Requires a connection to a local domain, used to review the user as they exist on the specified domain controller.
    It will search the entire Active Directory Structure of the specificede Domain and the Current Graph Tenant for a user with the UserPrincipalName matching the input.

    .PARAMETER Domain
    Specify the Domain / Server to connect to. Usually it's the ending of the user's UPN.
    Example: uniqueParentCompany.com

    .PARAMETER Credential
    Enter the credential for authentication to the local domain.

    .EXAMPLE 
    #Get the User Data from the Local Domain 'uniqueParentCompany.com' and from Graph
    Get-uniqueParentCompanyUser -UserPrincipalName "$userName@uniqueParentCompany.com" -Full -Domain "uniqueParentCompany.com"

    .EXAMPLE
    #Get the User Data from Graph
    Get-uniqueParentCompanyUser -UserPrincipalName "$userName@uniqueParentCompany.com" -Graph
   
    .EXAMPLE 
    #Get the User Data from the Local Domain 'uniqueParentCompany.com'
    Get-uniqueParentCompanyUser -UserPrincipalName "$userName@uniqueParentCompany.com" -LocalAD -Domain "uniqueParentCompany.com"
    
 
    
    .NOTES
    This is largely just for learning how to write a module!
    #>
    [CmdletBinding(DefaultParameterSetName = 'Full')] 
    param(
        #This Parameter is available to all sets
        [Parameter(Mandatory = $True,Position = 0,HelpMessage = "Enter a UPN for the user, `nExample: TestUser.TestLast@uniqueParentCompany.com",ValueFromPipelineByPropertyName)]
        [ValidatePattern( "[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[-A-Za-z0-9]*[A-Za-z0-9])?")]
        [string]$UserPrincipalName,
        #This Parameter is available only the the Graph Set
        [Parameter(ParameterSetName = 'Graph',Position = 1,Mandatory)]
        [switch]$Graph,
        #This Parameter is available only to the Domain Set
        [Parameter(ParameterSetName = 'Domain',Position = 1,Mandatory)]
        [switch]$LocalAD,
        [Parameter(ParameterSetName = 'Full', Position = 1)]
        [switch]$Full,
        #These Parameters are only available to the All and Domain Set
        [Parameter(ParameterSetName = 'Full',Mandatory = $True, Position = 2,HelpMessage = "Enter Domain to Check.`nExample:uniqueParentCompany.com")]
        [Parameter(ParameterSetName = 'Domain',Mandatory = $True, Position = 2,HelpMessage = "Enter Domain to Check.`nExample:uniqueParentCompany.com")]
        [string]$Domain,
        [Parameter(ParameterSetName = 'Full',Mandatory = $True, Position = 3,HelpMessage = "Enter credentials to authenticate to the local domain.",ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'Domain',Mandatory = $True, Position = 3,HelpMessage = "Enter credentials to authenticate to the local domain.",ValueFromPipelineByPropertyName)]
        [System.Management.Automation.Credential()]
        [PSCredential]$Credential
    )
    $userObject = @()
    switch ($PSCmdlet.ParameterSetName){
        'Graph' {
            $user = Get-MgUser -userid $UserPrincipalName | Select-Object *
            $userObject = $user
        }
        'LocalAD'{
            $user = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -Server $Domain -Credential $Credential -erroraction SilentlyContinue
            $userObject = $user 
        }
        'Full'{
            $localUser = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -Server $Domain -Credential $Credential -erroraction SilentlyContinue
            $graphUser = Get-MgUser -userid $UserPrincipalName | Select-Object *
            $userObject = [PSCustomObject]@{
                localUserData       = $localUser
                cloudUserData       = $graphUser
            }
        }
    }
    return $userObject
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





