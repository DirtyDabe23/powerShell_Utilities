# Create certificate and installs it to the Machine Store
$mycert = New-SelfSignedCertificate -DnsName "uniqueParentCompany.com" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(1) -KeySpec KeyExchange

# Export certificate to .pfx file
$mycert | Export-PfxCertificate -FilePath uniqueParentCompanyEXO.pfx -Password (Get-Credential).password

# Export certificate to .cer file
$mycert | Export-Certificate -FilePath uniqueParentCompanyEXO.cer
# SIG # Begin signature block#Script Signature# SIG # End signature block




