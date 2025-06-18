Get-ChildItem -Path ".\" -Recurse | Get-ItemProperty | Where-Object {($_.PSObject.properties.'value' -like "*$userName*") -or ($_.PSObject.properties.'value' -contains "*$userName*")}

Get-ChildItem -Path HKLM:\,HKCU:\ -Recurse | ForEach-Object { Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue } | Where-Object { $_.PSObject.Properties.Value -like "*$userName*" } | ForEach-Object { Write-Host "$($_.PSPath): $($_.PSObject.Properties.Name) = $($_.PSObject.Properties.Value)" }
# SIG # Begin signature block#Script Signature# SIG # End signature block





