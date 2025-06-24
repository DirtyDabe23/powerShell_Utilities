Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name Start -Value “3”
Start-Service tzautoupdate
SignatureBlock

