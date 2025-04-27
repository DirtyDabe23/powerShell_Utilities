Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope AllUsers| Out-Null
Repair-WinGetPackageManager -AllUsers -Force -Latest -Verbose
winget repair --ID "Microsoft.AppInstaller" --verbose --accept-source-agreements --accept-package-agreements --scope Machine

# SIG # Begin signature block#Script Signature# SIG # End signature block



