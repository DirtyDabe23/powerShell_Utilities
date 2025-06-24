$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Vacation Calendar.url")
)
$urlShortcut.TargetPath = "https://parentCompanyinc.sharepoint.com/officeattendance/Location/SitePages/Home.aspx?OR=Teams-HL&CT=1632148872282"
$urlShortcut.Save()


$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "CompuData Remote Environment.url")
)
$urlShortcut.TargetPath = "https://Domain.extension1pudatacloud.com"
$urlShortcut.Save()

$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Two Hour Tracking.url")
)
$urlShortcut.TargetPath = "https://parentCompanyinc.sharepoint.com/masterschedule/Location/SitePages/Home.aspx"
$urlShortcut.Save()


$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Master Scheduler.url")
)
$urlShortcut.TargetPath = "https://parentCompanyinc.sharepoint.com/masterschedule"
$urlShortcut.Save()

$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Marketing.url")
)
$urlShortcut.TargetPath = "https://parentCompanyinc.sharepoint.com/marketing"
$urlShortcut.Save()


$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "GIT Help.url")
)
$urlShortcut.TargetPath = "https://help.Domain.extension1"
$urlShortcut.Save()



$TargetFile = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
$ShortcutFile = "$env:Public\Desktop\OneDrive.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

SignatureBlock

