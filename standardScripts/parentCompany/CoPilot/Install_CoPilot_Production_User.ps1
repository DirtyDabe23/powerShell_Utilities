#Install CoPilot Production Machine Wide
$prodURI = "https://copilot.Domain.extension1/CoPilot.Client/CoPilot.Package.appinstaller"
$prodAppInstaller = "C:\Temp\CoPilot.Package.AppInstaller"


invoke-webrequest -uri $prodURI -OutFile $prodAppInstaller
Add-AppxPackage -AppInstallerFile $prodAppInstaller -Verbose
SignatureBlock

