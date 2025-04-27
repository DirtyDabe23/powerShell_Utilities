$NetAdapters = Get-NetAdapter -Physical

ForEach ($NetAdapter in $NetAdapters){
    $Binding = Get-NetAdapterBinding -Name $NetAdapter.Name
    $ipV6Status = $Binding | Where-Object {($_.ComponentID -eq "ms_tcpip6")}
}
If ($ipv6Status.Enabled -eq $False){WRite-output "Disabled"}
Else{
    Disable-NetAdapterBinding -Name $NetAdapter.Name -ComponentID "ms_tcpip6"
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




