
$commandletData = @()
ForEach ($commandlet in $Commandlets){
$commandData = Get-Help $commandlet
$commandletData += [PSCustomObject]@{
commandName = $commandlet
commandDescription = $commandData.description
}
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




