function Get-CimProgram {
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
        [Parameter(Mandatory = $false,HelpMessage = "The name of the CIM program to retrieve, defaults to all programs.",Position = 0)]
        [string]$CimProgramName = "*"
    )
    $cimPrograms = @()
    if($CimProgramName -eq "*") {
        $cimPrograms = Get-CimInstance -ClassName Win32_Product
    } else {
        $CimProgramName = "*$CimProgramName*"
        Get-CimInstance -ClassName Win32_Product -Filter "Name LIKE '$CimProgramName'" | ForEach-Object {
            $cimPrograms += $_
        }
    }
    if ($cimPrograms.Count -eq 0) {
        Write-Host "No CIM programs found matching the specified name." -ForegroundColor Yellow
        throw "Failed to find any CIM programs matching the specified name."
    }
    else{
        return $cimPrograms
    }
}
SignatureBlock

