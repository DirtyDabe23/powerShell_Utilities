#Create ComplteamMemberce Search
$Search=New-ComplteamMemberceSearch -Name "Remove Phishing Message" -ExchangeLocation All -ContentMatchQuery '(Sender:noreply@correosprepago.es)'

#Start a complteamMemberce search
Start-ComplteamMemberceSearch -Identity $Search.Identity

#SET TO PURGE
New-ComplteamMemberceSearchAction -SearchName "Remove Phishing Message" -Purge -PurgeType HardDelete

# SIG # Begin signature block#Script Signature# SIG # End signature block




