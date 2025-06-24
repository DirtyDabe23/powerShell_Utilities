function Get-InTuneApp {
    <#
    .SYNOPSIS
    Retrieves the Intune application details for a specific app.

    .DESCRIPTION
    This function retrieves the details of an Intune application based on the provided app ID.
    
    .PARAMETER AppId
    The ID of the application to retrieve.

    .EXAMPLE
    Get-InTuneApp -AppId "12345678-1234-1234-1234-123456789012"
    
    Retrieves the details of the specified Intune application.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppId
    )

    $uri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$AppId"
    
    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get
        return $response
    } 
    catch {
        Write-Error "Failed to retrieve app details: $_"
        return $null
    }
}
function Get-InTuneAppByDisplayName {
    <#
    .SYNOPSIS
    Retrieves the Intune application details for a specific app by its display name.

    .DESCRIPTION
    This function retrieves the details of an Intune application based on the provided display name.

    .PARAMETER DisplayName
    The display name of the application to retrieve. PLEASE NOTE, IT IS CASE SENSITIVE.

    .EXAMPLE
    Get-InTuneAppByDisplayName -DisplayName "parentCompany PowerShell Module: parentCompanyModule"

    Retrieves the details of the specified Intune application.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    $uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?`$filter=startsWith(DisplayName,'", "$DisplayName", "')" -join ""

    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get
        return $response
    } catch {
        Write-Error "Failed to retrieve app details: $_"
        return $null
    }
}

SignatureBlock

