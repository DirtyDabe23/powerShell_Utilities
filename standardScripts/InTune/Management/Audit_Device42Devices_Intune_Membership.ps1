$d42Devices = Import-CSV -Path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Intune\Audits\Device42_Resources_Devices_Windows.csv"
$d42DevicesNewNames = @()


ForEAch ($d42Device in $d42Devices)
{
    if ($d42Device.Name -like "*.*")
    {
        $newName = $d42device.name.split(".")[0]

        $d42DevicesNewNames +=[PSCustomObject]@{
            d42DeviceName     = $newName
            d42SerialNumber   = $d42Device.'Serial_#'
            OfficeLocation    = $d42device.Customer  
            }    
    }
    else 
    {
        $d42DevicesNewNames +=[PSCustomObject]@{
            d42DeviceName     = $d42device.Name
            d42SerialNumber   = $d42Device.'Serial_#'
            OfficeLocation    = $d42device.Customer  
            }      
        
    }
}

$d42Devices = $null
$d42DevicesNewNames =  $d42DevicesNewNames | Sort-Object -property "OfficeLocation","d42DeviceName"

$inTuneDevices = Get-MgDeviceManagementManagedDevice -all | Where-Object {($_.OperatingSystem -eq "Windows")} 

Write-Host "The following Devices are not in Device42"
$inTuneDevices | Where-Object {($_.DeviceName -notin $d42DevicesNewNames.d42DeviceName)} | Select-Object -property "DeviceName" | Sort-object -Property "DeviceName"


Write-Host "The following Devices are not in InTune"
$d42DevicesNewNames | Where-Object {($_.d42DeviceName -notin $inTuneDevices.deviceName)} | Sort-Object -property "OfficeLocation","d42DeviceName"
# SIG # Begin signature block#Script Signature# SIG # End signature block





