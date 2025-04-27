$TargetFile = "%windir%\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"
$ShortcutFile = "$env:Public\Desktop\PS_ISE.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
# SIG # Begin signature block#Script Signature# SIG # End signature block



