function Set-parentCompanyUserExtensionAttribute {
    <#
    .SYNOPSIS
    Sets a user extension attribute in Active Directory.
    .DESCRIPTION
    This function sets a specified user extension attribute for a user in Active Directory.
    .COMPONENT
    M365 , EntraID , Graph
    .PARAMETER UserPrincipalName
    The User Principal Name (UPN) of the user to modify.
    .PARAMETER ExtensionAttributeNumber
    The name of the extension attribute to set.
    Valid values are "1" through "15".
    .PARAMETER AttributeValue
    The value to set for the extension attribute.
    .PARAMETER WorkLocation
    If specified, sets the work location for the user.
    .PARAMETER WorkType
    The work type for the user. Valid values are "Shop", "Shop Office", "Office", "Contractor".
    .PARAMETER FirstResponder
    If specified, sets the user as a first responder.
    .PARAMETER ApplyO365AppTypes
    If specified, applies Office 365 app types to the user.
    .PARAMETER o365Type
    Specifies the Office 365 app type for the user. Valid values are "64", "32-NoAccess", "Git-Test", "Excluded".
    .PARAMETER ExcludedFromGlobalConfig
    If specified, marks the user as excluded from global configurations.
    .PARAMETER CompliantUsername
    If specified, marks the user's username as compliant with the naming convention despite failing the rules.
    .EXAMPLE
    Set-parentCompanyUserExtensionAttribute -UserPrincipalName "<UserPrincipalName>" -ExtensionAttributeNumber "1" -AttributeValue "New Value"
    Sets the extension attribute 01 for the specified user to "New Value".
    .EXAMPLE
    Set-parentCompanyUserExtensionAttribute -UserPrincipalName "<UserPrincipalName>" -WorkLocation -WorkType "Office" -FirstResponder -ApplyO365AppTypes -o365Type "64" -ExcludedFromGlobalConfig -CompliantUsername
    Sets multiple easy attributes for the specified user, including work location, first responder status, Office 365 app types, exclusion from global config, and compliance with naming conventions.
    .NOTES
    This function requires the M365 and EntraID modules to be installed and imported.
    It also requires appropriate permissions to modify user attributes in Active Directory.
    .LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.graph.users/?view=graph-powershell-1.0
    .LINK
    https://parentCompany.atlassian.net/wiki/spaces/GOC/pages/1083867137/parentCompany+-+User+Custom+Extension+Attributes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory = $true,ParameterSetName = "ExtensionAttribute")]
        [ValidateSet("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15")]
        [string]$ExtensionAttributeNumber,
        [Parameter(Mandatory = $true,ParameterSetName = "ExtensionAttribute")]
        [string]$AttributeValue,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Select this to set easy attributes for the work location and type.")]
        [switch] $WorkLocation,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Enter the work location for the user.")]
        [ValidateSet("Shop", "Shop Office", "Office", "Contractor")]
        [string] $WorkType,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true if the user is a first responder.")]
        [switch] $FirstResponder,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true to Apply Office 365 App Types to the user")]
        [switch] $ApplyO365AppTypes,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true to Apply Office 365 App Types to the user")]
        [ValidateSet("64", "32-NoAccess", "Git-Test", "Excluded")]
        [switch] $o365Type,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true if they are excluded from Global Configurations")]
        [switch] $ExcludedFromGlobalConfig,
        [Parameter(Mandatory = $false,ParameterSetName = "Easy-Attributes",HelpMessage = "Set to true if their username is compliant with the naming convention despite failing the rules.")]
        [switch] $CompliantUsername
    )
    $postExtensionAttributes = @()
    $user = Get-MGBetaUser -userid $userPrincipalName -ErrorAction Stop
    if (-not $user) {
        Throw "User with UPN '$UserPrincipalName' not found."
    } 
    switch ($PSCmdlet.ParameterSetName) {
        "ExtensionAttribute" {
           $extensionAttribute = "ExtensionAttribute" , "$ExtensionAttributeNumber" -join ""
           $postExtensionAttributes += @{
                $extensionAttribute = $AttributeValue
            } | ConvertTo-JSON -Depth 10
            # Set the extension attribute for the user'
            try{
            $result = Update-MgBetaUser -userid $user.ID -OnPremisesExtensionAttributes $postExtensionAttributes -ErrorAction Stop
            }
            catch {
                Throw "Failed to set extension attribute '$extensionAttribute' for user '$UserPrincipalName'. Error: $_"
            }
            Write-Output "Extension attribute '$extensionAttribute' set to '$AttributeValue' for user '$UserPrincipalName'."
            
        }
        "Easy-Attributes" {
            # Handle the Easy-Attributes parameter set
            if ($WorkLocation) {
                # Set the work location attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute1' = $WorkLocation
                }
            }
            if ($FirstResponder) {
                # Set the first responder attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute2' = "First Responder"
                }
            }
            if ($ApplyO365AppTypes) {
                # Set the O365 app types attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute3' = $o365Type
                }
            }
            if ($ExcludedFromGlobalConfig) {
                # Set the excluded from global config attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute13' = "Y"
                }
            }
            if ($CompliantUsername) {
                # Set the compliant username attribute
                $postExtensionAttributes += @{
                    'ExtensionAttribute14' = "Compliant"
                }
            }
            $finalPost = $postExtensionAttributes | ConvertTo-JSON -Depth 10
            try{
            $result = Update-MgBetaUser -userid $user.Id -OnPremisesExtensionAttributes $finalPost -ErrorAction Stop
            }
            catch {
                Throw "Failed to set extension attributes for user '$UserPrincipalName'. Error: $_"
            }
            return $result
        }
        Default {
            # Handle the default case
            Throw "Invalid parameter set. Please specify either 'ExtensionAttribute' or 'Easy-Attributes'."
        }
    }
}
SignatureBlock

