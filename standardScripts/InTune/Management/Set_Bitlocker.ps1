Enable-Bitlocker -MountPoint "C:" -EncryptionMethod XtsAes256 -RecoveryPasswordProtector 
Get-BitlockerVolume "C:" | select KeyProtector -ExpandProperty KeyProtector
# SIG # Begin signature block#Script Signature# SIG # End signature block



