$offices = ($allMailboxesNoRegion | Select Office -unique | sort).Office
ForEAch ($office in $offices){
switch ($office) {
    'subsidiaryCompany2, Inc.' {$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'parentCompany Select Tech'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'parentCompany (Beijing) Refrigeration Equipment Co., Ltd.'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'parentCompany Europe A/S'{$mailboxRegion = "EUR"
    $usageLocation = "DK"}
    'parentCompany Midwest'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'parentCompany (Shanghai)  Refrigeration Equipment Co.,Ltd'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'Indaiatuba'{$mailboxRegion = "IND"
    $usageLocation = "IN"}
    'subsidiaryCompany1'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'parentCompany LMP'{$mailboxRegion = "CAN"
    $usageLocation = "CA"}
    'parentCompany Alcoil, Inc.'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'subsidiaryCompany3'{$mailboxRegion = "BRA"
    $usageLocation = "BR"}
    'parentCompany (Shanghai) Refrigeration Equipment Co., Ltd.'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'subsidiaryCompany2 (Shanghai) Cooling Tower Co., Ltd.'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'Itu'{$mailboxRegion = "EUR"
    $usageLocation = "IT"}
    'parentCompany East'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    'parentCompany Air Cooling Systems (Jiaxing) Co., Ltd.'{$mailboxRegion = "NAM"
    $usageLocation = "CN"}
    'parentCompany Iowa'{$mailboxRegion = "NAM"
    $usageLocation = "US"}
    Default {$mailboxRegion = $null
    $usageLocation = $null}
}
$officeUsers = $allMailboxesNoRegion | where {($_.Office -eq $office)}
ForEach ($officeUser in $officeUsers){
    Set-Mailbox -identity $officeUser.GUID -mailboxRegion $mailboxRegion
}
}
    
SignatureBlock

