$ciURI = "https://ci-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$ciAppInstaller = "C:\Temp\CoPilotCI.Package.AppInstaller"

invoke-webrequest -uri $ciURI -OutFile $ciAppInstaller
Add-AppxPackage -AppInstallerFile $ciAppInstaller -Verbose
# SIG # Begin signature block#Script Signature# SIG # End signature block




