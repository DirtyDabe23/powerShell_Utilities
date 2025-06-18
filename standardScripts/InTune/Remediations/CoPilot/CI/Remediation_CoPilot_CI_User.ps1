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
$uri = "https://ci-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller"
$outFile = "C:\Temp\CoPiloanonSubsidiary-1.Package.AppInstaller"


$uniqueParentCompanyPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "$publisherName")}
$installed = $false
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path $progName)
    {
        $xmlValues = Select-Xml -Path $appXManifest -XPath "//default:*" -Namespace $namespaces
        If($xmlValues.Node.DisplayName -eq $dispName)
        {
            $Installed = $true
            IF ($uniqueParentCompanyProgram.Version -lt $version)
            {
            Write-Output "Version is Lower, removing."
            Remove-AppXPackage -Package $uniqueParentCompanyProgram
                If(!(Test-Path "C:\Temp"))
                {
                    New-Item -Type Directory -Path "C:\Temp"
                }
                Else
                {
                    Write-Output "Temp Directory Exists"
                }
            
                While (Get-AppXPackage $uniqueParentCompanyProgram.Name)
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



# SIG # Begin signature block#Script Signature# SIG # End signature block







