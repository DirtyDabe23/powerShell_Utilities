Clear-Host
Copy-Item -Path "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Software\Revit_Viewer\*" -Destination "C:\Temp" -Recurse -Verbose

While (!(Test-Path "C:\Temp\Revit\image\Installer.exe"))
{
    Start-Sleep -Seconds 5
    
}
Start-Process "C:\Temp\Revit\image\Installer.exe" -ArgumentList  '-i deploy --offline_mode -q -o "C:\Temp\Revit\image\Collection.xml" --installer_version "2.10.0.92"' -Verbose -Wait

While (!(Test-Path "C:\Program Files\Autodesk\Revit 2025\Revit.exe"))
{
    Start-Sleep -Seconds 10
}


$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("C:\Users\Public\Desktop\Revit Viewer 2025.lnk") 
$shortcut.TargetPath = "C:\Program Files\Autodesk\Revit 2025\Revit.exe"
$Shortcut.Arguments = "/viewer /language ENU"
$shortcut.Save()
# SIG # Begin signature block#Script Signature# SIG # End signature block




