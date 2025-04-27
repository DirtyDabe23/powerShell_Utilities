$procProcess = "DNS Record Review"


$dnsRecords = Get-DnsServerResourceRecord -ZoneName "uniqueParentCompany.com"
$dnsRecordObject = @()

$procStartTime = Get-Date 
ForEach ($dnsRecord in $dnsRecords)
{
    $dnsRecordObject += [PSCustomObject]@{
        name                    = $dnsRecord.hostName
        distinguishedName       = $dnsRecord.distinguishedName
        recordType              = $dnsRecord.recordType
        type                    = $dnsRecord.type
        recordClass             = $dnsRecord.recordClass
        timeToLive              = $dnsRecord.timeToLive
        recordDataAddress       = $dnsRecord.recordData.IPv4address.IPAddressToString
        recordDataAddressFamily = $dnsRecord.recorddata.IPv4Address.AddressFamily
        recordDataScopeID       = $dnsRecord.recordData.IPV4address.scopeID
    }

}
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime

$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Time taken for [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "$($procProcess).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$fileName
$dnsRecordObject | Export-CSV -path $exportPath
# SIG # Begin signature block#Script Signature# SIG # End signature block




