
if ($psVersionTable.PSVersion.Major -ne 7){
    Write-Output "Installing PowerShell 7"
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
    Write-Output "Install of PowerShell 7 Completed, relaunch and rerun with PWSH 7"
    }
else{
if (!(Test-Path $profile -ErrorAction SilentlyContinue)){
    New-Item -Type File -Path $profile
    }
#There is currently a bug that is preventing this from installing Machine Wide.
winget install --id DEVCOM.JetBrainsMonoNerdFont
#This is still able to be installed Machine Wide.
winget install --id JanDeDobbeleer.OhMyPosh --scope Machine

$terminalSettings = Invoke-RestMethod -Method Get -URI "https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/WinTerminalSettings.JSON" | ConvertTo-JSON -Depth 10
set-content -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Value $terminalSettings



$JSONData = invoke-restMethod -uri 'https://raw.githubusercontent.com/DirtyDabe23/DDrosdick_Public_Repo/refs/heads/main/OhMyPoshConfig.JSON' -Method Get | ConvertTo-Json -Depth 10
$JSONDATA | Out-File "$env:POSH_THEMES_PATH\ddrosdickTheme.OMP.json"
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ddrosdickTheme.omp.json" | Invoke-Expression
$content = @"
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ddrosdickTheme.omp.json" | Invoke-Expression
"@
Set-Content -value $content -Path $PROFILE
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




