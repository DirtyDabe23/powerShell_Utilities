$tracker = @()
$allMailboxes = Get-Mailbox -resultSize unlimited | Select-Object -Property * 
ForEach($mailbox in $allMailboxes){
    $usageLocation = $mailbox.UsageLocation
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
        'Indai'{$mailboxRegion = "IND"}
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
        'Switzerland'{$mailboxREgion = "CHE"}
        'Taiwan'{$mailboxRegion = "TWN"}
        'United Arab Emirates'{$mailboxRegion = "ARE"}
        'United Kingdom'{$mailboxRegion = "GBR"}
        'United States'{$mailboxRegion = "NAM"}
        Default {$mailboxREgion = $null}
    }
    Write-output "$($mailbox.displayName) | UsageLocation: $($mailbox.UsageLocation) | Current Region: $($mailbox.$mailboxRegion) | New Region: $MailboxRegion"
    Try{
        Set-Mailbox -identity $mailbox.ID -mailboxregion $mailboxRegion -errorAction Stop
        Write-output "$($mailbox.displayNAme) | Update Successful"
        $status = "Successful"
    }
    catch{
        Write-output "$($mailbox.displayNAme) | Failed to Update"
        $status = "Failed"
    }
    $tracker += [PSCustomObject]@{
        mailboxName             =   $mailbox.DisplayName
        initialmailboxRegion    =   $mailbox.MailboxRegion
        newRegion               =   $mailboxRegion
        status                  =   $status
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



