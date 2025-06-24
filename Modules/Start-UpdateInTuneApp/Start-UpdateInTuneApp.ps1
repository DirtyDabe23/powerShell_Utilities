function Start-UpdateInTuneApp {
    <#
    .SYNOPSIS
    Uploads a new installer version for an Intune Win32 application while keeping all other options the same.

    .DESCRIPTION
    This script automates the process of uploading a new .intunewin installer for an existing Intune Win32 app using Microsoft Graph API. It:
    - Retrieves the app by AppId or DisplayName
    - Creates a new content version
    - Uploads the new installer file
    - Commits the upload

    .PARAMETER AppId
    The AppId of the Intune Win32 app to update.

    .PARAMETER DisplayName
    The display name of the Intune Win32 app to update (case sensitive).

    .PARAMETER InstallerPath
    The path to the new .intunewin installer file.

    .EXAMPLE
    Start-UpdateInTuneApp1 -AppId "<AppId>" -InstallerPath "C:\Installers\MyApp_v2.intunewin"

    .EXAMPLE
    .Start-UpdateInTuneApp -DisplayName "My App" -InstallerPath "C:\Installers\MyApp_v2.intunewin"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "The AppId of the Intune Win32 app to update.",Position = 0)]
        [string]$AppId,
        [Parameter(Mandatory = $false,HelpMessage = "Display name of the Intune Win32 app to update (case sensitive).",Position = 1)]
        [string]$DisplayName,
        [Parameter(Mandatory = $true,HelpMessage = "Path to the new .intunewin installer file.",Position = 0)]
        [string]$InstallerPath
    )

    if (-not $AppId -and -not $DisplayName) {
        throw "You must specify either AppId or DisplayName."
    }

    if ($DisplayName) {
        $app = Get-InTuneAppByDisplayName -DisplayName $DisplayName
        if ($app.value -and $app.value.Count -gt 0) {
            $AppId = $app.value[0].id
        } else {
            Write-Error "No Intune app found with display name '$DisplayName'."
            return
        }
    } else {
        $app = Get-InTuneApp -AppId $AppId
        if (-not $app) {
            Write-Error "No Intune app found with AppId '$AppId'."
            return
        }
    }

    # Step 1: Create a new content version
    $uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$AppId/createUploadSession"
    $body = @{ fileName = [System.IO.Path]::GetFileName($InstallerPath) } | ConvertTo-Json
    $uploadSession = Invoke-MgGraphRequest -Uri $uri -Method Post -Body $body -ContentType 'application/json'

    if (-not $uploadSession.uploadUrl) {
        Write-Error "Failed to create upload session."
        return
    }

    # Step 2: Upload the installer file in chunks
    $chunkSize = 4MB
    $fs = [System.IO.File]::OpenRead($InstallerPath)
    $buffer = New-Object byte[] $chunkSize
    $offset = 0
    while ($offset -lt $fs.Length) {
        $read = $fs.Read($buffer, 0, $chunkSize)
        $rangeStart = $offset
        $rangeEnd = $offset + $read - 1
        $headers = @{
            'Content-Length' = $read
            'Content-Range' = "bytes $rangeStart-$rangeEnd/$($fs.Length)"
        }
        Invoke-RestMethod -Uri $uploadSession.uploadUrl -Method Put -Headers $headers -Body ($buffer[0..($read-1)])
        $offset += $read
    }
    $fs.Close()

    Write-Output "Installer uploaded successfully. The new version will be processed by Intune."
}
SignatureBlock

