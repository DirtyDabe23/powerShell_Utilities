$allDevices = Get-Device42Devices -Device42url 'itam.Domain.extension1' -APIToken $d42retrSecret -Device42Username 'GIT_API'
$d42Devices = $allDevices | where-object {($_.os_name -like "Microsoft Windows 1*")}
$inTuneDevices = Get-MgDeviceManagementManagedDevice -all | Where-Object {($_.OperatingSystem -eq "Windows")} 
$d42DeviceAudit = @()
ForEAch ($d42Device in $d42Devices)
{
    if ($d42Device.Name -like "*.*"){
        $newName = $d42device.name.split(".")[0]
            $searchDevice      =[PSCustomObject]@{
            d42DeviceName       = $newName
            OfficeLocation      = $d42device.Customer
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
    else{
            $searchDevice      =[PSCustomObject]@{
            d42DeviceName       = $d42device.Name
            OfficeLocation      = $d42device.Customer
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
}
$d42Devices = $null
$d42Devices =  $d42DevicesNewNames | Sort-Object -property "OfficeLocation","d42DeviceName"

Write-Host "The following Devices are not in Device42"
$inTuneDevices | Where-Object {($_.DeviceName -notin $d42Devices.d42DeviceName)} | Select-Object -property "DeviceName" | Sort-object -Property "DeviceName"
Write-Host "The following Devices are not in InTune"
$d42Devices | Where-Object {($_.d42DeviceName -notin $inTuneDevices.deviceName)} | Sort-Object -property "OfficeLocation","d42DeviceName"
SignatureBlock

