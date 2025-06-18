$senderAddress = Read-Host "Enter the sender address"
$messageTraceInfo = @()
$failedMessages = Get-MessageTrace -SenderAddress $senderAddress -Status Failed , Pending , FilteredAsSpam

ForEach ($failedMessage in $failedMessages)
{
    $messageDetail = $failedMessage | Get-MessageTraceDetail | Where-Object {($_.Event -like "Fail")} | Select-Object *
    
    $messageTraceInfo +=[PSCustomObject]@{
        senderAddress = $failedMessage.SenderAddress
        RecipientAddress = $failedMessage.RecipientAddress
        reasonFailed    = $messageDetail.Detail
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



