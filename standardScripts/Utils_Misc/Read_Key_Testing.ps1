while ($true){
$keyInfo = $keyInfo = $host.ui.rawui.readKey("IncludeKeyDown,NoEcho")
if ($keyInfo.Character -eq 'k'){Write-Output "$($keyInfo.Character) Key Pressed!"}
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



