#Install CoPilot CI Machine Wide
$ciURI = "https://ci-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$ciAppInstaller = "C:\Temp\CoPilosubsidiaryCompany4-shortName.Package.AppInstaller"

invoke-webrequest -uri $ciURI -OutFile $ciAppInstaller
$ciXMLContent = Select-Xml -Path $ciAppInstaller -XPath "//*"
$ciDownloadURL = $ciXMLContent.Node.MainPAckage.URI
$ciMSIPath = "C:\Temp\CoPilot_CI_$($ciXMLContent.node.mainpackage.version)_$($ciXMLContent.node.MainPackage.ProcessorArchitecture).msix"
invoke-webrequest -uri $ciDownloadURL -OutFile $ciMSIPath
Add-AppxProvisionedPackage -Online -PackagePath $ciMSIPath -SkipLicense -Verbose
# SIG # Begin signature block#Script Signature# SIG # End signature block





