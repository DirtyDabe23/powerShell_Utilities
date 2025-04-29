$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Vacation Calendar.url")
)
$urlShortcut.TargetPath = "https://uniqueParentCompanyinc.sharepoint.com/officeattendance/Location/SitePages/Home.aspx?OR=Teams-HL&CT=1632148872282"
$urlShortcut.Save()


$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "CompuData Remote Environment.url")
)
$urlShortcut.TargetPath = "https://uniqueParentCompany.compudatacloud.com"
$urlShortcut.Save()

$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Two Hour Tracking.url")
)
$urlShortcut.TargetPath = "https://uniqueParentCompanyinc.sharepoint.com/masterschedule/Location/SitePages/Home.aspx"
$urlShortcut.Save()


$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Master Scheduler.url")
)
$urlShortcut.TargetPath = "https://uniqueParentCompanyinc.sharepoint.com/masterschedule"
$urlShortcut.Save()

$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Marketing.url")
)
$urlShortcut.TargetPath = "https://uniqueParentCompanyinc.sharepoint.com/marketing"
$urlShortcut.Save()


$wshShell = New-Object -ComObject "WScript.Shell"
$urlShortcut = $wshShell.CreateShortcut(
  (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "GIT Help.url")
)
$urlShortcut.TargetPath = "https://help.uniqueParentCompany.com"
$urlShortcut.Save()


# SIG # Begin signature block#Script Signature# SIG # End signature block





