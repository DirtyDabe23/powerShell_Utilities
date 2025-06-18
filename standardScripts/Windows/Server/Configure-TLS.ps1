New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force 
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' –PropertyType 'DWORD' -Name 'DisabledByDefault' -Value '0' 
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -PropertyType 'DWORD' -Name 'Enabled' -Value '1' 

New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force 
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' –PropertyType 'DWORD' -Name 'DisabledByDefault' -Value '0' 
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' –PropertyType 'DWORD' -Name 'Enabled' -Value '1' 

New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\HTTP\Parameters' -PropertyType 'DWORD' -Name 'EnableHttp3' -Value '1'
# SIG # Begin signature block#Script Signature# SIG # End signature block




