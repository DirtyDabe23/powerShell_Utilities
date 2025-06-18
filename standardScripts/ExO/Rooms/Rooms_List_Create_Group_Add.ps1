#Get All RoomLists
Get-DistributionGroup -Filter {RecipientTypeDetails -eq "RoomList"} | Sort DisplayName | Format-Table DisplayName

#Get all GroupMembers in a RoomList 
Get-DistributionGroupMember -Identity "uniqueParentCompany TT Conference Rooms" | Sort Displayname | Format-Table DisplayName, RecipientTypeDetails


#Get All Room Mailboxes
Get-ExoMailbox -RecipientTypeDetails RoomMailbox | Sort DisplayName | Get-Place | Format-Table DisplayName, Building, Floor, City



#Set Config Options for RoomMailbox
Set-Place -Identity "Room1" -CountryOrRegion "US" -City "Location" -Floor 2 -MTREnabled $true -Capacity 10 -Street "Address1" -GeoCoordinates "Coordinates1" -Building "Global HQ" -State MD -PostalCode 21787 -Phone “PhoneNumber24" -Label "Department1" -VideoDeviceName "Teams Meeting Device" -DisplayDeviceName "Teams Meeting Device" -AudioDeviceName "Teams Meeting Device" -Tags Tag1, Tag2, Location


Set-Place -Identity "unique-Office-Location-3 - Bldg. A Conference Room" -CountryOrRegion "US" -City "Lake View" -Floor 2 -MTREnabled $true -Capacity 24 -Street "Address2" -Building "Building A" -State IA -PostalCode 51450 -Phone “PhoneNumber23" -Label "unique-Office-Location-3 - Building A Conference Room" -VideoDeviceName "Teams Meeting Device" -DisplayDeviceName "Teams Meeting Device" -AudioDeviceName "Teams Meeting Device" -Tags BuildingA, Tag2, Iowa

#Get all information about the room configurations
Get-ExoMailbox -RecipientTypeDetails RoomMailbox | Sort DisplayName | Get-Place | Select-Object -Property DisplayName, Capacity, CountryOrRegion, City, Floor, MTREnabled, Street, GeoCoordinates, Building, State, PostalCode, Phone, Label, VideoDeviceName, DisplayDeviceName, AudioDeviceName, Tags 


Set-Place -Identity "unique-Office-Location-3 - Bldg. B Conference Room" -CountryOrRegion "US" -State IA -PostalCode 51450 -City "Lake View" -Street "Address2" -Building "Building B" -Floor 2 -MTREnabled $false -Capacity 24 -Label "unique-Office-Location-3 - Building B Conference Room" -Tags BuildingB, Iowa
# SIG # Begin signature block#Script Signature# SIG # End signature block
















