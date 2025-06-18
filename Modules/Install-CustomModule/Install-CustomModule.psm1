function Install-CustomModule{
    <#
    .SYNOPSIS
    This function will install Custom uniqueParentCompany Modules that have been authored by GIT.
    
    .DESCRIPTION
    This function installs Custom Modules to the "C:\Program Files\PowerShell\Modules\[ModuleName]" path. 
    It searches commonly used deployment areas, GitHub, File Shares, LocalFiles, etc, to install the Modules.
    It will only install the Modules for PowerShell 7 as earlier versions are quickly approaching EOL.
    
    .EXAMPLE
    #The following example will use a localPath and will move the files into the PowerShell Modules Folder for long-term use.
    Install-CustomModule -moduleName "Start-BetterMessageTrace -localPath "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\____Modules\Start-BetterMessageTrace\0 - Prod\"
    
    #The following will connect to an uniqueParentCompany Approved GitHub Repository to pull the module named 'Start-BetterMessageTrace'
    Install-CustomModule -moduleName "Start-BetterMessageTrace" -gitHub
    
    #The following example will connect to an uniqueParentCompany Approved Server Share to install custom modules.
    Install-CustomModule -moduleName "Start-BetterMessageTrace" -serverShare '\\uniqueParentCompanyusers\public\tech-items\script configs\Modules\start-bettermessagetrace'
    
    
    Will copy all of the files found at that path into the PowerShell module folder 'Start-BetterMessageTrace'
    
    .NOTES
    This module installs PowerShell Files as Custom Modules.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,HelpMessage="Enter the name of the Module to install, this will create a folder in C:\Program Files\PowerShel\Modules\moduleName",Mandatory)]
        [string]
        $moduleName,
        [Parameter(HelpMessage="Use this switch to install a module from a Local Path",ParameterSetName = "Local")]
        [switch]
        $localSource,
        [Parameter(HelpMessage="Define the path to the directory where the modules are contained.`nExample: C:\Temp\Show-ExampleModule\ will get all the .psm1 and .ps1 files in C:\Temp\Show-ExampleModule",ParameterSetName = "Local",Mandatory)]
        [string]
        $localPath,
        [Parameter(HelpMessage="Use this switch to install a Module from a GitHub Repo",ParameterSetName = "GitHub")]
        [switch]
        $gitHubSource,
        [Parameter(HelpMessage="Use this switch to install a module from a Server Share",ParameterSetName = "Server")]
        [switch]
        $shareSource,
        [Parameter(HelpMessage = "Enter the path to the share.`nExample: \\server\Share\Install-CustomModule\ will get the files from \\server\share\Install-CustomModule",ParameterSetName ="Server",Mandatory)]
        [string]
        $shareString
    )
        $modulePath = 'C:\Program Files\PowerShell\Modules\',$moduleName ,"\" -join ''
        if (!(Test-Path $modulePath -ErrorAction SilentlyContinue)){
            New-Item -Type Directory -Path $modulePath
        }
        if ($localSource){
            If(!(Test-Path $localPath)){
                Throw "Invalid Path, please try again"
            }
            else{
                $items = Get-ChildItem -Path $localPath -Recurse | select-Object -Property *  | Where-Object  {($_.Extension -like ".ps*1")}
                Copy-Item $items.FullName -destination $modulePath 
            }
        }
        if ($gitHubSource){
            $baseURI = 'https://raw.githubusercontent.com/DirtyDabe23/uniqueParentCompanyRepo/refs/heads/main/Modules/'
            $extensions = '.psm1','.psd1','.ps1'
            ForEach ($extension in $extensions){
                $moduleURI = $baseURI , $moduleName ,'/' ,$moduleName , "$extension" -join ""
                If(invoke-restmethod -Method Get -uri $moduleURI -errorAction SilentlyContinue){
                    Invoke-RestMethod -method Get -uri $moduleURI -OutFile ($modulePath,$moduleName,$extension -join "")
                } 
            }
        }
        if($shareSource){
            If(!(Test-Path $shareString)){
                Throw "Invalid Path or Insufficient Privileges, please try again"
            }
            else{
                Copy-Item -path $shareString -Recurse -Destination $modulePath
            }
        }
    
    }
    # SIG # Begin signature block#Script Signature# SIG # End signature block
    
# SIG # Begin signature block#Script Signature# SIG # End signature block





