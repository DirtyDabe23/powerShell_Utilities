If !(Test-Path "C:\Temp")
{
    New-Item -Path "C:\" -Name "Temp" -Type Directory
}
else {
    Write-Output "Already exists"
}
SignatureBlock

