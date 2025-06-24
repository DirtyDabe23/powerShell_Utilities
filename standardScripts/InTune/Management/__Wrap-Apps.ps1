$startingLocation = Get-Location
$win32AppName = Read-Host "Enter the name of the Win32 App `nExample: Clear-Enrollment`nEnter"
$installScript = Read-Host "Enter the name of the Install Script.`nExample: InstallModule.ps1`nEnter"
$wrappingLocation = "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\_Project\_Intune\Microsoft-Win32-Content-Prep-Tool-master\Microsoft-Win32-Content-Prep-Tool-master"
Set-Location $wrappingLocation
.\IntuneWinAppUtil.exe `
-c "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\InTune\Apps\$win32AppName" `
-s "$installScript" `
-o "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\InTune\Apps\Wrapped\$win32AppName\"
Set-Location $startingLocation
SignatureBlock

