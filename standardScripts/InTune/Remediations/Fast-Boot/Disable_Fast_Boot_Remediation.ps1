Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberBootEnabled" -Type Dword -Value 0

$Key = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled"

If ($key.hiberBootEnabled -ne 0)
{
    Exit 1
}
Else{
    Exit 0
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




