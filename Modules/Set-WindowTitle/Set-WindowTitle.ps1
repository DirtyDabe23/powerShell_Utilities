function Set-WindowTitle {
    <#
    .SYNOPSIS
    Sets the title of the current PowerShell window.
    .DESCRIPTION
    This function allows you to set the title of the current PowerShell window to a specified string
    .COMPONENT
    PowerShell
    .PARAMETER Title
    The title to set for the PowerShell window.
    .EXAMPLE
    Set-WindowTitle -Title "My PowerShell Window"
    This command sets the title of the current PowerShell window to "My PowerShell Window".
    .NOTES
    THis function is useful for organizing multiple PowerShell windows or scripts.
    .OUTPUTS
    None
    #>
    [CmdletBinding()]
    param (
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1, 100)]
    # Ensure the title is not null, empty, and has a reasonable length
    [Parameter(Mandatory = $true,HelpMessage = "Enter the title for the PowerShell window.",
                   Position = 0)]
        [string]$Title
    )
    # Set the title of the current PowerShell window
    $host.UI.RawUI.WindowTitle = $Title
    Write-Host "Window title set to: $Title" -ForegroundColor Green
}
SignatureBlock

