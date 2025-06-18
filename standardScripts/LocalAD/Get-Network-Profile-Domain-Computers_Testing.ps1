#$cred = Get-Credential
$networkProfileData = @()
$computer = "DCCORP6"
$session = New-PSSession -ComputerName $computer -Credential $cred
$netAdapters = Invoke-Command -Session $session -ScriptBlock {Get-NetAdapter}
    ForEach ($netAdapter in $netAdapters)
    {
        $netAdapIndex = $netAdapter.interfaceIndex 
        $netProfile = Invoke-Command -Session $session -ScriptBlock {param ($netAdapIndex) Get-NetConnectionProfile -InterfaceIndex $netAdapIndex} -ArgumentList $netAdapIndex
        $networkProfileData += [PSCustomObject]@{
            computerName = $computer
            connectionName = $netProfile.Name
            interfaceAlias = $netprofile.InterfaceAlias
            interfaceIndex = $netprofile.InterfaceIndex
            networkCategory = $netProfile.NetworkCategory
            domainAuthenticationKind = $netprofile.DomainAuthenticationKind
            ipv4Connectivity = $netprofile.IPv4Connectivity
            ipv6Connectvitiy = $netprofile.IPv6Connectivity
            }
    }

# SIG # Begin signature block#Script Signature# SIG # End signature block



