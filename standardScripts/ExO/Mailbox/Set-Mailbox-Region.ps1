ForEach ($usageLocation in $usageLocations.UsageLocation){
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
        'Switzerland'{$mailboxRegion = "CHE"}
        'Taiwan'{$mailboxRegion = "TWN"}
        'United Arab Emirates'{$mailboxRegion = "ARE"}
        'United Kingdom'{$mailboxRegion = "GBR"}
        'United States'{$mailboxRegion = "NAM"}
        Default {$mailboxRegion = $null}
    }
    Get-Mailbox -Filter "usageLocation -eq '$usageLocation'" | Set-Mailbox -MailboxRegion $mailboxRegion
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



