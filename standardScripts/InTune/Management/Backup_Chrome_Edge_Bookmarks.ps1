    $chromeBookmarks = "$env:LocalAppData\Google\Chrome\User Data\Default\Bookmarks"
    $edgeBookmarks =  "$env:LocalAppData\Microsoft\Edge\User Data\Default\Bookmarks"
    if(!(Test-Path "C:\_Backup_AppData")){New-Item -Type Directory -Path "C:\_Backup_AppData\"}
    If (Test-Path $edgeBookmarks){Get-Item $edgeBookMarks | Copy-Item -Destination "C:\_Backup_AppData\$($($env:UserName).replace('.','-'))_edgeBookmarks" -Verbose -Force}
    if(Test-Path $chromeBookmarks){Get-Item $chromeBookmarks | Copy-Item -Destination "C:\_Backup_AppData\$($($env:UserName).replace('.','-'))_chromeBookMarks" -Verbose -Force}
    
# SIG # Begin signature block#Script Signature# SIG # End signature block



