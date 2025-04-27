Connect-MsolService
$upnSource = Read-Host -Prompt "Enter the source username"
$newUPN = Read-Host -Prompt "Enter the new UPN"
Set-MsolUserPrincipalName -UserPrincipalName $upnSource -NewUserPrincipalName $newUPN

# SIG # Begin signature block#Script Signature# SIG # End signature block



