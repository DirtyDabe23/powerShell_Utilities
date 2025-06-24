$publisherName = "*parentCompany*"
$progName = ".\CoPilot.exe"
$appXManifest = ".\appxmanifest.xml"
# Define namespaces
$namespaces = @{
    "default" = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
    "uap"     = "http://schemas.microsoft.com/appx/manifest/uap/windows10"
}
$dispName = "CoPilot (CI Version)"
$version = "1.2024.11118.102"  
$outFile = ".\CoPilosubsidiaryCompany4-shortName.Package.AppInstaller"

$parentCompanyPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "$publisherName")}
ForEach ($parentCompanyProgram in $parentCompanyPrograms)
{
    Set-Location $parentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -eq $dispName)
        {
            $Installed = $true

            Remove-AppXPackage -Package $parentCompanyProgram -AllUsers
        }

    }

}
Exit 0



SignatureBlock

