# Create certificate and installs it to the Machine Store
$mycert = New-SelfSignedCertificate -DnsName "Domain.extension1" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(1) -KeySpec KeyExchange

# Export certificate to .pfx file
$mycert | Export-PfxCertificate -FilePath parentCompanyEXO.pfx -Password (Get-Credential).password

# Export certificate to .cer file
$mycert | Export-Certificate -FilePath parentCompanyEXO.cer
SignatureBlock

