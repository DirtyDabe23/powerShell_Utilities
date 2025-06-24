function Get-parentCompanyUser{
    <#
    .SYNOPSIS
    This function will allow you to search a local domain, graph, or both, for the user information.
    .DESCRIPTION
    This function will allow you to search a local domain, graph, or both, for the user information.
    .COMPONENT
    EntraID, ActiveDirectory
    .PARAMETER UserPrincipalName
    The user's UserPrincipalName
    Example: TestUser.LastName@Domain.extension1
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
    Example: Domain.extension1
    .PARAMETER Credential
    Enter the credential for authentication to the local domain.
    .EXAMPLE 
    #Get the User Data from the Local Domain 'Domain.extension1' and from Graph
    Get-parentCompanyUser -UserPrincipalName "David.Drosdick@Domain.extension1" -Full -Domain "Domain.extension1"
    .EXAMPLE
    #Get the User Data from Graph
    Get-parentCompanyUser -UserPrincipalName "David.Drosdick@Domain.extension1" -Graph
    .EXAMPLE 
    #Get the User Data from the Local Domain 'Domain.extension1'
    Get-parentCompanyUser -UserPrincipalName "David.Drosdick@Domain.extension1" -LocalAD -Domain "Domain.extension1"
    .NOTES
    This is largely just for learning how to write a module!
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser
    .OUTPUTS
    A user object from either Graph, Local AD, or both depending on the parameter set used
    #>
    [CmdletBinding(DefaultParameterSetName = 'Full')] 
    param(
        #This Parameter is available to all sets
        [Parameter(Mandatory = $True,Position = 0,HelpMessage = "Enter a UPN for the user, `nExample: TestUser.TestLast@Domain.extension1",ValueFromPipelineByPropertyName)]
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
        [Parameter(ParameterSetName = 'Full',Mandatory = $True, Position = 2,HelpMessage = "Enter Domain to Check.`nExample:Domain.extension1")]
        [Parameter(ParameterSetName = 'Domain',Mandatory = $True, Position = 2,HelpMessage = "Enter Domain to Check.`nExample:Domain.extension1")]
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
SignatureBlock

