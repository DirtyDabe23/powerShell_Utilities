$qaURI = "https://qa-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$qaAppInstaller = "C:\Temp\CoPilotQA.Package.AppInstaller"

invoke-webrequest -uri $qaURI -OutFile $qaAppInstaller
Add-AppxPackage -AppInstallerFile $qaAppInstaller -Verbose
# SIG # Begin signature block#Script Signature# SIG # End signature block




