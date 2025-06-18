#Install CoPilot Production Machine Wide
$prodURI = "https://copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$prodAppInstaller = "C:\Temp\CoPilot.Package.AppInstaller"


invoke-webrequest -uri $prodURI -OutFile $prodAppInstaller
Add-AppxPackage -AppInstallerFile $prodAppInstaller -Verbose
# SIG # Begin signature block#Script Signature# SIG # End signature block




