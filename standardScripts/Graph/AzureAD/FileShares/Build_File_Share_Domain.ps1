#Build the File Share for Azure
$serverEndpointPath

New-SMBShare -Name "GlobalFS" -Path $serverEndpointPath

# SIG # Begin signature block#Script Signature# SIG # End signature block




