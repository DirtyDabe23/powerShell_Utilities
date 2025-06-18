$publisherName = "*uniqueParentCompany*"
$progName = ".\CoPilot.exe"
$appXManifest = ".\appxmanifest.xml"
# Define namespaces
$namespaces = @{
    "default" = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
    "uap"     = "http://schemas.microsoft.com/appx/manifest/uap/windows10"
}
$dispName = "CoPilot (CI Version)"
$version = "1.2024.11118.102"  
$outFile = ".\CoPiloanonSubsidiary-1.Package.AppInstaller"

$uniqueParentCompanyPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "$publisherName")}
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -eq $dispName)
        {
            $Installed = $true

            Remove-AppXPackage -Package $uniqueParentCompanyProgram -AllUsers
        }

    }

}
Exit 0



# SIG # Begin signature block#Script Signature# SIG # End signature block







