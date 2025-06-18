$ProgName = "Dell Command | Update for Windows 10"
If(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'")
{
    Exit 1
}
else {
    Exit 0
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




