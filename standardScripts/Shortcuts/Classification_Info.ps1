$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Info Classification Tool.url")
)
$urlShortcut.TargetPath = "https://infoclass.uniqueParentCompany.com"
$urlShortcut.Save()

# SIG # Begin signature block#Script Signature# SIG # End signature block




