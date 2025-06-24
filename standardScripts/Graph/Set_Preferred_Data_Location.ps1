$allUsers = Get-MgBetaUser -all -consistencyLevel eventual -property * | Select-Object -Property *
$needsLocations = $allUsers | Where {(($_.PreferredDataLocation -eq "") -or ($null -eq $_.PreferredDataLocation)) -and ($_.OnPremisesSyncEnabled -ne $true) -and ($_.UserType -eq 'Member')}
$officeLocations = $needsLocations | Select-Object -Property OfficeLocation -unique | sort
ForEAch ($Location in $officeLocations.OfficeLocation){
    switch ($location) {
        'subsidiaryCompany2, Inc.' {$dataRegion = "NAM"
        $usageLocation = "US"}
        'parentCompany Select Tech'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'parentCompany (Beijing) Refrigeration Equipment Co., Ltd.'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'parentCompany Europe A/S'{$dataRegion = "EUR"
        $usageLocation = "DK"}
        'parentCompany Midwest'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'parentCompany (Shanghai)  Refrigeration Equipment Co.,Ltd'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'Indaiatuba'{$dataRegion = "IND"
        $usageLocation = "IN"}
        'subsidiaryCompany1'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'parentCompany LMP'{$dataRegion = "CAN"
        $usageLocation = "CA"}
        'parentCompany Alcoil, Inc.'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'subsidiaryCompany3'{$dataRegion = "BRA"
        $usageLocation = "BR"}
        'parentCompany (Shanghai) Refrigeration Equipment Co., Ltd.'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'subsidiaryCompany2 (Shanghai) Cooling Tower Co., Ltd.'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'Itu'{$dataRegion = "EUR"
        $usageLocation = "IT"}
        'parentCompany East'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'parentCompany Air Cooling Systems (Jiaxing) Co., Ltd.'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'parentCompany Iowa'{$dataRegion = "NAM"
        $usageLocation = "US"}
        Default {$dataRegion = $null
        $usageLocation = $null}
    }
    Write-output "$location Data Region: $DataRegion"
    if ($dataRegion){
        $users = $needsLocations | where {($_.OfficeLocation -eq $location)}
        ForEAch ($user in $users){
            Update-MgBetaUser -userid $user.ID -PreferredDataLocation "$dataRegion"
        }
    }
}
SignatureBlock

