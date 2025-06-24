Connect-MicrosoftTeams
$CQ = Get-CSCallQueue -NameFilter "GIT Help Desk CQ"
Set-CsCallQueue -Identity $CQ.Identity -TimeoutThreshold "20"

SignatureBlock

