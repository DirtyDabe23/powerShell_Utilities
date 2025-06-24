$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Info Classification Tool.url")
)
$urlShortcut.TargetPath = "https://infoclass.Domain.extension1"
$urlShortcut.Save()

SignatureBlock

