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
$uri = "https://ci-copilot.Domain.extension1/CoPilot.Client/CoPilot.Package.appinstaller"
$outFile = "C:\Temp\CoPilosubsidiaryCompany4-shortName.Package.AppInstaller"


$parentCompanyPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "$publisherName")}
$installed = $false
ForEach ($parentCompanyProgram in $parentCompanyPrograms)
{
    Set-Location $parentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -eq $dispName)
        {
            $Installed = $true
            IF ($parentCompanyProgram.Version -lt $version)
            {
            Write-Output "Version is Lower, removing."
            Remove-AppXPackage -Package $parentCompanyProgram
                If(!(Test-Path "C:\Temp"))
                {
                    New-Item -Type Directory -Path "C:\Temp"
                }
                Else
                {
                    Write-Output "Temp Directory Exists"
                }
            
                While (Get-AppXPackage $parentCompanyProgram.Name)
                {
                    Write-Output "Waiting for Removal"
                    Start-Sleep -Seconds 5
                }
                
                Write-Output "Installing New Version"
                invoke-webrequest -uri $uri -OutFile $outFile 
                Add-AppXPackage -AppInstallerFile "$outfile" 
                Start-Sleep -seconds 10
                Write-Output "Updated"
                Start-Sleep -seconds 10
            }
            Else{
                Write-Output "Up to Date"
            }
        }

    }

}

If (!($installed))
{
    Write-Output "Not installed but required"
    If(!(Test-Path "C:\Temp"))
    {
        New-Item -Type Directory -Path "C:\Temp"
    }
    Else
    {
        Write-Output "Temp Directory Exists"
    }
    Write-Output "Installing New Version"
    invoke-webrequest -uri $uri -OutFile $outFile 
    Add-AppXPackage -AppInstallerFile "$outfile" 
    Start-Sleep -seconds 10
    Write-Output "Installed"
}
Exit 0



SignatureBlock

