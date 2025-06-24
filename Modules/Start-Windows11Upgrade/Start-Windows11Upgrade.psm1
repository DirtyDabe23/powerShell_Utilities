function Start-Windows11Upgrade{
    <#
    .SYNOPSIS
    Starts the Windows 11 Upgrade process using the official upgrade tool.
    .DESCRIPTION
    This function downloads the Windows 11 Upgrade Tool from Microsoft's official site and starts the upgrade process
    with specified arguments.
    .PARAMETER Quiet
    If specified, runs the upgrade in quiet mode without user interaction.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Run the upgrade in quiet mode without user interaction.')]
        [switch]$Quiet,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Directory to store the upgrade tool. Defaults to C:\_Windows_FU\packages.')]
        [string]$Directory = 'C:\_Windows_FU\packages'
    )
    
    $dir = $Directory
    if ($dir -notlike 'C:\*') {
        Write-Host "Directory must be on the C: drive. Defaulting to C:\_Windows_FU\packages."
        $dir = 'C:\_Windows_FU\packages'
    }
    # Ensure the directory exists
    if (!(Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
    # Download the Windows 11 Upgrade Tool
    Write-Host "Downloading Windows 11 Upgrade Tool to $dir..."
    $ProgressPreference = 'SilentlyContinue' # Suppress progress bar
    $ErrorActionPreference = 'Stop' # Stop on errors
    $global:ProgressPreference = 'SilentlyContinue'
    $global:ErrorActionPreference = 'Stop'
    # Define the URL and file path
    $url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
    $file = "$($dir)\Win11Upgrade.exe"
    # Remove the file if it already exists
    Write-Host "Checking for existing upgrade tool..."
    if (Test-Path $file) {
        Write-Host "Existing upgrade tool found at $file. Removing it..."
        # Remove the existing file
        Remove-Item -Path $file -Force
    }
    # Download the upgrade too
    Write-Host "Downloading Windows 11 Upgrade Tool..."
    Invoke-RestMethod -Uri $url -OutFile $file -HttpVersion '1.1' -UseBasicParsing
    if($quiet){
        Write-Host "Running Windows 11 Upgrade Tool in quiet mode..."
        Write-Verbose "Start the upgrade process with quiet mode and other arguments"
        Write-Verbose "Note: The '/quiet' argument is used to run the upgrade without user interaction"
        Write-Verbose "'/auto upgrade' is used to automatically upgrade the system"
        Write-Verbose "'/EULA accept' is used to accept the End User License Agreement"
        Write-Verbose "The '/copylogs $dir' argument is used to copy logs to the specified directory"
        # Start the upgrade process with quiet mode and other arguments
        Write-Host "Starting the upgrade process... This may take some time."
        Start-Process -FilePath $file -ArgumentList "/QuitInstall /SkipEULA /auto upgrade /copylogs $dir" -Wait -NoNewWindow
        Write-Host "Windows 11 Upgrade Tool has been started in quiet mode. Please wait for the upgrade to complete."
        Write-Host "You can check the logs in the specified directory: $dir"
        Write-Host "If you need to interact with the upgrade process, please run this script without the -Quiet parameter."
        Write-Host "Note: The upgrade process may take some time to complete. Please be patient."
        Write-Host "If you encounter any issues, please check the logs in the specified directory: $dir"
    }
    else {
        Write-Host "Running Windows 11 Upgrade Tool..."
        Write-Host "This is not in quiet mode. You will need to interact with the upgrade process."
        Write-Verbose "Start the upgrade process without quiet mode"
        Write-Verbose "This is useful to see the upgrade process and interact with it, and so the user can accept the EULA and be notified of reboots and any other prompts"
        Start-Process -FilePath $file
    }
}
SignatureBlock

