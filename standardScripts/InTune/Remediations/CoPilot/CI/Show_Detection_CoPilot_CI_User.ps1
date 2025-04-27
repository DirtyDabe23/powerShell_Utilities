CLS
$i = 10
$user = Get-ComputerInfo | Select CsUserName
While ($I -gt 0)
{
CLS
$intial = Get-Location 
$uniqueParentCompanyPrograms = Get-AppxPackage -AllUsers  | Where-Object {($_.publisher -like "*uniqueParentCompany*")}
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path ".\Copilot.exe"){
        $appXManifest = ".\appxmanifest.xml"

        # Define namespaces
        $namespaces = @{
            "default" = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
            "uap"     = "http://schemas.microsoft.com/appx/manifest/uap/windows10"
        }
        # Use Select-Xml to get the DisplayName
        $now = Get-Date -format HH:mm:ss 
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        Write-Output "[$now] $user : Detected $($xmlValues.Node.DisplayName) Version $($uniqueParentCompanyProgram.Version)"
    }
}

Set-Location $intial

Start-Sleep -seconds 60
}

# SIG # Begin signature block#Script Signature# SIG # End signature block







