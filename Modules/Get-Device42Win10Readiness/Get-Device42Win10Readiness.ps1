function Get-Device42Win10Readiness{
    <#
    .SYNOPSIS
        This script audits Device42 devices for compatibility with Windows 11 and Intune membership.
    .DESCRIPTION
        The script retrieves devices from Device42, checks their compatibility with Windows 11 based on RAM and CPU specifications,
        and verifies their Intune membership status. It returns a sorted list of devices with their compatibility status and reasons for incompatibility.
    .COMPONENT
        Device42, Intune
    .PARAMETER d42ApiToken
    The API token for Device42.
    .PARAMETER d42Username
    The username for Device42.
    .EXAMPLE
        Get-Device42Win10Readiness -d42ApiToken "your_device42_api_token" -d42Username "your_device42_username"
    .OUTPUTS
        A sorted list of devices with their compatibility status, Intune membership status, primary user information, and reasons for incompatibility if applicable.
    .NOTES 
    1. Retrieves devices from Device42 that are running Windows 10 and do not have
        the specified OS version.
    2. Checks each device's RAM and CPU specifications to determine Windows 11 compatibility.
    3. Verifies if each device is managed by Intune.
    4. Returns a sorted list of devices with their compatibility status, Intune membership status
        primary user information, and reasons for incompatibility if applicable.
    5. Sorts the output by compatibility status, Intune membership status, office location, and device name.
    6. Outputs the final list of devices.

    #>
    [CmdletBinding()]
    param(
    [Parameter(Mandatory = $true,HelpMessage = "Device42 API Token",Position = 1)]
    [string]$d42ApiToken
    )
    $allDevices = Get-Device42Devices -Device42url 'itam.Domain.extension1' -APIToken $d42ApiToken -Device42Username 'GIT_API'
    $d42Devices = $allDevices | where-object {($_.os_name -like "Microsoft Windows 10*") -and ($_.os_version -notlike "*26100*")}
    $inTuneDevices = Get-InTuneWindowsManagedDevices
    $d42DevicesNewNames = @()
    ForEach ($d42Device in $d42Devices)
    {
        $searchName             = $null 
        $compatbility           = $null
        $incompatbilityReason   = $null 
        if ($d42Device.Name -like "*.*"){
            $searchName = $d42device.name.split(".")[0]

        }
        else{
            $searchName = $d42device.name
        }
        if ($searchName -notin $intuneDevices.devicedisplayname){
            $inTuneStatus = "Not MDM Managed"
        }
        else{
            $inTuneStatus = "MDM Managed"
            $intuneDevice = $intuneDevices | where-object {$_.devicedisplayname -eq $searchName}
        }
        if ($d42device.RAM -le "4"){
            $incompatbilityReason       = "Not Compatible: Insufficient RAM"
        }
        if($d42device.cpu_speed -lt "1.0" -or $d42device.core_per_cpu -lt "2"){
            if ($null -ne $incompatbilityReason){
                $incompatbilityReason += "`nNot Compatible: Insufficient CPU"
            }
            else{
                $incompatbilityReason = "Not Compatible: Insufficient CPU"
            }
        }
        if ($null -eq $incompatbilityReason){
            $compatbility = "Compatible"
            $incompatbilityReason = "N/A"
        }
        else{
            $compatbility = "Not Compatible"
        }
        $d42DevicesNewNames +=[PSCustomObject]@{
        d42DeviceName       = $searchName
        OfficeLocation      = $d42device.Customer
        intuneStatus        = $inTuneStatus
        primaryUser         = $intuneDevice.devicePrimaryUser
        primaryUserEmail    = $intuneDevice.userPrincipalName
        shopOrOffice        = $intuneDevice.devicePrimaryUserShoporOffice
        win11Ready          = $compatbility
        incompabilityReason = $incompatbilityReason
        cpuCount            = $d42device.total_cpus
        cpuCoreCount        = $d42device.core_per_cpu
        threadPerCore       = $d42device.threads_per_core
        cpuSpeed            = $d42device.cpu_speed
        RAMSize             = $d42device.ram
        RAMUnit             = $d42device.ram_size_type   
        osName              = $d42device.os_name
        osVersion           = $d42device.os_version
        } 
    }
    $d42InTuneWin11Ready = $d42DevicesNewNames | Sort-Object -Property @{expression = "compatbility"; descending = $false}, @{expression = "intuneStatus"; descending = $false}, @{expression = "OfficeLocation"}, @{expression = "d42DeviceName"; descending = $false}
    return $d42InTuneWin11Ready
} 
SignatureBlock

