function Install-parentCompanyModule {
    <#
    .SYNOPSIS
    Installs the parentCompany PowerShell module from the specified path.

    .DESCRIPTION
    This function copies the parentCompany PowerShell module from a specified user profile path to the system's PowerShell modules directory.

    .EXAMPLE
    Install-parentCompanyModule

    This will copy the parentCompany module to the default PowerShell modules directory.
    #>

    [CmdletBinding()]
    param ()

    # Copy the parentCompany module to the PowerShell modules directory
    Write-Verbose "Moving all parentCompany Modules to the PowerShell Modules Directory"
    get-childitem -path ("$env:USERPROFILE",'\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\parentCompanyRepo\Modules\' -join "") | Copy-Item -Destination 'C:\Program Files\PowerShell\Modules\' -Recurse -Force -Verbose
    return "parentCompany PowerShell modules installed successfully."
}

SignatureBlock

