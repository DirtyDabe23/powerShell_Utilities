$syncGroupName = "TT Prod File Share Sync Group"
$resourceGroupName = "TT_Prod_File_Share"
$storageSyncServiceName = "TT_Prod_File_Share_Sync"

#Run this on every server 
#Disables IE Security Enhanced
$installType = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\").InstallationType

# This step is not required for Server Core
if ($installType -ne "Server Core") {
    # Disable Internet Explorer Enhanced Security Configuration 
    # for Administrators
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 -Force

    # Disable Internet Explorer Enhanced Security Configuration 
    # for Users
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 -Force

    # Force Internet Explorer closed, if open. This is required to fully apply the setting.
    # Save any work you have open in the Internet Explorer browser. This will not affect other browsers,
    # including Microsoft Edge.
    Stop-Process -Name iexplore -ErrorAction SilentlyContinue
}



# Gather the OS version
$osver = [System.Environment]::OSVersion.Version

# Download the appropriate version of the Azure File Sync agent for your OS.
if ($osver.Equals([System.Version]::new(10, 0, 20348, 0))) {
    Invoke-WebRequest -Uri https://aka.ms/afs/agent/Server2022 -OutFile "StorageSyncAgent.msi" 
} elseif ($osver.Equals([System.Version]::new(10, 0, 17763, 0))) {
    Invoke-WebRequest -Uri https://aka.ms/afs/agent/Server2019 -OutFile "StorageSyncAgent.msi" 
} elseif ($osver.Equals([System.Version]::new(10, 0, 14393, 0))) {
    Invoke-WebRequest -Uri https://aka.ms/afs/agent/Server2016 -OutFile "StorageSyncAgent.msi" 
} elseif ($osver.Equals([System.Version]::new(6, 3, 9600, 0))) {
    Invoke-WebRequest -Uri https://aka.ms/afs/agent/Server2012R2 -OutFile "StorageSyncAgent.msi" 
} else {
    throw [System.PlatformNotSupportedException]::new("Azure File Sync is only supported on Windows Server 2012 R2, Windows Server 2016, Windows Server 2019 and Windows Server 2022")
}

# Install the MSI. Start-Process is used to PowerShell blocks until the operation is complete.
# Note that the installer currently forces all PowerShell sessions closed - this is a known issue.
Start-Process -FilePath "StorageSyncAgent.msi" -ArgumentList "/quiet" -Wait

# Note that this cmdlet will need to be run in a new session based on the above comment.
# You may remove the temp folder containing the MSI and the EXE installer
Remove-Item -Path ".\StorageSyncAgent.msi" -Recurse -Force

#Enter the name of the Storage Sync Service to Add
$storageSync = Get-AzSTorageSyncService -Name $storageSyncServiceName -ResourceGroupName $resourceGroupName
$registeredServer = Register-AzStorageSyncServer -ParentObject $storageSync

Get-AzStorageSyncSErverEndpoint  -ResourceGroupName $resourceGroupName -StorageSyncServiceName $storageSyncServiceName -SyncGroupName $syncGroupName



$driveLetter = "F"
$drive = Get-PSDrive -Name $driveLetter
$driveTotal = $drive.Used + $drive.Free
$freeSpacePercent = [math]::Round(($drive.Free / $drivetotal) * 100)
Write-Output "Free space on drive $drive is $freeSpacePercent%"

#Server Endpoint Path
$serverEndpointPath = $driveLetter + ":\GlobalFS"


if (!(Test-Path $serverEndpointPath))
{
    New-Item -Path "$serverEndpointPath" -ItemType Directory | Out-Null 
}

$syncGroup = Get-AzStorageSyncGroup -name $syncGroupName -ResourceGroupName $resourceGroupName -StorageSyncServiceName $storageSyncServiceName


$cloudTieringDesired = $true
$volumeFreeSpacePercentage = $freeSpacePercent
# Optional property. Choose from: [NamespaceOnly] default when cloud tiering is enabled. [NamespaceThenModifiedFiles] default when cloud tiering is disabled. [AvoidTieredFiles] only available when cloud tiering is disabled.
$initialDownloadPolicy = "NamespaceOnly"
$initialUploadPolicy = "Merge"
# Optional property. Choose from: [Merge] default for all new server endpoints. Content from the server and the cloud merge. This is the right choice if one location is empty or other server endpoints already exist in the sync group. [ServerAuthoritative] This is the right choice when you seeded the Azure file share (e.g. with Data Box) AND you are connecting the server location you seeded from. This enables you to catch up the Azure file share with the changes that happened on the local server since the seeding.

if ($cloudTieringDesired) {
    # Ensure endpoint path is not the system volume
    $directoryRoot = [System.IO.Directory]::GetDirectoryRoot($serverEndpointPath)
    $osVolume = "$($env:SystemDrive)\"
    if ($directoryRoot -eq $osVolume) {
        throw [System.Exception]::new("Cloud tiering cannot be enabled on the system volume")
    }

    # Create server endpoint
    New-AzStorageSyncServerEndpoint `
        -Name $registeredServer.FriendlyName `
        -SyncGroup $syncGroup `
        -ServerResourceId $registeredServer.ResourceId `
        -ServerLocalPath $serverEndpointPath `
        -CloudTiering `
        -VolumeFreeSpacePercent $volumeFreeSpacePercentage `
        -InitialDownloadPolicy $initialDownloadPolicy `
        -InitialUploadPolicy $initialUploadPolicy
} else {
    # Create server endpoint
    New-AzStorageSyncServerEndpoint `
        -Name $registeredServer.FriendlyName `
        -SyncGroup $syncGroup `
        -ServerResourceId $registeredServer.ResourceId `
        -ServerLocalPath $serverEndpointPath `
        -InitialDownloadPolicy $initialDownloadPolicy
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




