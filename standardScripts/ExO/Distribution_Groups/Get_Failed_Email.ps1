$sender = "kevin.williams@Domain.extension1"

Get-MessageTrace -status "failed", "quarantined", "FilteredasSpam" -senderaddress $sender

SignatureBlock

