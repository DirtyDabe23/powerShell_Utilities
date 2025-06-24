Set-Location -Path "C:\Users\David.Drosdick\tempDir"
$scriptFiles = $items | where {($_.Extension -eq '.ps1')}
$WrapUpScriptContent = @()
ForEach ($script in $scriptFiles){
    $content = Get-Content -Path $script.FullName
    $WrapUpScriptContent += $content
    $WrapUpScriptContent += "`n`n"
}
$WrapUpScriptContent | Out-File -FilePath "C:\Users\David.Drosdick\tempDir\parentCompanyModule.ps1" -Force
$moduleFiles = $items | where {($_.Extension -eq '.psm1')}
$wrapUpModuleContent = @()
ForEach ($module in $moduleFiles){
    $content = Get-Content -Path $module.FullName
    $wrapUpModuleContent += $content
    $wrapUpModuleContent += "`n`n"
}
$wrapUpModuleContent | Out-File -FilePath "C:\Users\David.Drosdick\tempDir\parentCompanyModule.psm1" -Force
SignatureBlock

