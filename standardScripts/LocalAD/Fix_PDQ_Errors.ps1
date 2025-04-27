#From PDQ
$computerName = Read-Host -prompt "Enter the Computer Name Here"
Resolve-DNSName -Name $computerName
Test-NetConnection -ComputerName $computerName
Test-NetConnection -ComputerName $computerName -port 445


#From the Endpoint
$netAdapter = Get-Netadapter
$netAdapIndex = $netAdapter.interfaceIndex 
$netProfile = Get-NetConnectionProfile -InterfaceIndex $netAdapIndex


#on the Endpoint
New-NetFirewallRule -DisplayName 'PDQ Port' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445 -RemoteAddress Any

# SIG # Begin signature block#Script Signature# SIG # End signature block



