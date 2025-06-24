New-Mailbox -Name "parentCompany Europe BVBA - Room 1" -DisplayName "parentCompany Europe BVBA - Room 1" -Room
New-Mailbox -Name "parentCompany Europe BVBA - Room 2" -DisplayName "parentCompany Europe BVBA - Room 2" -Room
New-Mailbox -Name "parentCompany Europe BVBA - Room 3" -DisplayName "parentCompany Europe BVBA - Room 3" -Room
New-Mailbox -Name "parentCompany Europe BVBA - Production Meeting Room" -DisplayName "parentCompany Europe BVBA - Production Meeting Room" -Room


Add-DistributionGroupMember -Identity "parentCompany Europe BVBA Conference Rooms" -Member "parentCompany Europe BVBA - Room 1"
Add-DistributionGroupMember -Identity "parentCompany Europe BVBA Conference Rooms" -Member "parentCompany Europe BVBA - Room 2"
Add-DistributionGroupMember -Identity "parentCompany Europe BVBA Conference Rooms" -Member "parentCompany Europe BVBA - Room 3"
Add-DistributionGroupMember -Identity "parentCompany Europe BVBA Conference Rooms" -Member "parentCompany Europe BVBA - Production Meeting Room"


Set-Place -Identity "parentCompany Europe BVBA - Room 1" -CountryOrRegion "BE"  -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $true -Capacity 16 -Label "parentCompany Europe BVBA - Room 1" 
Set-Place -Identity "parentCompany Europe BVBA - Room 2" -CountryOrRegion "BE"  -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $false -Capacity 6 -Label "parentCompany Europe BVBA - Room 2" 
Set-Place -Identity "parentCompany Europe BVBA - Room 3" -CountryOrRegion "BE"  -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $false -Capacity 6 -Label "parentCompany Europe BVBA - Room 3"
Set-Place -Identity "parentCompany Europe BVBA - Production Meeting Room" -CountryOrRegion "BE" -City "Tongeren" -Building "Office" -Floor 0 -MTREnabled $true -Capacity 12 -Label "parentCompany Europe BVBA - Production Meeting Room"

SignatureBlock

