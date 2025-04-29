#This script is designed to do all of the configuration features that a server requires for our management.
function Start-ConfigureuniqueParentCompanyServer{
    function Start-DefenderAudit{
        $runningAV = Get-CimInstance -namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Select-Object *
        if ($runningAV.displayName -eq 'Windows Defender' -OR $null -eq $runningAV){
        $osCaption = Get-CimInstance -ClassName CIM_OperatingSystem  | Select-Object caption
            if($osCaption -like "*Server*"){
                Write-output "$($env:COMPUTERNAME) is a Server. Using those methods"
                $defender = get-windowsFeature -name Windows-Defender
                IF ($defender.InstallState -ne "Installed"){
                    $needsReboot = $true
                    Install-WindowsFeature -Name Windows-Defender -Verbose}
                if (!(Get-Service -name windefend -ErrorAction SilentlyContinue)){Write-Output "Defender Service Not Installed"}
                else{$firewall = $true
                    $firewall | out-null
                    Write-Output "Defender Service Installed"
                        $service = Get-Service -name windefend
                        If ($service.State -ne "Running"){
                            Write-Output "Defender Service Not Running"
                        }
                    }
                if (!(Get-Service -name mpssvc -ErrorAction SilentlyContinue)){Write-Output "Firewall Service Not Installed"}
                else{$firewall = $true
                Write-Output "Firewall Service Installed"
                    $service = Get-Service -name mpssvc
                    If ($service.State -ne "Running"){
                        Write-Output "Firewall Service Not Running"
                    }
                }
                if ($needsReboot){Write-output "$($env:COMPUTERNAME) requires a reboot to install Defender"}}
            #If not a Server
            else{
                Write-output "$($env:COMPUTERNAME) is a Workstation or Laptop. Using those methods"
                try{$defenderStatus = Get-MPComputerStatus | Select-Object *
                    IF ($defenderStatus.AntivirusEnabled -eq $true){
                        Write-Output "$($env:COMPUTERNAME) AV status is enabled"
                    }
                    Else{
                        Write-Output "$($env:COMPUTERNAME) AV status is not enabled"
                        Set-MpPreference -DisableRealtimeMonitoring $false -Verbose
                        Write-Output "$($env:COMPUTERNAME) AV status is now enabled"
    
                    }
                    If($defenderStatus.IoavProtectionEnabled -eq $true){
                        Write-Output "$($env:COMPUTERNAME) Firewall status is enabled"
                    }
                    Else{
                        Write-Output "$($env:COMPUTERNAME) Firewall status is not enabled"
                        Set-MpPreference -DisableIOAVProtection  $false -Verbose
                        Write-Output "$($env:COMPUTERNAME) Firewall status is now enabled"
                    }
                
                }
                catch{
                    Write-output "Defender not Present"
                    Get-AppxPackage Microsoft.SecHealthUI -AllUsers | Reset-AppxPackage -Verbose
                    Write-output "Re-Attemmpt Start-DefenderAudit"
                }
            }
        }
        Else{
            Write-Output "$($env:COMPUTERNAME) is using $($runningAV.displayName)"
            Write-Output $runningAV
        }
    }
    <#
    .SYNOPSIS
    This Function performs most of the standard configuration items for a Server for uniqueParentCompany Management.
    
    .DESCRIPTION
    This function installs various items on an uniqueParentCompany Server for Management. This includes:
    PowerShell 7
        Adding the required environmental variable as well.
    Azure Arc 
        Enrolls based on the timezone location of the server.
    ScreenConnect
        Downloads and installs based on the Domain that the server is on.
    
    .EXAMPLE
    Start-ConfigureuniqueParentCompanyServer 
    
    .NOTES
    This module requires Administrative level permissions in addition to internet access. Files are downloaded from Microsoft's GitHub and Directly from the PSGallery. 
    Third Party Software:
        ScreenConnect - Downloaded from uniqueParentCompany-git.screenconnect.com
    #>
$Path = "C:\Temp"
if (!(Test-Path $Path)){
    New-Item -itemType Directory -Path C:\ -Name Temp
}
else{
    Write-Host "Folder already exists"
}

if ($psVersionTable.PSVersion.Major -ne 7){
Write-Output "Installing PowerShell 7"
## Using Invoke-RestMethod
$webData = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
## Using Invoke-WebRequest
$webData = ConvertFrom-JSON (Invoke-WebRequest -uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest")
## The release download information is stored in the "assets" section of the data
$assets = $webData.assets
## The pipeline is used to filter the assets object to find the release version we want
$asset = $assets | where-object { $_.name -match "win-x64" -and $_.name -match ".msi"}
## Download the latest version into the same directory we are running the script in
write-output "Downloading $($asset.name)"
Invoke-WebRequest $asset.browser_download_url -OutFile "$pwd\$($asset.name)"
msiexec.exe /package PowerShell-7.5.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1
Write-Output "Install of PowerShell 7 Completed"
}

Write-Output "Installing PowerShell Modules"
if (!(Get-PackageProvider -Name NuGet -Force)){Install-PackageProvider -Name NuGet -Force}
if (!(Get-PSResourceRepository -Name PSGAllery | Select-Object -Property Trusted) -ne "True"){Set-PSResourceRepository -Name PSGallery -Trusted}
Install-PSResource -Name Az -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph.Beta -Scope AllUsers -Verbose
Install-PSResource  ExchangeOnlineManagement -Scope AllUsers -Verbose
Write-Output "PowerShell Module Install Completed"


Write-Output "Enrolling into Azure Arc"
$azureAplicationId ="cd58df38-bda7-4ffa-9d3d-49ab4cb0eb1f"
$azureTenantId= $tenantIDString
$azurePassword = ConvertTo-SecureString "$AzureARC" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal
Connect-AzConnectedMachine -ResourceGroupName "AzureARC_uniqueParentCompanyEAST" -Name "$env:ComputerName" -Location "EastUS" -subscriptionid "azSubsription"
Write-Output "Completed Azure Arc Enrollment"
Start-DefenderAudit
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






