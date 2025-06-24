$ciURI = "https://ci-copilot.Domain.extension1/CoPilot.Client/CoPilot.Package.appinstaller"
$ciAppInstaller = "C:\Temp\CoPilosubsidiaryCompany4-shortName.Package.AppInstaller"

invoke-webrequest -uri $ciURI -OutFile $ciAppInstaller
Add-AppxPackage -AppInstallerFile $ciAppInstaller -Verbose
SignatureBlock

