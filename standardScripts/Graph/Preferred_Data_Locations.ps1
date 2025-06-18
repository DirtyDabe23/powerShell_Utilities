$allUsers = Get-MgBetaUser -all -consistencyLevel eventual -property * | select *
$needsLocations = $allUsers | Where {(($_.PreferredDataLocation -eq "") -or ($null -eq $_.PreferredDataLocation)) -and ($_.OnPremisesSyncEnabled -ne $true)}
$usageLocations = ($needsLocations | select UsageLocation -unique).UsageLocation
$totalUsers = $needsLocations.Count
$counter = 1
ForEach ($user in $needsLocations){
 switch ($usageLocation) {
        'AE' {$dataRegion = "ARE"}
        'AT'{$dataRegion = "EUR"}
        'AU'{$dataRegion = "AUS"}
        'BE'{$dataRegion = "EUR"}
        'BR'{$dataRegion = "BRA"}
        'CA'{$dataRegion = "CAN"}
        'CN'{$dataRegion = "NAM"}
        'DE'{$dataRegion = "EUR"}
        'DK'{$dataRegion = "EUR"}
        'ES'{$dataRegion = "ESP"}
        'GB'{$dataRegion = "GBR"}
        'IT'{$dataRegion = "ITA"}
        'MY'{$dataRegion = "APC"}
        'US'{$dataRegion = "NAM"}
        'VN'{$dataRegion = "APC"}
        'ZA'{$dataRegion = "ZAF"}
        Default {$dataRegion = $null}
    }
    if ($dataRegion){
    Write-Output "[$(Get-Date -Format HH:mm)] $counter/$totalUsers  | $($user.DisplayName) | Setting Region: $dataRegion"
    Update-MgBetaUser -userid $user.ID -PreferredDataLocation $dataRegion
    $counter++
    }
}

# SIG # Begin signature block#Script Signature# SIG # End signature block



