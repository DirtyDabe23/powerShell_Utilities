$gname = Read-Host -Prompt "Enter the Group Name"
Get-MGGroup -search "Displayname:$gname" -consistencylevel:eventual
SignatureBlock

