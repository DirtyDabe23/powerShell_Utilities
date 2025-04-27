$ModuleName = "Clear-Enrollment"
$SourcePath = ".\Pre\Clear-Enrollment"  # Adjusted path to match the structure
$TargetPath7 = "C:\Program Files\PowerShell\Modules\$ModuleName"
$TargetPath5 = "C:\Program Files\WindowsPowerShell\Modules\$moduleName"

if (-not (Test-Path -Path $TargetPath7)) {
    New-Item -ItemType Directory -Path $TargetPath7 -Force
}
if (-not (Test-Path -Path $TargetPath5)) {
    New-Item -ItemType Directory -Path $TargetPath5 -Force
}

Copy-Item -Path "$SourcePath\*" -Destination $TargetPath7 -Recurse -Force
Copy-Item -Path "$SourcePath\*" -Destination $TargetPath5 -Recurse -Force

Write-Output "Module $ModuleName installed successfully to $TargetPath7 and $targetPath5"
# SIG # Begin signature block#Script Signature# SIG # End signature block




