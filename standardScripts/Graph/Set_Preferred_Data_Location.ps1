$allUsers = Get-MgBetaUser -all -consistencyLevel eventual -property * | Select-Object -Property *
$needsLocations = $allUsers | Where {(($_.PreferredDataLocation -eq "") -or ($null -eq $_.PreferredDataLocation)) -and ($_.OnPremisesSyncEnabled -ne $true) -and ($_.UserType -eq 'Member')}
$officeLocations = $needsLocations | Select-Object -Property OfficeLocation -unique | sort
ForEAch ($Location in $officeLocations.OfficeLocation){
    switch ($location) {
        'unique-Company-Name-18' {$dataRegion = "NAM"
        $usageLocation = "US"}
        'unique-Office-Location-21'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'uniqueParentCompany (Beijing) Refrigeration Equipment Co., Ltd.'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'unique-Company-Name-6'{$dataRegion = "EUR"
        $usageLocation = "DK"}
        'unique-Office-Location-2'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'uniqueParentCompany (Shanghai)  Refrigeration Equipment Co.,Ltd'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'Indaiatuba'{$dataRegion = "IND"
        $usageLocation = "IN"}
        'unique-Company-Name-20'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'unique-Company-Name-11'{$dataRegion = "CAN"
        $usageLocation = "CA"}
        'unique-Company-Name-2'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'unique-Office-Location-16'{$dataRegion = "BRA"
        $usageLocation = "BR"}
        'unique-Office-Location-9'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'unique-Company-Name-16'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'Itu'{$dataRegion = "EUR"
        $usageLocation = "IT"}
        'unique-Office-Location-0'{$dataRegion = "NAM"
        $usageLocation = "US"}
        'unique-Office-Location-18'{$dataRegion = "NAM"
        $usageLocation = "CN"}
        'unique-Office-Location-3'{$dataRegion = "NAM"
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
# SIG # Begin signature block#Script Signature# SIG # End signature block

















