#Get Installed Package Providers
$InstalledProviders = (Get-PackageProvider).name

#If the PowerShell Module for Windows Update is not installed, install it
If ($InstalledProviders -notcontains "NuGet")
{

Install-PackageProvider -name NuGet -scope allusers -Force
}
Else
{
Write-Host "Package is installed"
}


#Get All Installed Modules
$InstalledModules = (Get-Module -ListAvailable).name

#If the PowerShell Module for Windows Update is not installed, install it
If ($InstalledModules -notcontains "PSWindowsUpdate")
{

Install-Module PSWindowsUpdate -Force
}
Else
{
Write-Host "Module is installed"
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



