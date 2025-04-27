$path="HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$officeCheck = (Get-ItemProperty -Path $path).platform

if($officeCheck -eq 'x64'){
    Write-Output "Office is 64 bit."
}
else{
    Write-Output "Office is 32 bit."
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



