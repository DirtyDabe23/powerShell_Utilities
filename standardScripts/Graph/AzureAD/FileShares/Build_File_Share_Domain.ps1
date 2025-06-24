#Build the File Share for Azure
$serverEndpointPath

New-SMBShare -Name "GlobalFS" -Path $serverEndpointPath

SignatureBlock

