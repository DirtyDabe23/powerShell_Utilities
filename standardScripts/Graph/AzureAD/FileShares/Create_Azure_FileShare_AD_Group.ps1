New-ADGroup -Name "GFS-Access" -SamAccountName "GFS-Access" -GroupCategory "Security" -GroupScope "Global" -DisplayName "GFS-Access" -Description "Grants Access to the Global File Share which is hosted via Azure File Sync"


$groupSID = "S-1-5-21-1606498617-567609507-740312968-22621"

$realSID = "*$groupSID"
$serverEndpointPath = "Z:\"
icacls $serverEndpointPath /grant:r $realSID':'RX /t  




$realSID = "*S-1-5-21-2622334066-3885296712-2215220612-15125"
$serverEndpointPath = "D:\Global"
icacls $serverEndpointPath /grant:r $realSID':'RX 


$realSID = "*S-1-5-21-2622334066-3885296712-2215220612-15704"
$serverEndpointPath = "D:\Global"
icacls $serverEndpointPath /grant:r $realSID':'RX 



# SIG # Begin signature block#Script Signature# SIG # End signature block




