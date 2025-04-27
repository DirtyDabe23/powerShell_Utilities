$allMGUsers = Get-MGBetaUser -All -ConsistencyLevel eventual
$allSynchingUsers = $allMGUsers | Where-Object {($_.OnPremisesSyncEnabled -eq $true)}
$allNonSynchingUsers = $allMGUsers | Where-Object {($_.OnPremisesSyncEnabled -ne $true)}

# SIG # Begin signature block#Script Signature# SIG # End signature block



