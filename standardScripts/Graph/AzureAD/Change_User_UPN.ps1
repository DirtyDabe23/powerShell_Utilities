Connect-MsolService
$upnSource = Read-Host -Prompt "Enter the source username"
$newUPN = Read-Host -Prompt "Enter the new UPN"
Set-MsolUserPrincipalName -UserPrincipalName $upnSource -NewUserPrincipalName $newUPN

SignatureBlock

