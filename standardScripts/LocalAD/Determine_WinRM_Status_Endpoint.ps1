$networkProfileData = @()
$netAdapters = Get-NetAdapter
#Addresses every adapter individually 
ForEach ($netAdapter in $netAdapters)
{
    #Assigning a subproperty to a variable for ease of passing into the script block
    $netAdapIndex = $netAdapter.interfaceIndex 
    #Get the netprofile information for only the adapter being addressed
    
    try 
    {
    $netProfile = Get-NetConnectionProfile -InterfaceIndex $netAdapIndex
    } 
    catch
    {
        $networkProfileData += [PSCustomObject]@{
            computerName                = $computer.Name
            computerIPV4Address         = $endpointIP
            pingResponse				= "Successful"
            winRMStatus                 = "Successful"
            psSessionStatus				= "Successful"
            getNetAdapterStatus			= "Successful"
            getNetConnectionProfile		= "Failed"
            interfaceIndex              = $netAdapIndex
            connectionName              = "Unable to Assess"
            interfaceAlias              = "Unable to Assess"
            networkCategory             = "Unable to Assess"
            domainAuthenticationKind    = "Unable to Assess"
            ipv4Connectivity            = "Unable to Assess"
            ipv6Connectvitiy            = "Unable to Assess"
                                                } 
    continue
    }

    #Switch Statements to get readable values for Network Category.
    $networkCategory = $netProfile.NetworkCategory
    switch ($networkCategory)
    {
        0{$networkCategory ="Public"}
        1{$networkCategory = "Private"}
        2{$networkCategory ="Domain"}
    }



    #Load the values into the object
    $networkProfileData += [PSCustomObject]@{
        computerName                = $computer.Name
        computerIPV4Address         = $endpointIP
        pingResponse				= "Successful"
        winRMStatus                 = "Successful"
        psSessionStatus				= "Successful"
        getNetAdapterStatus			= "Successful"
        getNetConnectionProfile		= "Successful"
        interfaceIndex              = $netAdapIndex
        connectionName              = $netProfile.Name
        interfaceAlias              = $netprofile.InterfaceAlias
        networkCategory             = $networkCategory 
        domainAuthenticationKind    = $netprofile.DomainAuthenticationKind
        ipv4Connectivity            = $netprofile.IPv4Connectivity
        ipv6Connectvitiy            = $netprofile.IPv6Connectivity
} 
}

# SIG # Begin signature block#Script Signature# SIG # End signature block



