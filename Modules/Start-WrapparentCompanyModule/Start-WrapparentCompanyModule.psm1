function Start-WrapparentCompanyModule{
    <#
        .SYNOPSIS
        This function wraps an parentCompany PowerShell module for Intune deployment.
        .DESCRIPTION
        The function copies the specified parentCompany module to a designated input path, creates an installation script, and then uses IntuneWinAppUtil to create a .intunewin package for deployment.
        .PARAMETER ModuleName
        The name of the parentCompany PowerShell module to be wrapped.
        .PARAMETER modulePath
        The path to the parentCompany PowerShell module on the local machine. Default is set to a specific directory in the user's profile.
        .PARAMETER moduleInputPath
        The path where the module will be copied for wrapping. Default is set to a specific directory in the user's profile.
        .PARAMETER moduleOutputPath
        The path where the wrapped module will be outputted. Default is set to a specific directory in the user's profile.
        .EXAMPLE
        Start-WrapparentCompanyModule -ModuleName "MyparentCompanyModule"
        This command will wrap the specified parentCompany module and create a .intunewin package for deployment.
        .NOTES
        This function requires the IntuneWinAppUtil.exe to be available in the system PATH.
        Ensure that the specified paths exist or are created before running the function.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [Parameter(Mandatory=$false)]
        [string]$modulePath = "$env:USERPROFILE\parentCompany, Inc\GIT IT Support - Documents\General\PowerShell Scripts\parentCompanyRepo\Modules\$ModuleName",
        [Parameter(Mandatory=$false)]
        [string]$moduleInputPath = "$env:USERPROFILE\parentCompany, Inc\GIT IT Support - Documents\General\InTune-Apps\Pre-Wrap\Modules\$ModuleName\",
        [Parameter(Mandatory=$false)]
        [string]$installScriptPath = "C:\Users\David.Drosdick\parentCompany, Inc\GIT IT Support - Documents\General\InTune-Apps\Pre-Wrap\Modules\$ModuleName\",
        [parameter(Mandatory=$false)]
        [string]$moduleOutputPath = "$env:USERPROFILE\parentCompany, Inc\GIT IT Support - Documents\General\InTune-Apps\Post-Wrap\Modules\$ModuleName"
    )
    if (!(Test-Path -Path $modulePath)){
        throw "Module path does not exist: $modulePath"
    }
    if (!(Test-Path -Path $moduleInputPath)){
        Write-Warning "Module input path does not exist: $moduleInputPath"
        New-Item -ItemType Directory -Path $moduleInputPath -Force | Out-Null
        if (Test-Path -Path $moduleInputPath){
            Write-Output "Module input path created successfully: $moduleInputPath"
        } else {
            throw "Failed to create module input path: $moduleInputPath"
        }
    }
    if (!(Test-Path -Path $moduleOutputPath)){
        Write-Warning "Module output path does not exist: $moduleOutputPath"
        New-Item -ItemType Directory -Path $moduleOutputPath -Force | Out-Null
        if (Test-Path -Path $moduleOutputPath){
            Write-Output "Module output path created successfully: $moduleOutputPath"
        } else {
            throw "Failed to create module output path: $moduleOutputPath"
        }
    }

    Copy-Item -Path $modulePath -Destination $moduleInputPath -Recurse -Force
    Write-Output "Module $ModuleName copied to input path: $moduleInputPath"
    $installScript = @"
    sourcePath = ".\$moduleName"
    targetPath = "C:\Program Files\PowerShell\Modules\$moduleName"
    if (-not (Test-Path -Path targetPath)) {
        New-Item -ItemType Directory -Path targetPath -Force
    }

    Copy-Item -Path ".\$moduleName\*" -Destination targetPath -Recurse -Force

    Write-Output "Module $moduleName installed successfully to targetPath."
"@
    $installScript = $installScript -replace "sourcePath", "`$sourcePath"
    $installScript = $installScript -replace "targetPath", "`$targetPath"

    New-Item -Path $moduleInputPath -Name "InstallModule.ps1" -ItemType File -Value $installScript -Force | Out-Null
    Write-Output "Install script created at: $moduleOutputPath\InstallModule.ps1"
    $installScriptPath = $moduleInputPath , "\", "InstallModule.ps1" -join ""
    IntuneWinAppUtil -c $moduleInputPath -s $installScriptPath -o $moduleOutputPath 
    if ($LASTEXITCODE -ne 0) {
        throw "IntuneWinAppUtil failed with exit code $LASTEXITCODE"
    }
    Write-Output "IntuneWinAppUtil executed successfully. Output path: $moduleOutputPath"  
   
}
SignatureBlock

