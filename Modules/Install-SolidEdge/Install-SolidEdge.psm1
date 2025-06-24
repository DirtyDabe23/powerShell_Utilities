function Install-SolidEdge{
    <#
    .SYNOPSIS
    Installs Solid Edge software.
    .DESCRIPTION
    This function installs Solid Edge software using the provided installer path and options.
    It can also set environment variables and optionally reboot the machine after installation.
    .COMPONENT
    Endpoint
    .PARAMETER InstallerPath
    The path to the Solid Edge installer executable.
    .PARAMETER Options
    Additional options to pass to the installer.
    .PARAMETER SetEnvironmentVariables
    Specifies whether to set environment variables after installation.
    .PARAMETER SELicenseServer
    Specifies the Solid Edge license server to set after installation.
    .PARAMETER RebootAfterInstallation
    Specifies whether to reboot the machine after installation.
    .PARAMETER ForceReboot
    Specifies whether to force a reboot without user confirmation after installation.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'"
    Installs Solid Edge silently with specified options.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation
    Installs Solid Edge and sets the environment variables for the license server, then reboots the machine after installation.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation -ForceReboot
    Installs Solid Edge, sets the environment variables for the license server, and forces a reboot immediately after installation.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation -ForceReboot:$false
    Installs Solid Edge, sets the environment variables for the license server, and reboots the machine in 5 minutes after installation, allowing the user to save their work.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables
    Installs Solid Edge and sets the environment variables for the license server without rebooting the machine.
    .EXAMPLE
    Install-SolidEdge -InstallerPath "C:\Path\To\SolidEdgeInstaller.exe" -Options "/s /v '/qn'" -SetEnvironmentVariables -SELicenseServer "29000@Hertz-TFS" -RebootAfterInstallation -ForceReboot:$true
    Installs Solid Edge, sets the environment variables for the license server, and forces a reboot immediately after installation.
    .NOTES
    You must have administrative privileges to run this function and said account must be able to authenticate to the target machine.
    .OUTPUTS
    None. This function performs an installation and does not return any output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,helpMessage = "Path to the Solid Edge installer executable.`nYou can target a full version OR a service pack!",Position = 0)]
            [string]$InstallerPath,
        [Parameter(Mandatory = $false,HelpMessage = "Additional options for the installer, e.g., '/s /v '/qn'")]
        [ValidateNotNullOrEmpty()]
            [string]$Options = "/s /v '/qn'",
        [Parameter(Mandatory = $false,HelpMessage = "Use ths parameter to specify you want to set environment variables after the installation completes.`nThis is useful for setting up paths or configurations that Solid Edge requires to run properly.")]
            [switch]$SetEnvironmentVariables,
        [Parameter(Mandatory = $false,ParameterSetName = "EnvironVariables", HelpMessage = "Use this parameter to specify you want to set the Solid Edge license after the installation completes.`nThis is useful for setting up the license server or other licensing configurations that Solid Edge requires to run properly.`n`
        Note: This parameter is only used if the SetEnvironmentVariables switch is also specified.`nIf you do not specify this parameter, the default license server will be used.`nYou can specify a different license server by providing the server name and port in the format 'server:port'.`n
        As this is an parentCompany module, the default license server is set to '29000@Hertz-TFS'.")]
        [Parameter(Mandatory = $false,ParameterSetName = "EnvironVariablesReboot", HelpMessage = "Use this parameter to specify you want to set the Solid Edge license after the installation completes.`nThis is useful for setting up the license server or other licensing configurations that Solid Edge requires to run properly.`n`
        Note: This parameter is only used if the SetEnvironmentVariables switch is also specified.`nIf you do not specify this parameter, the default license server will be used.`nYou can specify a different license server by providing the server name and port in the format 'server:port'.`n
        As this is an parentCompany module, the default license server is set to '29000@Hertz-TFS'.")]
            [string]$SELicenseServer = '29000@Hertz-TFS',
        [Parameter(Mandatory = $false , ParameterSetName = "EnvironVariablesReboot", HelpMessage = "Use this parameter to specify you want to reboot the machine after the installation completes.`nThis is useful for ensuring that all changes take effect and that Solid Edge is ready to use after installation.`n`
        Note: This parameter is only used if the SetEnvironmentVariables switch is also specified.`nIf you do not specify this parameter, the machine will not be rebooted after the installation completes.")]
            [switch]$RebootAfterInstallation,
        [Parameter(Mandatory = $false, ParameterSetName = "EnvironVariablesReboot", HelpMessage = "Use this to specify if you want to force a reboot or wait for user confirmation before rebooting.`nThis is useful for ensuring that the machine is rebooted immediately after the installation completes, without waiting for user confirmation.")]
            [switch]$ForceReboot
        )
    # Check if the installer path exists
    if (-Not (Test-Path -Path $InstallerPath)) {
        Write-Error "Installer path '$InstallerPath' does not exist."
        return
    }
    # Start the installation process
    try {
        Write-Host "Starting Solid Edge installation... This can take up to 10 minutes"
        Start-Process -FilePath $InstallerPath -ArgumentList $Options -Wait -NoNewWindow
        Write-Host "Solid Edge installation completed successfully."
        if($SetEnvironmentVariables){
            Write-Host "Setting environment variables for Solid Edge..."
            [System.Environment]::SetEnvironmentVariable('SE_License_Server', $SELicenseServer,'Machine')
            Write-Host "Environment variables set successfully. You NEED to restart your computer for the changes to take effect."
            if($RebootAfterInstallation) {
                if($ForceReboot) {
                    Write-Host "Rebooting the machine immediately..."
                    Restart-Computer -Force
                } else {
                    Write-Host "Rebooting the machine in 5 minutes. Please save your work."
                    Restart-Computer -Delay 300 -Confirm:$false
                    return "The machine will reboot in 5 minutes. Please save your work."
                }
                    return "Please restart your computer to apply the changes."
                }
            }
        return "Solid Edge installation completed successfully. Environment variables set. Please restart your computer to apply the changes."
    } 
    catch {
        throw "An error occurred during the installation: $_"
    }
}
SignatureBlock

