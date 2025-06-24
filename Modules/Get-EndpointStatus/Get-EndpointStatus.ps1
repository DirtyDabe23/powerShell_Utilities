function Get-EndpointStatus {
    <#
    .SYNOPSIS
    Retrieves the status of the endpoint, including hardware and software information, and provides recommendations based on the collected data.
    .DESCRIPTION
    This script checks the operating system, PowerShell version, disk space, uptime, memory, processor speed, and other system parameters.
    It provides recommendations for improving the endpoint's performance and security based on the collected data.
    .COMPONENT
    Endpoint
    .PARAMETER All
    Retrieves all information about the endpoint, including hardware and software details, and recommendations.
    .PARAMETER EndpointData
    Retrieves only the endpoint data, including hardware and software details.
    .PARAMETER Recommendations
    Retrieves only the recommendations based on the endpoint data.
    .INPUTS
    None. You cannot pipe objects to this function.
    .OUTPUTS
    Returns a custom object containing the endpoint status and recommendations.
    .EXAMPLE
    Get-EndpointStatus
    .NOTES
    This script retrieves the status of the endpoint, including hardware and software information, and provides recommendations
    based on the collected data. It checks for the operating system, PowerShell version, disk space, uptime, memory, processor speed, and other system parameters.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0,ParameterSetName = "Default")]
        [switch] $All,
        [Parameter(Mandatory = $false,Position = 0,ParameterSetName = "EndpointData")]
        [switch] $EndpointData,
        [Parameter(Mandatory = $false,Position = 0,ParameterSetName = "Recommendations")]
        [switch] $Recommendations
    )
    $recommendations = @()
    $macOS = $IsMacOS
    $linux = $IsLinux
    $windows = $IsWindows
    if ($macOS) {
        throw "This script is not designed for macOS. Please use a macOS-specific script."
    }
    if ($linux) {
        throw "This script is not designed for Linux. Please use a Linux-specific script."
    }
    if (!($windows)){
        throw "This script is not designed for this operating system. Please use a Windows-specific script."
    }
    $programs = Get-CimInstance -ClassName Win32_Product | Select-Object -Property Name, Version, InstallDate
    $runningAV = Get-CimInstance -namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Select-Object *
    $diskInfo = Get-Disk | Where-Object { $_.OperationalStatus -eq "Online"} 
    $computerInfo = Get-ComputerInfo | select-object -Property *
    $uptime = Get-Uptime
    $hostData = $host
    if ($hostData.Name -ne "ConsoleHost") {
        $recommendations += "This script is designed to run in the PowerShell console. Please run it in the PowerShell console."
        return
    }
    if ($hostData.Version -lt "7.0") {
        $recommendations += "This script requires PowerShell version 7.0 or higher. Please update your PowerShell version."
        return
    }
    if ($runningAV.Count -eq 0) {
        $recommendations += "No antivirus software is running on the endpoint. Ensure that an antivirus solution is installed and running."
    } 
    else {
            if (!($runningAV.displayName -eq 'Windows Defender')){
                $recommendations += "The endpoint is running antivirus software other than Windows Defender. Considering Removing $($runningAV.displayName) and using Windows Defender for better compatibility and performance."
            }
            else {
                Write-OUtput "Windows Defender is running on the endpoint."
            }
    }
    if ($diskInfo.Count -eq 0) {
        $recommendations += "No disks found. Ensure the endpoint has at least one disk."
    } else {
        foreach ($disk in $diskInfo) {
            if ($disk.Size -lt 100GB) {
                $recommendations += "The disk $($disk.DeviceID) is less than 100GB. Consider upgrading the disk for better performance."
            }
            if ($disk.FreeSpace / $disk.Size -lt 0.1) {
                $recommendations += "The disk $($disk.DeviceID) has less than 10% free space. Consider freeing up space or upgrading the disk."
            }
        }
    }

    if ($uptime.Days -gt 4) {
        $recommendations += "The endpoint has been up for more than 4 days. Consider rebooting to apply updates and clear memory."
    }
    if ($computerInfo.CsTotalPhysicalMemory -lt 8GB) {
        $recommendations += "The endpoint has less than 8GB of RAM. Consider upgrading the memory for better performance."
    }
    if ($computerInfo.CsProcessors.MaxClockSpeed -lt 2000) {
        $recommendations += "The endpoint's processor speed is less than 2GHz. Consider upgrading the processor for better performance."
    }
    if ($computerInfo.CsProcessors.NumberOfLogicalProcessors -lt 4) {
        $recommendations += "The endpoint has less than 4 logical processors. Consider upgrading the processor for better performance."
    }
    $user = $computerInfo.CsUserName
    if ($user -notin @("SYSTEM", "LocalService", "NetworkService")) {
        $recommendations += "The endpoint is not running under a system account. Ensure the user account is appropriate for the endpoint's role."
    }
    if ($user -notin @("Administrator", "Admin", "Root")) {
        $recommendations += "The endpoint is not running under an administrative account. Ensure the user account has the necessary permissions."
    }
    if ($computerInfo.CsBootupState -ne "Normal") {
        $recommendations += "The endpoint boot state is not normal. Check for any issues during bootup."
    }
    if ($computerInfo.OsStatus -ne "Running") {
        $recommendations += "The endpoint operating system is not running. Check for any issues with the OS."
    }
    if ($programs.Count -eq 0) {
        $recommendations += "No programs found. Ensure the endpoint has the necessary software installed."
    } else {
        foreach ($program in $programs) {
            if ($program.InstallDate -lt (Get-Date).AddYears(-1)) {
                $recommendations += "The program '$($program.Name)' was installed more than a year ago. Consider updating or removing it."
            }
        }
    }
    if ($null -eq $computerInfo.CsChassisSKUNumber) {
        $recommendations += "The endpoint chassis SKU number is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CsManufacturer) {
        $recommendations += "The endpoint manufacturer information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CsModel) {
        $recommendations += "The endpoint model information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CsTotalPhysicalMemory) {
        $recommendations += "The endpoint total physical memory information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.PhysicallyInstalledMemory) {
        $recommendations += "The endpoint physically installed memory information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.OsFreePhysicalMemory) {
        $recommendations += "The endpoint OS free physical memory information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.OsFreeVirtualMemory) {
        $recommendations += "The endpoint OS free virtual memory information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.OsInUseVirtualMemory) {
        $recommendations += "The endpoint OS in-use virtual memory information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSPRocessors.Name) {
        $recommendations += "The endpoint processor name information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSPRocessors.MaxClockSpeed) {
        $recommendations += "The endpoint processor speed information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSPRocessors.NumberofCores) {
        $recommendations += "The endpoint processor number of cores information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSPRocessors.NumberOfLogicalProcessors) {
        $recommendations += "The endpoint processor number of logical processors information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSPRocessors.Status) {
        $recommendations += "The endpoint processor status information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSPowerSupplyState) {
        $recommendations += "The endpoint power supply state information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.CSThermalState) {
        $recommendations += "The endpoint thermal state information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.OsOrganization) {
        $recommendations += "The endpoint OS organization information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.TimeZone) {
        $recommendations += "The endpoint timezone information is not available. Ensure the system is properly configured."
    }
    if ($null -eq $computerInfo.LogonServer) {
        $recommendations += "The endpoint logon server information is not available. Ensure the system is properly configured."
    }
    $endpointData = @()
    $endpointData += [pscustomobject]@{
                endpointStandardName                = $computerinfo.CsName
                endpointSerialNumber                = $computerInfo.BiosSerialNumber
                endpointDNSName                     = $computerinfo.CsDNSHostName
                endpointUser                        = $computerInfo.CsUserName
                endpointWorkGroup                   = $computerInfo.CsWorkgroup
                endpointDomain                      = $computerInfo.CsDomain
                endpointOSOrganization              = $computerInfo.OsOrganization
                endpointChassis                     = $computerInfo.CsChassisSKUNumber
                endpointManufacturer                = $computerInfo.CsManufacturer
                endpointModel                       = $computerInfo.CsModel
                endpointTotalPhysicalMemory         = $computerInfo.CsTotalPhysicalMemory
                endpointPhysicallyInstalledMemory   = $computerInfo.PhysicallyInstalledMemory
                endpointOsFreePhysicalMemory        = $computerInfo.OsFreePhysicalMemory
                endpointOsFreeVirtualMemory         = $computerInfo.OsFreeVirtualMemory
                endpointOsInUseVirtualMemory        = $computerInfo.OsInUseVirtualMemory
                endpointProcessorName               = $computerInfo.CSProcessors.Name
                endpointProcessorSpeedMhz           = $computerInfo.CSProcessors.MaxClockSpeed
                endpointProcessorNumOfCores         = $computerInfo.CSProcessors.NumberofCores
                endpointProcessorNumOfThreads       = $computerInfo.CSProcessors.NumberOfLogicalProcessors
                endpointProcessorStatus             = $computerInfo.CSPRocessors.Status
                endpointPowerSupplyState            = $computerInfo.CSPowerSupplyState
                endpointThermalState                = $computerInfo.CSThermalState
                endpointBootState                   = $computerInfo.CsBootupState
                endpointOSVersion                   = $computerInfo.OSVersion
                endpointOSStatus                    = $computerInfo.OsStatus
                endpointUptime                      = $computerInfo.OsUptime
                endpointNumUsers                    = $computerInfo.OsNumberOfUsers
                endpointTimezone                    = $computerInfo.TimeZone
                endpointLogonServer                 = $computerInfo.LogonServer
    }
    switch ($PSCmdlet.ParameterSetName){
        $recommendations { 
            $finalReturn = ForEach ($recommendation in $recommendations) {
                [pscustomobject]@{
                    recommendation = $recommendation
                }
            }
        }
        $endpointData {
            $finalReturn = $endpointData

        }
        Default{
            $finalReturn = [pscustomobject]@{
            endpointStatus = $endpointData
            recommendations = ForEAch ($recommendation in $recommendations) {
                [pscustomobject]@{
                    recommendation = $recommendation
                }
            }
            }         
        }
    }
    
    return $finalReturn
}