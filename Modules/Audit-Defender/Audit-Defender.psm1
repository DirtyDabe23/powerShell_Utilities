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
Start-DefenderAudit
# SIG # Begin signature block#Script Signature# SIG # End signature block



