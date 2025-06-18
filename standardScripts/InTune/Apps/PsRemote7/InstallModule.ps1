#Requires -version 7.0 
$psConfiguration = Get-PSSessionConfiguration -Name PowerShell.7

If(!($psConfiguration.enabled)){
    Enable-PSRemoting -Force
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value * -Force
    New-NetFirewallRule -Name WinRM -DisplayName "Windows Remote Management" -Profile Domain,Public,Private -Protocol TCP -LocalPort 5985 -Action Allow -EdgeTraversalPolicy Allow
    Set-Service -name "WinRM" -StartupType Automatic
    Restart-Service -name "WinRM"
    $psConfiguration = Get-PSSessionConfiguration -Name PowerShell.7
    

    If(!($psConfiguration.enabled)){
        Write-Output "Needs Enabled"
        Exit 1 
    }
    Else{
        Write-Output "Enabled"
        $item = New-Item -Path "HKLM:\Software\uniqueParentCompany\WinRM" -Force 
        New-ItemProperty -Path $item.PSPath -PropertyType String -Name PowerShell7 -Value "Enabled" -Force
        Exit 0
    }
}
Else{
    Write-Output "Enabled"
    Exit 0
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





