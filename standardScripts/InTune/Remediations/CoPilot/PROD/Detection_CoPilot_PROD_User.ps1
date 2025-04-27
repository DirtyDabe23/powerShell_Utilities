$publisherName = "*uniqueParentCompany*"
$progName = ".\CoPilot.exe"
$appXManifest = ".\appxmanifest.xml"
# Define namespaces
$namespaces = @{
    "default" = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
    "uap"     = "http://schemas.microsoft.com/appx/manifest/uap/windows10"
}
$dispName = "CoPilot"
$version = "1.2024.11118.102"

$uniqueParentCompanyPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "$publisherName")}
$installed = $false 
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path $progName){
        Write-Output "Detected CoPilot"
        
        # Use Select-Xml to get the DisplayName
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -eq $dispName)
        {
            $installed = $true
            IF ($uniqueParentCompanyProgram.Version -lt "$version"){
            Write-Output "Version is Lower"
            Exit 1
            }
            Else{
                Write-Output "Up to Date"
                Exit 0
            }
        }
        Else{
            Write-Output "Detected $($xmlValues.Node.DisplayName)"
            }
    }
}
   

If (!($installed))
{
Write-Output "Not Detected"
Exit 1
}

Else{
    Write-Output "Installed and up to date"
    Exit 0
}

# SIG # Begin signature block#Script Signature# SIG # End signature block






