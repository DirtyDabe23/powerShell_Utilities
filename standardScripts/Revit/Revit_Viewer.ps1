

If (!(Test-Path "C:\Program Files\Autodesk\Revit 2025\Revit.exe"))
{
    Exit 1
}


$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("C:\Users\Public\Desktop\Revit Viewer 2025.lnk") 
$shortcut.TargetPath = "C:\Program Files\Autodesk\Revit 2025\Revit.exe"
$Shortcut.Arguments = "/viewer /language ENU"
$shortcut.Save()
Exit 0
# SIG # Begin signature block#Script Signature# SIG # End signature block



