function Uninstall-CimProgram {
    <#
    .SYNOPSIS
    Uninstalls a specified CIM program.
    .DESCRIPTION
    This function uninstalls a CIM program by its name using the Win32_Product class.
    .COMPONENT
    Endpoint
    .PARAMETER CimProgramName
    The name of the CIM program to uninstall.
    .EXAMPLE
    Uninstall-CimProgram -CimProgramName "Example CIM Program"
    Uninstalls the specified CIM program.
    .NOTES
    You must have administrative privileges to run this function and said account must be able to authenticate to the target machine.
    .OUTPUTS
    None. This function performs an uninstallation and does not return any output.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage = "Name of the CIM program to uninstall.",Position = 0)]
        [string]$CimProgramName
    )
    # Check if the CIM program is installed
    $cimProgram = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -eq $CimProgramName }
    if ($null -eq $cimProgram) {
        Write-Host "CIM program '$CimProgramName' is not installed."
        return
    }

    # Uninstall the CIM program
    try {
        $cimProgram.Uninstall() | Out-Null
        return "CIM program '$CimProgramName' has been uninstalled successfully."
    } catch {
        Write-Error "Failed to uninstall CIM program '$CimProgramName'. Error: $_"
    }
}
SignatureBlock

