If(Test-Path "C:\Program Files\Autodesk\Revit 2025\Revit.exe")
{
    If (Test-Path "C:\Users\Public\Desktop\Revit Viewer 2025.lnk")
    {
    Exit 0
    }
    Else{
        Exit 1
    }
}
Else
{
    Exit 1
}



# SIG # Begin signature block#Script Signature# SIG # End signature block




