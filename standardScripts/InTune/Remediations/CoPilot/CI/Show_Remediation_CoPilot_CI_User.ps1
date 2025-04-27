cls
$uniqueParentCompanyPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "*uniqueParentCompany*")}
$installed = $false
ForEach ($uniqueParentCompanyProgram in $uniqueParentCompanyPrograms)
{
    Set-Location $uniqueParentCompanyProgram.installLocation
    If (Test-path ".\Copilot.exe")
    {
            $Installed = $true
            Write-Output "Detected CoPilot"
            IF ($uniqueParentCompanyProgram.Version -lt "1.2024.11115.104")
            {
            Write-Output "Version is Lower, removing."
            Remove-AppXPackage -Package $uniqueParentCompanyProgram  -wait
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
            invoke-webrequest -uri "https://copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller" -OutFile C:\Temp\CoPilot.Package.AppInstaller
            Add-AppXPackage -AppInstallerFile "C:\Temp\CoPilot.Package.appinstaller" 
            Start-Sleep -seconds 10
            Write-Output "Updated"
            Start-Sleep -seconds 10
            }
    Else{
        Write-Output "Up to Date"
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
    invoke-webrequest -uri "https://ci-copilot.uniqueParentCompany.com/CoPilot.Client/CoPilot.Package.appinstaller" -OutFile C:\Temp\CoPilot.Package.AppInstaller
    Add-AppXPackage -AppInstallerFile "C:\Temp\CoPilot.Package.appinstaller" 
    Start-Sleep -seconds 10
    Write-Output "Installed"
}
#Exit 0



# SIG # Begin signature block#Script Signature# SIG # End signature block






