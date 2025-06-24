#Create Compliance Search
$Search=New-ComplianceSearch -Name "Remove Phishing Message" -ExchangeLocation All -ContentMatchQuery '(Sender:noreply@correosprepago.es)'

#Start a compliance search
Start-ComplianceSearch -Identity $Search.Identity

#SET TO PURGE
New-ComplianceSearchAction -SearchName "Remove Phishing Message" -Purge -PurgeType HardDelete

SignatureBlock

