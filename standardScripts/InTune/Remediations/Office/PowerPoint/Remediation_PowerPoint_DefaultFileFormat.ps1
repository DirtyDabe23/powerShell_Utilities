Set-Location "HKCU:\"
$path = ".\Software\Microsoft\Office\16.0\PowerPoint\Options"
Set-ItemProperty -Path $path -Name defaultFormat -Value $null
$defaultFormat = (Get-ItemProperty -Path ".\Software\Microsoft\Office\16.0\PowerPoint\Options").defaultFormat
if ($defaultFormat -eq "") { 
  Write-Host "Correct Format"
  Exit 0
} 
Else {
  Write-Host "Incorrect Format"
  Exit 1
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





