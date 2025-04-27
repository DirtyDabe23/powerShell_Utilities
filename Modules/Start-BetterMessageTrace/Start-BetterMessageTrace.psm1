function Start-BetterMessageTrace {
    <#
    .SYNOPSIS
    This function performs a message trace based on a provided mailbox identity.  
    
    .DESCRIPTION
    This function performs a message trace based on the provided mailbox identity as a sender.
    It will search for all event types that correspond with a failure, run the command to pull all events that match the following
    EventType: Failed , Pending , FilteredAsSpam
    
    .EXAMPLE
    Start-BetterMessageTrace -senderAddress givenName.surName@domain.com 

    
    .NOTES
    This module is most performant on PowerShell 5.1.2
    It requires ExchangeOnlineManagement and the requisite permissions to perform message traces.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position=0,HelpMessage="Enter an identity that would be used for -senderAddress in get-messagetrace -senderaddress")]
        [string]
        $senderAddress,
        [Parameter(Position=1,HelpMessage="Enter an identity that would be used for -recipientAddress in get-messagetrace -recipientAddress")]
        [string]
        $recipientAddress
    )
    if (!($messageTraceLogger)){
    $messageTraceLogger     =   @()
    }
    $params = @{}
    if ($senderAddress){$Params.Add('senderAddress',$senderAddress)}
    if($recipientAddress){$Params.Add('recipientAddress',$recipientAddress)}
    $continue               =   $true
    while($continue){
        $messageTraceInfo   =   @()
        $failedMessages     =   Get-MessageTrace @params -status Failed , Pending , FilteredAsSpam
        forEach($failedMessage in $failedMessages){
            $messageDetails          =   $failedMessage | Get-MessageTraceDetail | Where-Object {($_.Event -in @("Fail","Drop","Spam"))} | Select-Object -Property *
            ForEach ($messageDetail in $messageDetails){
                $messageTraceInfo       +=  [PSCustomObject]@{
                    senderAddress       =   $failedMessage.senderAddress
                    recipientAddress    =   $failedMessage.recipientAddress
                    status              =   $failedMessage.Status
                    reasonFailed        =   $messageDetail.Detail
                }
            }
        }
        $now = Get-Date -Format "HH:mm"
        $messageTraceLogger         +=   [PSCustomObject]@{
            Time                    =   $now
            traceData               =   $messageTraceInfo
        }
        Write-Output "The messageTraceInfo returned:`n"
        return $messageTraceLogger
    }
}


# SIG # Begin signature block#Script Signature# SIG # End signature block



