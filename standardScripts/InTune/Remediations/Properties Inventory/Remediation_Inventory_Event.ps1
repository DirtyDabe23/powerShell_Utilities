# Load the .NET Registry class
$regRoot = [Microsoft.Win32.Registry]::LocalMachine
$regBasePath = "SYSTEM\CurrentControlSet\Services\EventLog"

# Define Parent and Subkey names
$parentKeyName = "Microsoft/Windows/DeviceManagement-Enterprise-Diagnostics-Provider/InventoryAgent"
$subKeyName = "$parentKeyName\Microsoft/Windows/DeviceManagement-Enterprise-Diagnostics-Provider/InventoryAgent"

# Create Parent Key and Set Values
$parentKey = $regRoot.CreateSubKey("$regBasePath\$parentKeyName")
$parentKey.SetValue("MaxSize", 524288, [Microsoft.Win32.RegistryValueKind]::DWord)
$parentKey.SetValue("AutoBackupLogFiles", 0, [Microsoft.Win32.RegistryValueKind]::DWord)
$parentKey.Close()

# Create Subkey and Set EventMessageFile
$subKey = $regRoot.CreateSubKey("$regBasePath\$subKeyName")
$subKey.SetValue("EventMessageFile", "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\EventLogMessages.dll", `
    [Microsoft.Win32.RegistryValueKind]::ExpandString)
$subKey.Close()

Write-Output "Registry keys and values have been created or corrected."

# SIG # Begin signature block#Script Signature# SIG # End signature block




