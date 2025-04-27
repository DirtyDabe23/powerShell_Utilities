#admin
$publisherName = "*uniqueParentCompany*"
$uniqueParentCompanyPrograms = Get-AppxPackage -AllUsers  | Where-Object {($_.publisher -like "$publisherName") -and ($_.Name -notlike "$publisherName")}
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
Remove-AppXPackage -package $uniqueParentCompanyProgram.PackageFullName -AllUsers
}

$prodURI = "https://copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$qaURI = "https://qa-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$ciURI = "https://ci-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"

$prodAppInstaller = "C:\Temp\CoPilot.Package.AppInstaller"
$qaAppInstaller = "C:\Temp\CoPilotQA.Package.AppInstaller"
$ciAppInstaller = "C:\Temp\CoPiloanonSubsidiary-1.Package.AppInstaller"

#Prod
invoke-webrequest -uri $prodURI -OutFile $prodAppInstaller
$prodXMLContent = Select-Xml -Path $prodAppInstaller -XPath "//*"
$prodDownloadURL = $prodXMLContent.Node.MainPAckage.URI
$prodMSIPath = "C:\Temp\CoPilot_Production_$($prodXMLContent.node.mainpackage.version)_$($prodXMLContent.node.MainPackage.ProcessorArchitecture).msix"
invoke-webrequest -uri $prodDownloadURL -OutFile $prodMSIPath
Add-AppxProvisionedPackage -Online -PackagePath $prodMSIPath -SkipLicense -Verbose


#QA
invoke-webrequest -uri $qaURI -OutFile $qaAppInstaller
$qaXMLContent = Select-Xml -Path $qaAppInstaller -XPath "//*"
$qaDownloadURL = $qaXMLContent.Node.MainPAckage.URI
$qaMSIPath = "C:\Temp\CoPilot_QA_$($qaXMLContent.node.mainpackage.version)_$($qaXMLContent.node.MainPackage.ProcessorArchitecture).msix"
invoke-webrequest -uri $qaDownloadURL -OutFile $qaMSIPath
Add-AppxProvisionedPackage -Online -PackagePath $qaMSIPath -SkipLicense -Verbose


#CI
invoke-webrequest -uri $ciURI -OutFile $ciAppInstaller
$ciXMLContent = Select-Xml -Path $ciAppInstaller -XPath "//*"
$ciDownloadURL = $ciXMLContent.Node.MainPAckage.URI
$ciMSIPath = "C:\Temp\CoPilot_CI_$($ciXMLContent.node.mainpackage.version)_$($ciXMLContent.node.MainPackage.ProcessorArchitecture).msix"
invoke-webrequest -uri $ciDownloadURL -OutFile $ciMSIPath
Add-AppxProvisionedPackage -Online -PackagePath $ciMSIPath -SkipLicense -Verbose

# SIG # Begin signature block#Script Signature# SIG # End signature block







