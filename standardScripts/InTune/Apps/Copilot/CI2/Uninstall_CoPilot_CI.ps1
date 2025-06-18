$publisherName = "*uniqueParentCompany*"
$progName = ".\CoPilot.exe"
$appXManifest = ".\appxmanifest.xml"
# Define namespaces
$namespaces = @{
    "default" = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
    "uap"     = "http://schemas.microsoft.com/appx/manifest/uap/windows10"
}
$dispName = "*CoPilot*"

$startingLocation = Get-Location

$uniqueParentCompanyPrograms = Get-AppxPackage -AllUsers | Where-Object {($_.publisher -like "$publisherName") -and ($_.Name -notlike "*sharepoint*")}
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -like $dispName)
        {
            $Installed = $true

            Remove-AppXPackage -Package $uniqueParentCompanyProgram -AllUsers
        }

    }

}
$uniqueParentCompanyProgramsUser = Get-AppxPackage | Where-Object {($_.publisher -like "$publisherName") -and ($_.Name -notlike "*sharepoint*")}
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyProgramsUser)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -like $dispName)
        {
            $Installed = $true

            Remove-AppXPackage -Package $uniqueParentCompanyProgram
        }

    }

}

Set-Location $startingLocation

#Exit 0



# SIG # Begin signature block#Script Signature# SIG # End signature block





