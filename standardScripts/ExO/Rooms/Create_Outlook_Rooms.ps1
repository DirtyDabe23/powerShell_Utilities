New-Mailbox -Name "unique-Company-Name-7 - Room 1" -DisplayName "unique-Company-Name-7 - Room 1" -Room
New-Mailbox -Name "unique-Company-Name-7 - Room 2" -DisplayName "unique-Company-Name-7 - Room 2" -Room
New-Mailbox -Name "unique-Company-Name-7 - Room 3" -DisplayName "unique-Company-Name-7 - Room 3" -Room
New-Mailbox -Name "unique-Company-Name-7 - Production Meeting Room" -DisplayName "unique-Company-Name-7 - Production Meeting Room" -Room


Add-DistributionGroupMember -Identity "unique-Company-Name-7 Conference Rooms" -Member "unique-Company-Name-7 - Room 1"
Add-DistributionGroupMember -Identity "unique-Company-Name-7 Conference Rooms" -Member "unique-Company-Name-7 - Room 2"
Add-DistributionGroupMember -Identity "unique-Company-Name-7 Conference Rooms" -Member "unique-Company-Name-7 - Room 3"
Add-DistributionGroupMember -Identity "unique-Company-Name-7 Conference Rooms" -Member "unique-Company-Name-7 - Production Meeting Room"


Set-Place -Identity "unique-Company-Name-7 - Room 1" -CountryOrRegion "BE"  -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $true -Capacity 16 -Label "unique-Company-Name-7 - Room 1" 
Set-Place -Identity "unique-Company-Name-7 - Room 2" -CountryOrRegion "BE"  -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $false -Capacity 6 -Label "unique-Company-Name-7 - Room 2" 
Set-Place -Identity "unique-Company-Name-7 - Room 3" -CountryOrRegion "BE"  -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $false -Capacity 6 -Label "unique-Company-Name-7 - Room 3"
Set-Place -Identity "unique-Company-Name-7 - Production Meeting Room" -CountryOrRegion "BE" -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $true -Capacity 12 -Label "unique-Company-Name-7 - Production Meeting Room"

# SIG # Begin signature block#Script Signature# SIG # End signature block




