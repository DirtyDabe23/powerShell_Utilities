$allMailboxes = Get-Mailbox -ResultSize Unlimited | select * 
$brasilMailboxes = $allMailboxes | Where-Object {($_.UsageLocation -eq 'Brazil') -and ($_.receipienttypedetails -eq "SharedMailbox")}
 
# SIG # Begin signature block#Script Signature# SIG # End signature block



