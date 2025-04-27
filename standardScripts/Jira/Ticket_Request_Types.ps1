$ticketCSV = import-csv -path "C:\temp\2023_12_18_Export_Afternoon.csv"
$requestTypes = $ticketCSV | Select-Object -Property 'Customer Request Type' -Unique
$requestTypes = $requestTypes.'Customer Request Type'
$ticketData = @()

foreach ($requestType in $requestTypes) 
{
    $ticketCount = $ticketCSV | Where-object {($_.'Customer Request Type' -eq "$requestType")}
    $ticketCount = $ticketCount.Count
	if($TicketCount -eq $null){$ticketcount = '1'}
      $ticketData += [PSCustomObject]@{
        'Customer Request Type'       = $requestType
        Count = $ticketCount
        }
    
}
$ticketData = $ticketData | sort-object -Property Count -Descending
# SIG # Begin signature block#Script Signature# SIG # End signature block



