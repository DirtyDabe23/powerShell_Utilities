#Install CoPilot Production Machine Wide
$prodURI = "https://copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$prodAppInstaller = "C:\Temp\CoPilot.Package.AppInstaller"


invoke-webrequest -uri $prodURI -OutFile $prodAppInstaller
$prodXMLContent = Select-Xml -Path $prodAppInstaller -XPath "//*"
$prodDownloadURL = $prodXMLContent.Node.MainPAckage.URI
$prodMSIPath = "C:\Temp\CoPilot_Production_$($prodXMLContent.node.mainpackage.version)_$($prodXMLContent.node.MainPackage.ProcessorArchitecture).msix"
invoke-webrequest -uri $prodDownloadURL -OutFile $prodMSIPath
Add-AppxProvisionedPackage -Online -PackagePath $prodMSIPath -SkipLicense -Verbose

# SIG # Begin signature block#Script Signature# SIG # End signature block




