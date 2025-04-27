Connect-MGGraph -nowelcome
$userUPN = Read-Host "Enter the user principal name of the user who's immutable ID you need to clear"
$user = (Get-MGBetaUser -userid $userUPN).id
Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/Users/$user" -Body @{OnPremisesImmutableId = $null}
# SIG # Begin signature block#Script Signature# SIG # End signature block



