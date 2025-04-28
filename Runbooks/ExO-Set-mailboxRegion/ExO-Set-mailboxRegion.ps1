Connect-ExchangeOnline -ManagedIdentity -Organization $parentCompany.onmicrosoft.com
$allMailboxesNoRegion = Get-Mailbox -ResultSize Unlimited | select-object -Property DisplayName, OFfice , PrimarySMTPAddress,  GUID , ID , UsageLocation , MailboxRegion | Where-Object {($_.Mailboxregion -eq '') -or ($_.MailboxRegion -eq $null)}

if($allMailboxesNoRegion){ $usageLocations = $allMailboxesNoRegion.UsageLocation | Where-Object {($_ -ne "") -and ($_ -ne $null)}
    ForEach ($usageLocation in $usageLocations){
     switch ($usageLocation) {
         'South Korea' {$mailboxRegion = "APC"}
         'Japan'{$mailboxRegion = "APC"}
         'Singapore'{$mailboxRegion = "APC"}
         'Malaysia'{$mailboxRegion = "APC"}
         'Hong Kong Special Administrative Region'{$mailboxRegion = "APC"}
         'Australia'{$mailboxRegion = "AUS"}
         'Brazil'{$mailboxRegion = "BRA"}
         'Canada'{$mailboxRegion = "CAN"}
         'France'{$mailboxRegion = "EUR"}
         'Netherlands'{$mailboxRegion = "EUR"}
         'Ireland'{$mailboxRegion = "EUR"}
         'Norway'{$mailboxRegion = "EUR"}
         'Switzerland'{$mailboxRegion = "EUR"}
         'Austria'{$mailboxRegion = "EUR"}
         'Finland'{$mailboxRegion = "EUR"}
         'Sweden'{$mailboxRegion = "EUR"}
         'Germany'{$mailboxRegion = "EUR"}
         'India'{$mailboxRegion = "IND"}
         'Isreal'{$mailboxRegion = "ISR"}
         'Italy'{$mailboxRegion = "ITA"}
         'Japan'{$mailboxRegion = "JPN"}
         'Korea'{$mailboxRegion = "KOR"}
         'Mexico'{$mailboxRegion = "MEX"}
         'New Zealand'{$mailboxRegion = "NZL"}
         'Norway'{$mailboxRegion = "NOR"}
         'Poland'{$mailboxRegion = "POL"}
         'Qatar'{$mailboxRegion = "QAT"}
         'South Africa'{$mailboxRegion = "ZAF"}
         'Spain'{$mailboxRegion = "ESP"}
         'Sweden'{$mailboxRegion = "SWE"}
         'Switzerland'{$mailboxRegion = "CHE"}
         'Taiwan'{$mailboxRegion = "TWN"}
         'United Arab Emirates'{$mailboxRegion = "ARE"}
         'United Kingdom'{$mailboxRegion = "GBR"}
         'United States'{$mailboxRegion = "NAM"}
         Default {$mailboxRegion = $null}
     }
    Write-Output "Addressing: $usageLocation"
    $usageLocationMailboxes     = $allMailboxesNoRegion | where-object {($_.UsageLocation -eq $usageLocation)} 
    ForEach ($mailbox in $usageLocationMailboxes){
        Write-Output "$($mailbox.DisplayName) | Applying Region: $mailboxRegion"
        Set-Mailbox -identity $mailbox.GUID -mailboxRegion $mailboxRegion
    }
 }
}
