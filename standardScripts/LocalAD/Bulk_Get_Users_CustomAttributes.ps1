#Returns all enabled users that are not a service account, that do not have extension attributes filled out 
$allUsers = Get-ADUser -filter * -properties *  | Where-Object {($_.Enabled -eq $true) -and ($_.company -ne "Not Affiliated") -and ($_.company -ne $null) -and ($_.extensionattribute1 -eq $null)}
# SIG # Begin signature block#Script Signature# SIG # End signature block



