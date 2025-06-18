# Load the .NET Registry class
$regRoot = [Microsoft.Win32.Registry]::LocalMachine
$regBasePath = "SYSTEM\CurrentControlSet\Services\EventLog"

# Define Parent and Subkey names
$parentKeyName = "Microsoft/Windows/DeviceManagement-Enterprise-Diagnostics-Provider/InventoryAgent"
$subKeyName = "$parentKeyName\Microsoft/Windows/DeviceManagement-Enterprise-Diagnostics-Provider/InventoryAgent"

# Function to test if a registry value exists and matches expected data
function Test-RegistryValue {
    param (
        [Microsoft.Win32.RegistryKey]$Key,
        [string]$ValueName,
        [string]$ExpectedValue
    )
    try {
        $value = $Key.GetValue($ValueName)
        return $value -eq $ExpectedValue
    } catch {
        return $false
    }
}

# Detection Logic
$parentExists = $false
$parentValuesCorrect = $false
$subKeyExists = $false
$subKeyValuesCorrect = $false

# Open Parent Key
$parentKey = $regRoot.OpenSubKey("$regBasePath\$parentKeyName")
if ($parentKey) {
    $parentExists = $true
    $maxSizeCorrect = Test-RegistryValue -Key $parentKey -ValueName "MaxSize" -ExpectedValue 524288
    $autoBackupCorrect = Test-RegistryValue -Key $parentKey -ValueName "AutoBackupLogFiles" -ExpectedValue 0
    $parentValuesCorrect = $maxSizeCorrect -and $autoBackupCorrect
    $parentKey.Close()
}

# Open Subkey
$subKey = $regRoot.OpenSubKey("$regBasePath\$subKeyName")
if ($subKey) {
    $subKeyExists = $true
    $subKeyValuesCorrect = Test-RegistryValue -Key $subKey -ValueName "EventMessageFile" `
                          -ExpectedValue "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\EventLogMessages.dll"
    $subKey.Close()
}

# Detection Output
if ($parentExists -and $parentValuesCorrect -and $subKeyExists -and $subKeyValuesCorrect) {
    Write-Output "Registry keys and values exist correctly."
    exit 0  # Detection Passed
} else {
    Write-Output "Registry keys or values are missing or incorrect."
    exit 1  # Detection Failed
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




