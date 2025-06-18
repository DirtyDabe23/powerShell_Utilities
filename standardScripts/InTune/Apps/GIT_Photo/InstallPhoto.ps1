$SourcePath = ".\GIT_Logos"  # Adjusted path to match the structure
$TargetPath = "C:\GIT_Scripts\GIT_Logos\"

if (-not (Test-Path -Path $TargetPath)) {
    New-Item -ItemType Directory -Path $TargetPath -Force
}

Copy-Item -Path "$SourcePath\*" -Destination $TargetPath -Recurse -Force

# SIG # Begin signature block#Script Signature# SIG # End signature block




