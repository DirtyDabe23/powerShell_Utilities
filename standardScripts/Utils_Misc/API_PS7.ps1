## Using Invoke-RestMethod
$webData = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"

## Using Invoke-WebRequest
$webData = ConvertFrom-JSON (Invoke-WebRequest -uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest")

## The release download information is stored in the "assets" section of the data
$assets = $webData.assets

## The pipeline is used to filter the assets object to find the release version we want
$asset = $assets | where-object { $_.name -match "win-x64" -and $_.name -match ".msi"}

## Download the latest version into the same directory we are running the script in
write-output "Downloading $($asset.name)"
Invoke-WebRequest $asset.browser_download_url -OutFile "$pwd\$($asset.name)"

msiexec.exe /package PowerShell-7.5.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1

# SIG # Begin signature block#Script Signature# SIG # End signature block



