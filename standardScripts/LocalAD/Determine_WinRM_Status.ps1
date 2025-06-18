#Enter credentials for domain admin account
$cred = Get-Credential
#Pulls all the computers 
$computers = Get-ADComputer -filter * -Properties * | Where-Object {($_.LastLogonDate -gt (Get-Date).AddDays(-90))} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "Name"
#Initializes the object to store all values
$networkProfileData = @()
#Counter for Tracking
$counter = 1

#FileShare to export the CSV 
$shareLoc = "C:\Temp\"
$fileName = "networkProfileData.csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm

#Time tracking for how long this process takes
$Start_Time = Get-Date 

ForEach ($computer in $computers)
{
    #information logging
    $currTime = Get-Date -format "HH:mm"
    Write-Host "[$($currTime)] | $counter/$($computers.count) | Checking: $($computer.Name)"

    #Tests to see if the computer can be connected to remotely, if it can, it proceeds, otherwise it sets all values to null
    If (Test-Connection -ComputerName $computer.name -ErrorAction SilentlyContinue -Count 1)
    {
        #Gets the IP Address
        $endpointIP = (test-connection -ComputerName $computer.name -count 1).IPV4Address.ipaddresstostring
        
        If(Test-WSMan -computer $computer.Name -erroraction SilentlyContinue) 
        {
            #Creates session data per endpoint
            try
            {
            $session = New-PSSession -ComputerName $computer.name -Credential $cred -ErrorAction Stop
            }
            catch
            {
                $networkProfileData += [PSCustomObject]@{
                    computerName                = $computer.Name
                    computerIPV4Address         = $endpointIP
                    pingResponse                = "Successful"
                    winRMStatus                 = "Successful"
                    psSessionStatus                = "Failed"
                    getNetAdapterStatus            = "Unable to Assess"
                    getNetConnectionProfile        = "Unable to Assess"
                    interfaceIndex              = "Unable to Assess"
                    connectionName              = "Unable to Assess"
                    interfaceAlias              = "Unable to Assess"
                    networkCategory             = "Unable to Assess"
                    domainAuthenticationKind    = "Unable to Assess"
                    ipv4Connectivity            = "Unable to Assess"
                    ipv6Connectvitiy            = "Unable to Assess"
                                                        }  
            $counter++
            continue
            }
            #Gets the network adapaters on the endpoints.
            try 
            {
                $netAdapters = Invoke-Command -Session $session -ScriptBlock {Get-NetAdapter} -ErrorAction Stop 
            }
            catch 
            {
                $networkProfileData += [PSCustomObject]@{
                    computerName                = $computer.Name
                    computerIPV4Address         = $endpointIP
                    pingResponse                = "Successful"
                    winRMStatus                 = "Successful"
                    psSessionStatus                = "Successful"
                    getNetAdapterStatus            = "Failed"
                    getNetConnectionProfile        = "Unable to Assess"
                    interfaceIndex              = "Unable to Assess"
                    connectionName              = "Unable to Assess"
                    interfaceAlias              = "Unable to Assess"
                    networkCategory             = "Unable to Assess"
                    domainAuthenticationKind    = "Unable to Assess"
                    ipv4Connectivity            = "Unable to Assess"
                    ipv6Connectvitiy            = "Unable to Assess"
                                                        }
            $counter++
            continue  
            }
            
            
            

                #Addresses every adapter individually 
                ForEach ($netAdapter in $netAdapters)
                {
                    #Assigning a subproperty to a variable for ease of passing into the script block
                    $netAdapIndex = $netAdapter.interfaceIndex 
                    #Get the netprofile information for only the adapter being addressed
                    
                    try 
                    {
                    $netProfile = Invoke-Command -Session $session -ScriptBlock {param ($netAdapIndex) Get-NetConnectionProfile -InterfaceIndex $netAdapIndex} -ArgumentList $netAdapIndex -ErrorAction Stop
                    } 
                    catch
                    {
                        $networkProfileData += [PSCustomObject]@{
                            computerName                = $computer.Name
                            computerIPV4Address         = $endpointIP
                            pingResponse                = "Successful"
                            winRMStatus                 = "Successful"
                            psSessionStatus                = "Successful"
                            getNetAdapterStatus            = "Successful"
                            getNetConnectionProfile        = "Failed"
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
                        pingResponse                = "Successful"
                        winRMStatus                 = "Successful"
                        psSessionStatus                = "Successful"
                        getNetAdapterStatus            = "Successful"
                        getNetConnectionProfile        = "Successful"
                        interfaceIndex              = $netAdapIndex
                        connectionName              = $netProfile.Name
                        interfaceAlias              = $netprofile.InterfaceAlias
                        networkCategory             = $networkCategory 
                        domainAuthenticationKind    = $netprofile.DomainAuthenticationKind
                        ipv4Connectivity            = $netprofile.IPv4Connectivity
                        ipv6Connectvitiy            = $netprofile.IPv6Connectivity
                } 
                }

            
    #increment the counter

        }
        
        else
        {
            $networkProfileData += [PSCustomObject]@{
                computerName                = $computer.Name
                computerIPV4Address         = $endpointIP
                pingResponse                = "Successful"
                winRMStatus                 = "Failed"
                psSessionStatus                = "Unable to Assess"
                getNetAdapterStatus            = "Unable to Assess"
                getNetConnectionProfile        = "Unable to Assess"
                interfaceIndex              = "Unable to Assess"
                connectionName              = "Unable to Assess"
                interfaceAlias              = "Unable to Assess"
                networkCategory             = "Unable to Assess"
                domainAuthenticationKind    = "Unable to Assess"
                ipv4Connectivity            = "Unable to Assess"
                ipv6Connectvitiy            = "Unable to Assess"
                                                    }  
        }

    }
    else 
    {
        #Gets the IP Address
        $endpointIP = (test-connection -ComputerName $computer.name -erroraction SilentlyContinue -count 1).IPV4Address.ipaddresstostring 
        
        switch ($endpointIP)
                    {
                        null{$networkCategory ="Public"}
                        1{$networkCategory = "Private"}
                        2{$networkCategory ="Domain"}
                    }

            $networkProfileData += [PSCustomObject]@{
                computerName                = $computer.Name
                computerIPV4Address         = $endpointIP
                pingResponse                = "Unable to Ping"
                winRMStatus                 = "Unable to Assess"
                psSessionStatus                = "Unable to Assess"
                getNetAdapterStatus            = "Unable to Assess"
                getNetConnectionProfile        = "Unable to Assess"
                interfaceIndex              = "Unable to Assess"
                connectionName              = "Unable to Assess"
                interfaceAlias              = "Unable to Assess"
                networkCategory             = "Unable to Assess"
                domainAuthenticationKind    = "Unable to Assess"
                ipv4Connectivity            = "Unable to Assess"
                ipv6Connectvitiy            = "Unable to Assess"
                                                    }  
    }
$counter++
}
$endTime = Get-Date
$netTime = $endTime - $start_Time 
Write-Output "[$($currTime)] | Time taken for [Network Profile Configuration Audit] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"

$exportPath = $shareLoc+$dateTime+"."+$fileName

$networkProfileData | export-csv -path $exportPath
$networkProfileData

# SIG # Begin signature block#Script Signature# SIG # End signature block



