$allDevices = Get-Device42Devices -Device42url 'itam.Domain.extension1' -APIToken $d42retrSecret -Device42Username 'GIT_API'
$d42Devices = $allDevices | where-object {($_.os_name -like "Microsoft Windows 10*")}
$inTuneDevices = Get-InTuneWindowsManagedDevices
$d42DevicesNewNames = @()
ForEAch ($d42Device in $d42Devices)
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
$d42InTuneWin11Ready | Format-Table
SignatureBlock

