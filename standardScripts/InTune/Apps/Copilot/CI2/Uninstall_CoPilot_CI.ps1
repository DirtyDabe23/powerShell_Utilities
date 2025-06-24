$publisherName = "*parentCompany*"
$progName = ".\CoPilot.exe"
$appXManifest = ".\appxmanifest.xml"
# Define namespaces
$namespaces = @{
    "default" = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
    "uap"     = "http://schemas.microsoft.com/appx/manifest/uap/windows10"
}
$dispName = "*CoPilot*"

$startingLocation = Get-Location

$parentCompanyPrograms = Get-AppxPackage -AllUsers | Where-Object {($_.publisher -like "$publisherName") -and ($_.Name -notlike "*sharepoint*")}
ForEach ($parentCompanyProgram in $parentCompanyPrograms)
{
    Set-Location $parentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -like $dispName)
        {
            $Installed = $true

            Remove-AppXPackage -Package $parentCompanyProgram -AllUsers
        }

    }

}
$parentCompanyProgramsUser = Get-AppxPackage | Where-Object {($_.publisher -like "$publisherName") -and ($_.Name -notlike "*sharepoint*")}
ForEach ($parentCompanyProgram in $parentCompanyProgramsUser)
{
    Set-Location $parentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -like $dispName)
        {
            $Installed = $true

            Remove-AppXPackage -Package $parentCompanyProgram
        }

    }

}

Set-Location $startingLocation

#Exit 0



SignatureBlock

