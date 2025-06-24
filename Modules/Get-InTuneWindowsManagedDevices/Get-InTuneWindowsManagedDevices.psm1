function Get-InTuneWindowsManagedDevices{
    <#
    .SYNOPSIS
    This module pulls all of the Windows Managed Devices from InTune.
    .DESCRIPTION
    This module pulls all of the Windows Managed Devices from InTune. It does not support any parameters, it simply returns all devices, their DisplayName, 
    Operating System, ID, DeviceID, Location, Department, and Primary User, and Primary User Email
    .COMPONENT
    EntraID, Intune
    .EXAMPLE
    Get-InTuneWindowsManagedDevices
    .NOTES
    General notes
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    .OUTPUTS
    A list of all Windows Managed Devices in InTune with their details.
    #>
    $allDevices = Get-MgBetaDevice -All -ConsistencyLevel eventual -Property * | Select-Object -Property *
    $windowsManagedDevices = $allDevices| where-object {($_.ManagementType -eq 'MDM') -and ($_.OperatingSystem -eq 'Windows')}
    $deviceDetails = @()
    forEach ($managedDevice in $windowsManagedDevices){
        $deviceOwner = Get-MgDeviceRegisteredUser -DeviceId $managedDevice.Id -Property * | Select-Object -Property additionalproperties -ExpandProperty AdditionalProperties
        if ($null -ne $deviceOwner.userPrincipalName){
            $deviceOwnerDetails = Get-MgBetaUser -userid $deviceOwner.userPrincipalName
        } 
        $shopOrOffice = $null
        if ($null -ne $deviceOwnerDetails.OnPremisesExtensionATtributes.ExtensionAttribute1){
            [string]$shopOrOffice = $deviceOwnerDetails.OnPremisesExtensionAttributes.ExtensionAttribute1
        }
        else{
            $shopOrOffice = "Not Found"
        }
        $OSVersion = $managedDevice.operatingSystemVersion
        if ($OSVersion -like "10.0.1*"){
            $OSVersion = "Windows 10"
        }
        else{
            $OSVersion = "Windows 11"
        }
        if($null -eq $deviceOwner){
            $deviceDepartment   = "No listed department"
            $deviceLocation     = "No listed location"
            $deviceOwner        = "No listed owner"
            $deviceOwnerEmail   = "No listed owner" 
        }
        else{
            $deviceDepartment   = $deviceOwnerDetails.department
            $deviceLocation     = $deviceOwnerDetails.officeLocation
            $deviceOwner        = $deviceOwnerDetails.displayName
            $deviceOwnerEmail   = $deviceOwnerDetails.userPrincipalName 
        }
        $deviceDetails += [PSCustomObject]@{
            deviceDisplayName               =   $managedDevice.DisplayName
            deviceOperatingSystem           =   $OSVersion
            deviceID                        =   $managedDevice.Id
            deviceDeviceID                  =   $managedDevice.DeviceId
            deviceLocation                  =   $deviceLocation
            deviceDepartment                =   $deviceDepartment
            devicePrimaryUser               =   $deviceOwner
            devicePrimaryUserEmail          =   $deviceOwnerEmail
            devicePrimaryUserShoporOffice   =   $shopOrOffice
        }
    }
    $sortedDetails = $deviceDetails | sort-object -property @{expression="deviceOperatingSystem"; asc=$true},@{Expression = "deviceLocation";Descending =$true}, @{expression="deviceDisplayName"; asc=$true}
    return $sortedDetails
}
SignatureBlock

