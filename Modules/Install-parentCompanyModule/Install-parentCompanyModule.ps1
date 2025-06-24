function Install-parentCompanyModule {
    <#
    .SYNOPSIS
    Installs the parentCompany PowerShell module from the specified path.

    .DESCRIPTION
    This function copies the parentCompany PowerShell module from a specified user profile path to the system's PowerShell modules directory.

    .EXAMPLE
    Install-parentCompanyModule

    This will copy the parentCompany module to the default PowerShell modules directory.
    #>

    [CmdletBinding()]
    param ()

    # Copy the parentCompany module to the PowerShell modules directory
    Write-Verbose "Moving all parentCompany Modules to the PowerShell Modules Directory"
    $parentCompanyModulePath = "$env:USERPROFILE",'\parentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\parentCompanyRepo\Modules\' -join ""
    try{
        Test-Path -Path $parentCompanyModulePath -PathType Container -ErrorAction Stop | Out-Null
    }
    catch{
        throw "The specified parentCompany module path does not exist: $parentCompanyModulePath"
    }
    $currentItems = Get-ChildItem -Path $parentCompanyModulePath -Directory -ErrorAction SilentlyContinue | Where-Object {($_.BaseName -ne 'parentCompanyModule')}
    if ($null -eq $currentItems){$currentItems = @()
        throw "No parentCompany modules found in the specified path: $parentCompanyModulePath"
    }
    # Create backup directory if it doesn't exist
    $backupDir = "C:\Temp\backupModules\$((Get-Date).ToString('yyyy-MM-dd_HH-mm'))"
    if (!(Test-Path -Path $backupDir -PathType Container -ErrorAction SilentlyContinue)){
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }
    # Create module install location if it doesn't exist
    $moduleInstallLocation = "C:\Program files\PowerShell\Modules" 
    Test-Path -Path $moduleInstallLocation -PathType Container -ErrorAction SilentlyContinue | Out-Null
    if (!(Test-Path -Path $moduleInstallLocation -PathType Container -ErrorAction SilentlyContinue)){
        New-Item -Path $moduleInstallLocation -ItemType Directory -Force | Out-Null
    }
    # Move existing modules to backup directory
    $modules = Get-ChildItem -Path $moduleInstallLocation -Directory -ErrorAction SilentlyContinue
    if ($null -eq $modules){$modules = @()}
        $moveModules = $modules | Where-Object {($_.BaseName -in $currentItems.BaseName) -and ($_.BaseName -ne 'parentCompanyModule')
    }
    if($moveModules.count -eq 0){
        Write-Verbose "No existing parentCompany modules found to move to backup directory."
        }
    else{
        Write-Verbose "Moving existing parentCompany modules to backup directory: $backupDir"
        ForEach ($moveModule in $moveModules){
            Move-Item $moveModule -Destination $backupDir -Force
        }
    }
    try{
        Test-Path -Path ($parentCompanyModulePath , "parentCompanyModule") -PathType Container -ErrorAction Stop | Out-Null
    }
    catch{
        throw "The specified parentCompany module path does not exist: $($parentCompanyModulePath , 'parentCompanyModule' -join '')"
    }
    try{
        Copy-Item -path ($parentCompanyModulePath , "parentCompanyModule\" -join "") -Destination $moduleInstallLocation -Recurse -Force
        return "parentCompany PowerShell modules installed successfully."
    }
    catch{
        throw "Failed to copy parentCompany modules to $moduleInstallLocation. Error: $_"
    }
}

SignatureBlock

