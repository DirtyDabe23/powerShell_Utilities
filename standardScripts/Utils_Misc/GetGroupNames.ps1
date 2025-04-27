$gname = Read-Host -Prompt "Enter the Group Name"
Get-MGGroup -search "Displayname:$gname" -consistencylevel:eventual
# SIG # Begin signature block#Script Signature# SIG # End signature block



