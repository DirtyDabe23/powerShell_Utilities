#Install CoPilot QA Machine Wide
$qaURI = "https://qa-copilot.Domain.extension1/CoPilot.Client/CoPilot.Package.appinstaller"
$qaAppInstaller = "C:\Temp\CoPilotQA.Package.AppInstaller"

invoke-webrequest -uri $qaURI -OutFile $qaAppInstaller
$qaXMLContent = Select-Xml -Path $qaAppInstaller -XPath "//*"
$qaDownloadURL = $qaXMLContent.Node.MainPAckage.URI
$qaMSIPath = "C:\Temp\CoPilot_QA_$($qaXMLContent.node.mainpackage.version)_$($qaXMLContent.node.MainPackage.ProcessorArchitecture).msix"
invoke-webrequest -uri $qaDownloadURL -OutFile $qaMSIPath
Add-AppxProvisionedPackage -Online -PackagePath $qaMSIPath -SkipLicense -Verbose

SignatureBlock

