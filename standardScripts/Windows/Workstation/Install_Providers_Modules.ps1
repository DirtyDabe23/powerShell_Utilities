$start_time = Get-Date

$installedModules = Get-InstalledModule

$packageProviders = Get-PackageProvider
If (!($packageProviders.name -like 'NuGet'))
{
    Write-Host "Installing Package Provider: NuGet"
    Install-PackageProvider -Name "NuGet" -Force
}
else 
{
    Write-Host "Provider already installed"
}



$psRepository = Get-PSRepository
If (!($psRepository.name -like 'PSGallery'))
{
    Write-Host "Setting PSGallery to Trusted"
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}
else 
{
    Write-Host "Provider already trusted"
}




$modules = @('Az','Microsoft.Graph','Microsoft.Graph.Beta','DomainHealthChecker','ExchangeOnlineManagement')

ForEach ($module in $modules)
{
    If (!($installedModules.name -like $module))
    {
        Write-Host "Installing Module: $module"
        #Install-Module -Name $module -Force -Verbose
    }
    else 
    {
        Write-Host "Module already installed: $module"
    }

}

Write-Output "Time taken for PowerShell Configuration: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"
# SIG # Begin signature block#Script Signature# SIG # End signature block





