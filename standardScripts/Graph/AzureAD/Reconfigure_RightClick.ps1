    If(!(Test-Path -path "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -erroraction silentlycontinue))
    {
    reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    Get-Process -name "Explorer" | Stop-Process 
    }
    Else{
        Write-Host "Already Done"
    }
# SIG # Begin signature block#Script Signature# SIG # End signature block




