$port =445
 # Check Windows Firewall status
    $firewallStatus = Get-NetFirewallProfile | Select-Object -Property Name, Enabled
    Write-Host "Firewall Profile Status:"
    $firewallStatus | Format-Table -AutoSize

    # Check if there are any rules blocking port 445
    $blockedRules = Get-NetFirewallRule | Where-Object { 
        ($_.Direction -eq 'Inbound' -and $_.LocalPort -eq $port) -and ($_.Action -eq 'Block')
    }

    if ($blockedRules) {
        Write-Host "The following firewall rules are blocking port $port :"
        $blockedRules | Format-Table -AutoSize
    } else {
        Write-Host "No specific firewall rules found blocking port $port."
    }

    # Check if any application is listening on port 445
    $netstatOutput = netstat -ano | Select-String ":$port"
    if ($netstatOutput) {
        Write-Host "The following application is listening on port $port :"
        $netstatOutput
    } else {
        Write-Host "No application is currently listening on port $port."
    }

    # Check for any related services
    $relatedServices = Get-Service | Where-Object { $_.DisplayName -like '*NetBIOS*' -or $_.DisplayName -like '*Server*' }
    Write-Host "Related Services Status:"
    $relatedServices | Format-Table -Property Name, DisplayName, Status -AutoSize

# SIG # Begin signature block#Script Signature# SIG # End signature block



