#Enter credentials for domain admin account
$cred = Get-Credential
#Pulls all the computers 
$computers = Get-ADComputer -filter * -Properties * | Where-Object {($_.LastLogonDate -gt (Get-Date).AddDays(-90))} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "Name"
#Initializes the object to store all values
$networkProfileData = @()
#Counter for Tracking
$counter = 1

#FileShare to export the CSV 
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
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
    If(Test-WSMan -computer $computer.Name -erroraction SilentlyContinue) 
    {
    #Creates session data per endpoint
    try{
    $session = New-PSSession -ComputerName $computer.name -Credential $cred -ErrorAction Stop
    }
    catch{
        $networkProfileData += [PSCustomObject]@{
            computerName = $computer.Name 
            connectionName = "Unable to connect"
            interfaceAlias = "Unable to connect"
            interfaceIndex = "Unable to connect"
            networkCategory = "Unable to connect"
            domainAuthenticationKind = "Unable to connect"
            ipv4Connectivity = "Unable to connect"
            ipv6Connectvitiy = "Unable to connect"
    }
    $counter++
    continue
    }
    #Gets the network adapaters on the endpoints.
    try {
        $netAdapters = Invoke-Command -Session $session -ScriptBlock {Get-NetAdapter} -ErrorAction Stop 
    }
    catch {
        $networkProfileData += [PSCustomObject]@{
            computerName = $computer.Name 
            connectionName = "Unable to get Adapters"
            interfaceAlias = "Unable to get Adapters"
            interfaceIndex = "Unable to get Adapters"
            networkCategory = "Unable to get Adapters"
            domainAuthenticationKind = "Unable to get Adapters"
            ipv4Connectivity = "Unable to get Adapters"
            ipv6Connectvitiy = "Unable to get Adapters"
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
            
            try {
            $netProfile = Invoke-Command -Session $session -ScriptBlock {param ($netAdapIndex) Get-NetConnectionProfile -InterfaceIndex $netAdapIndex} -ArgumentList $netAdapIndex -ErrorAction Stop
            } 
            catch{
                $networkProfileData += [PSCustomObject]@{
                    computerName = $computer.Name 
                    connectionName = "Index Lookup Failed"
                    interfaceAlias = "Index Lookup Failed"
                    interfaceIndex = $netAdapIndex
                    networkCategory = "Index Lookup Failed"
                    domainAuthenticationKind = "Index Lookup Failed"
                    ipv4Connectivity = "Index Lookup Failed"
                    ipv6Connectvitiy = "Index Lookup Failed"
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
                computerName = $computer
                connectionName = $netProfile.Name
                interfaceAlias = $netprofile.InterfaceAlias
                interfaceIndex = $netprofile.InterfaceIndex
                networkCategory = $networkCategory 
                domainAuthenticationKind = $netprofile.DomainAuthenticationKind
                ipv4Connectivity = $netprofile.IPv4Connectivity
                ipv6Connectvitiy = $netprofile.IPv6Connectivity
                }
        }

    }
    #If the computer can't be remoted into, we're just marking it down as unable to check with its name.
    else
    {
        $networkProfileData += [PSCustomObject]@{
            computerName = $computer.Name 
            connectionName = "Unable to check"
            interfaceAlias = "Unable to check"
            interfaceIndex = "Unable to check"
            networkCategory = "Unable to check"
            domainAuthenticationKind = "Unable to check"
            ipv4Connectivity = "Unable to check"
            ipv6Connectvitiy = "Unable to check"
    }
    }
#increment the counter
$counter++
} 

$endTime = Get-Date
$netTime = $endTime - $start_Time 
Write-Output "[$($currTime)] | Time taken for [Network Profile Configuration Audit] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"

$exportPath = $shareLoc+$dateTime+"."+$fileName

$networkProfileData | export-csv -path $exportPath

# SIG # Begin signature block#Script Signature# SIG # End signature block




