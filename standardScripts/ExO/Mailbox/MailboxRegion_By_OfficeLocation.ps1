$offices = ($allMailboxesNoRegion | Select Office -unique | sort).Office
ForEAch ($office in $offices){
switch ($office) {
    'unique-Company-Name-18' {$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'unique-Office-Location-21'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'uniqueParentCompany (Beijing) Refrigeration Equipment Co., Ltd.'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'unique-Company-Name-6'{$mailboxRegion = "EUR"
    $usageLocation = "DK"}
    'unique-Office-Location-2'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'uniqueParentCompany (Shanghai)  Refrigeration Equipment Co.,Ltd'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'Indaiatuba'{$mailboxRegion = "IND"
    $usageLocation = "IN"}
    'unique-Company-Name-20'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'unique-Company-Name-11'{$mailboxRegion = "CAN"
    $usageLocation = "CA"}
    'unique-Company-Name-2'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'unique-Office-Location-16'{$mailboxRegion = "BRA"
    $usageLocation = "BR"}
    'unique-Office-Location-9'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'unique-Company-Name-16'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'Itu'{$mailboxRegion = "EUR"
    $usageLocation = "IT"}
    'unique-Office-Location-0'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'unique-Office-Location-18'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'unique-Office-Location-3'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    Default {$mailboxRegion = $null
    $usageLocation = $null}
}
$officeUsers = $allMailboxesNoRegion | where {($_.Office -eq $office)}
ForEach ($officeUser in $officeUsers){
    Set-Mailbox -identity $officeUser.GUID -mailboxRegion $mailboxRegion
}
}
    
# SIG # Begin signature block#Script Signature# SIG # End signature block

















