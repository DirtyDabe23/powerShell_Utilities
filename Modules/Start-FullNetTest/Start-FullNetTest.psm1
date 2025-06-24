function Start-FullNetTest{
    #Requires -Module NetTCPIP
    <#
    .SYNOPSIS
        This function tests connectivity to specified remote domain controllers on essential ports.
    .DESCRIPTION
        The function uses Test-NetConnection to check connectivity on various ports required for Active Directory operations.
    .PARAMETER RemoteDCs    
        An array of IP addresses or hostnames of remote domain controllers to test.

    .EXAMPLE
    Start-parentCompanyPingTest -target "google.com","12.43.63.23"
    This command runs the connectivity tests against specified IP addresses and hostnames.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position = 0,HelpMessage = "Enter the IP or hostname of the remote domain controllers to test." )]
        [ValidateNotNullOrEmpty()]
        [string]$target
    )

        $trackingResult = @()
        # Define the list of ports you'd like to test.
        $Ports = @(
            [PSCustomObject]@{ PortName = "DNS (TCP 53)"; PortNumber = 53 }
            [PSCustomObject]@{ PortName = "Kerberos (TCP 88)"; PortNumber = 88 }
            [PSCustomObject]@{ PortName = "LDAP (TCP 389)"; PortNumber = 389 }
            [PSCustomObject]@{ PortName = "LDAP GC (TCP 3268)"; PortNumber = 3268 }
            [PSCustomObject]@{ PortName = "SMB (TCP 445)"; PortNumber = 445 }
            [PSCustomObject]@{ PortName = "RPC Endpoint Mapper (TCP 135)"; PortNumber = 135 }
            [PSCustomObject]@{ PortName = "RPC Dynamic Ports (TCP 49152-65535) 1"; PortNumber = 42069 }
            [PSCustomObject]@{ PortName = "RPC Dynamic Ports (TCP 49152-65535) 2"; PortNumber = 49200 }
            [PSCustomObject]@{ PortName = "RPC Dynamic Ports (TCP 49152-65535) 3"; PortNumber = 49303 }
        )
        # Testing each of the defined ports.
        foreach ($PortName in $Ports) {
            $port = $PortName.PortNumber
            Write-Host "Testing $($PortName.PortName) on port $Port..."
            try{
                $pingResult = Test-NetConnection -ComputerName "$target" -Port $Port -errorAction stop
            }
            catch{
                Write-Warning "Failed to connect to $target on port $Port. Error: $_"
                $pingResult = $null
            }
            ForEach ($resolvedAddress in $pingResult.ResolvedAddresses.IPAddressToString){
                [string]$resolvedAddressList += $resolvedAddress , ", " -join ""
            }
            $trackingResult += [PSCustomObject]@{
            Target              = "$target"
            SourceAddress       = $pingResult.SourceAddress
            InterfaceAlias      = $pingResult.InterfaceAlias
            InterfaceIndex      = $pingResult.InterfaceIndex
            PortName            = $PortName.PortName
            PortNumber          = $PortName.PortNumber
            PingSucceeded       = $pingResult.PingSucceeded
            NameResolution      = $pingResult.NameResolutionSucceeded
            TCPTestSucceeded    = $pingResult.TcpTestSucceeded
            ResolvedAddress     = $resolvedAddressList.TrimEnd(", ")
            RemoteAddress       = $pingResult.RemoteAddress
            Route               = "N/A"
            }
        }
        $traceRouteResult = Test-NetConnection -ComputerName "$target" -TraceRoute
        ForEach ($resolvedAddress in $traceRouteREsults.ResolvedAddresses.IPAddressToString){
            [string]$resolvedAddressList += $traceRouteResults.ResolvedAddresses.IPAddressToString + ", "
        }
        ForEach ($hop in $traceRouteResults.TraceRoute){
            [string] $hopList += $hop + ", "
        }
            $trackingResult += [PSCustomObject]@{
            Target              = "$target"
            SourceAddress       = $traceRouteResult.SourceAddress
            InterfaceAlias      = $traceRouteREsult.InterfaceAlias
            InterfaceIndex      = $traceRouteResult.InterfaceIndex
            PortName            = "Trace Route"
            PortNumber          = "N/A"
            PingSucceeded       = $traceRouteResult.PingSucceeded
            NameResolution      = $traceRouteResult.NameResolutionSucceeded
            TCPTestSucceeded     = $traceRouteResult.TcpTestSucceeded
            ResolvedAddress     = $resolvedAddressList.TrimEnd(", ")
            RemoteAddress       = $traceRouteResult.RemoteAddress
            Route               = $hopList.TrimEnd(", ")
            }
        return $trackingResult
}
SignatureBlock

