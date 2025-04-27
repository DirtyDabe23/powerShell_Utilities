function Start-BetterIISReset {
    Write-Output "This is the IIS Command that actually works"
    iisreset /stop /timeout:60
    taskkill /F /FI "SERVICES eq was"
    iisreset /start
    Write-Output "Brought to you by David Drosdick :)"
}

# SIG # Begin signature block#Script Signature# SIG # End signature block



