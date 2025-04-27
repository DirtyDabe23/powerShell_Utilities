#Configure a Server to configure + install required items for Management.
if (!(Get-PackageProvider -Name NuGet -Force)){Install-PackageProvider -Name NuGet -Force}
if (!(Get-PSResourceRepository -Name PSGAllery | Select-Object -Property Trusted) -ne "True"){Set-PSResourceRepository -Name PSGallery -Trusted}
Install-PSResource -Name Az -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph -Scope AllUsers -Verbose
Install-PSResource  Microsoft.Graph.Beta -Scope AllUsers -Verbose
Install-PSResource  ExchangeOnlineManagement -Scope AllUsers -Verbose
# SIG # Begin signature block#Script Signature# SIG # End signature block



