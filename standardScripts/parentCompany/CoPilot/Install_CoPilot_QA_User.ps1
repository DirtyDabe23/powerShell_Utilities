$qaURI = "https://qa-copilot.Domain.extension1/CoPilot.Client/CoPilot.Package.appinstaller"
$qaAppInstaller = "C:\Temp\CoPilotQA.Package.AppInstaller"

invoke-webrequest -uri $qaURI -OutFile $qaAppInstaller
Add-AppxPackage -AppInstallerFile $qaAppInstaller -Verbose
SignatureBlock

