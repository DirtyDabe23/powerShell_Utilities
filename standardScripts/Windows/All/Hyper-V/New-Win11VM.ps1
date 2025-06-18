#There is a conflict with the VMWare VM Module and the Hyper-V Module. This is to ensure there are no conflicts in commands.
Import-Module -Name Hyper-V -Prefix Hv


#Top Level VM Configuration
$vmOS                   =   "Win11"
$vmOSVersion            =   "24h2"
$vmFunction             =   "Test"
$vmISOPath              =   "C:\ISO\$vmOS\$vmOSVersion.iso"
$vmName                 =   $vmOS, '-',$vmOSVersion, '-',$vmFunction , '-VM' -join ""
$vmContainer            =   "C:\VM\" , "$vmOS" , "\" , "$vmOSVersion","\","$vmFunction" -join ""
$vmFolder               =   $vmContainer    ,   "\VM"           -join ""
$vmPath                 =   $vmFolder       ,   "\"             -join ""
$vhdxContainer          =   $vmContainer    ,   "\VHDx"         -join ""
$vhdXPath               =   $vhdxContainer  , "\$vmName.vhdx"   -join ""




#Verify the paths are created and ready for the files to be staged.
if (!(Test-Path "C:\VM\" -ErrorAction SilentlyContinue)){
    New-Item -Type Directory -Path "C:\VM\"
}
if (!(Test-Path "C:\VM\$vmOS\")){
    New-Item -Type Directory -Path "C:\VM\$vmOS\"
}
if (!(Test-Path "C:\VM\$vmOS\$vmOSVersion\")){
    New-Item -Type Directory -Path "C:\VM\$vmOS\$vmOSVersion\"
}

if (!(Test-Path $vmContainer -errorAction SilentlyContinue)){
    New-Item -Type Directory -Path $vmContainer
}
if (!(Test-Path $vmFolder -errorAction SilentlyContinue)){
    New-Item -Type Directory -Path $vmFolder
}
if (!(Test-Path $vhdxContainer)){
    New-Item -Type Directory -Path "$vhdxContainer"
}



#VHDx Configuration
$vhdData                =   @{
Path                    =   $vhdXPath
blockSize               =   128MB
logicalSectorSize       =   4KB
sizeBytes               =   100GB
Fixed                   =   $true
}
New-HvVHD @vhdData





#This configures the VM's Switching and RAM 
$vmConfig = @{
    #OS and Host Configuration
    Name                        =   $vmName
    MemoryStartupBytes          =   8589934592
    SwitchName                  =   "Default Switch"
    Generation                  =   2
    Path                        =   $vmPath
    BootDevice                  =   "VHD"
    VHDPath                     =   "$vhdXPath"
}
$newVM = New-HvVM @vmConfig

#This configures the VM to boot via the ISO
$createVMDVDDrive = @{
    vmName  =   $vmName
    Path    =   $vmISOPath
}
Add-HVVMDvdDrive @createVMDVDDrive

#This configures the VM to not allow file copy operations. 
$vmIntegartionService = @{
    vmName  =   $vmName
    Name    =   "Guest Service Interface"
}
Disable-HVVMIntegrationService @vmIntegartionService 

#Retrieve all Configured Items after Setting Them, required for configuring Boot Order.
$setVM = Get-HvVM -name $newVM.name
$vmVHDXAssigned = Get-HvVMHardDiskDrive -VMName $newVM.Name
$vmISOAssigned = Get-HvVMDvdDrive -VMName $newVM.Name 
$vmNetworkAssigned = Get-HvVMFirmware -VM $setVM | Select-Object -ExpandProperty BootOrder | Where-Object { $_.BootType -eq 'Network' }


#This configures Secure Boot
$vmFirmware = @{
    VM                  =   $newVM
    EnableSecureBoot    =   "On"
    SecureBootTemplate  =   "MicrosoftWindows"
    BootOrder           =   $vmVHDXAssigned , $vmISOAssigned , $vmNetworkAssigned
    
    
}
Set-HVVMFirmware @vmFirmware

$vmProcessor = @{
    Count                           =   4
    VM                              =   $newVM
    EnableHostResourceProtection    =   $true
}
Set-HvVMProcessor @vmProcessor
$vmSettings = @{
    VM                              =   $newVM
    AutomaticCheckpointsEnabled     =   $false
    AutomaticStartAction            =   "StartIfRunning"
    AutomaticStopAction             =   "TurnOff"
    CheckPointType                  =   "Disabled"
}
Set-VM @vmSettings
Set-HvVMKeyProtector -VM $newVM -NewLocalKeyProtector
Enable-HvVMTPM -Vm $newVM
Start-HvVM -Name $vmName

# SIG # Begin signature block#Script Signature# SIG # End signature block




