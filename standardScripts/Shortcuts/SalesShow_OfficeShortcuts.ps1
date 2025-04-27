
$TargetFile = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.exe"
$ShortcutFile = "$env:Public\Desktop\Word.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()


$TargetFile = "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.exe"
$ShortcutFile = "$env:Public\Desktop\PowerPoint.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()



$TargetFile = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.exe"
$ShortcutFile = "$env:Public\Desktop\Excel.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

# SIG # Begin signature block#Script Signature# SIG # End signature block




