Get-ChildItem -Path ".\" -Recurse | Get-ItemProperty | Where-Object {($_.PSObject.properties.'value' -like "*david.drosdick*") -or ($_.PSObject.properties.'value' -contains "*david.drosdick*")}

Get-ChildItem -Path HKLM:\,HKCU:\ -Recurse | ForEach-Object { Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue } | Where-Object { $_.PSObject.Properties.Value -like "*david.drosdick*" } | ForEach-Object { Write-Host "$($_.PSPath): $($_.PSObject.Properties.Name) = $($_.PSObject.Properties.Value)" }
SignatureBlock

