Connect-ExchangeOnline
$messageTraceLogger = @()
If ($null -eq $senderAddress){
    $senderAddress = Read-Host "Enter the sender address"
}
$i = 2
while ($i -gt 1 ){$messageTraceInfo = @()
$failedMessages = Get-MessageTrace -SenderAddress $senderAddress -Status Failed , Pending , FilteredAsSpam

ForEach ($failedMessage in $failedMessages)
{
    $messageDetail = $failedMessage | Get-MessageTraceDetail | Where-Object {($_.Event -in "Fail","Drop","Spam")} | Select-Object *

    
    $messageTraceInfo +=[PSCustomObject]@{
        senderAddress = $failedMessage.SenderAddress
        RecipientAddress = $failedMessage.RecipientAddress
        reasonFailed    = $messageDetail
    }
} Write-Output "[$(Get-Date -Format HH:mm)] The following messages FROM $senderAddress have errors`n`n`n"
$messageTraceInfo | Select-Object * | Format-Table
$now = Get-Date -Format "HH:mm" 
Write-Output "`n`n-Press Any Key to Re-Run`n`n-Press Control+C to exit-`n`n`n"
$messageTraceLogger += [PSCustomObject]@{
    Time        =   $now
    traceData   =   $messageTraceInfo
}
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
Clear-Host
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



