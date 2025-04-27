$output = @()
$masterRoles = Get-ADDomainController -Filter * | Select-Object Name, Domain, Forest, OperationMasterRoles | Where-Object {$_.OperationMasterRoles} 
ForEach ($masterRole in $MasterRoles.OperationMasterRoles)
{
    $Output += [PSCustomObject]@{
        ServerName = $masterRoles.Name
        Domain = $masterRoles.Domain
        Forest = $masterRoles.Forest
        OperationMasterRole = $masterRole
    }
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




