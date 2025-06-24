function Get-Device42Devices {
    <#
        .SYNOPSIS
            Get Device42 devices from the API.
        .DESCRIPTION
            This function retrieves devices from the Device42 API and returns them as a PowerShell object.
        .COMPONENT
            Device42
        .PARAMETER Device42URL
            The URL of the Device42 API.
        .PARAMETER APIToken
            The API token for authentication with the Device42 API.
        .PARAMETER Device42Username
            The username for authentication with the Device42 API.
        .EXAMPLE
            Get-Device42Devices -Device42URL "itam.company.com" -APIToken "your_api_token" -Device42Username "admin-user@company.com"
        .NOTES
            This function requires the Device42 API token and username for authentication.
        .OUTPUTS
            A PowerShell object containing the devices retrieved from the Device42 API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Device42 URL`nExample: itam.company.com")]
        [string]$device42url,
        [Parameter(Mandatory = $true)]
        [string]$APIToken,
        [Parameter(Mandatory = $true, HelpMessage = "The User Name to use for authentication`nExample: D42_API")]
        [string]$device42Username
    )
    $useFilter = "?include_cols="
    $properties = "name , customer , total_cpus ,core_per_cpu ,threads_per_core ,cpu_speed , ram ,ram_size_type ,os_name , os_version"
    $encodedProperties = [uri]::EscapeDataString($properties)
    $constructedFilter = $useFilter , $encodedProperties -join ""



    $apiuri ="https://$($device42url)/api/2.0/devices/",$constructedFilter -join ""
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$($device42Username):$($APIToken)")))
    $device42Header = @{
        "Authorization" = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    }
    $device42Devices = (invoke-restmethod -uri $apiuri -Method Get -Headers $device42Header -ErrorAction Stop).devices
    if ($null -eq $device42Devices) {
        Write-Error "No devices found in Device42."
        return
    }
    return $device42Devices
}
SignatureBlock

