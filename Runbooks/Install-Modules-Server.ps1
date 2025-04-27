#Configure a Server to configure + install required items for Management.
if (!(Test-Path $Path))
{
New-Item -itemType Directory -Path C:\ -Name Temp
}
else
{
write-host "Folder already exists"
}

Invoke-WebRequest -uri "https://github.com/PowerShell/PowerShell/releases/download/v7.5.0/PowerShell-7.5.0-win-x64.msi" -outfile "C:\Temp\PWSH7.msi"
Start-Process -FilePath "C:\Temp\PWSH7.msi" -ArgumentList "/qn" -wait
if (!(Get-PackageProvider -Name NuGet -Force)){Install-PackageProvider -Name NuGet -Force}
if (!(Get-PSResourceRepository -Name PSGAllery | Select-Object -Property Trusted) -ne "True"){Set-PSResourceRepository -Name PSGallery -Trusted}
Install-PSResource -Name Az -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph.Beta -Scope AllUsers -Verbose
Install-PSResource  ExchangeOnlineManagement -Scope AllUsers -Verbose
# SIG # Begin signature block#Script Signature# SIG # End signature block



