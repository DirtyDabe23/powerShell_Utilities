If !(Test-Path "C:\Temp")
{
    New-Item -Path "C:\" -Name "Temp" -Type Directory
}
else {
    Write-Output "Already exists"
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



