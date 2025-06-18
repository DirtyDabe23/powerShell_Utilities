Enable-PSRemoting -Force
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value * -Force
New-NetFirewallRule -Name WinRM -DisplayName "Windows Remote Management" -Profile Domain,Public,Private -Protocol TCP -LocalPort 5985 -Action Allow -EdgeTraversalPolicy Allow
Set-Service -name "WinRM" -StartupType Automatic
Get-NetConnectionProfile | Set-NetConnectionProfile -networkcategory "Private"
Restart-Service -name "WinRM"
# SIG # Begin signature block#Script Signature# SIG # End signature block




