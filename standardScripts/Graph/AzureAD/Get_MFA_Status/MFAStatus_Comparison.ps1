# Define the file paths
$e5UsersFile = "C:\Temp\0717_MFAStatusByOfficeE5.csv"
$MFAenabledMembersFile= "C:\Temp\MFAEnabledGroupMembers.csv"


$inMFAGroupFile = "C:\Temp\InMFAGroup.csv"
$nonMFAGroupFile = "C:\Temp\NonMFAGroup.csv"


# Load the CSV files
$e5users = Import-Csv $e5UsersFile
$MFAEnabledMembers = Import-Csv $MFAenabledMembersFile

# Compare and filter the data
$devicesOnboarded = $e5users | Where-Object { $MFAEnabledMembers.UserPrincipalName -contains $_.UserPrincipalName }
$needsOnboarded = $e5users | Where-Object { $MFAEnabledMembers.UserPrincipalName -notcontains $_.UserPrincipalName }


# Export the results to CSV
$devicesOnboarded | Export-Csv $inMFAGroupFile -NoTypeInformation
$needsOnboarded | Export-Csv $nonMFAGroupFile -NoTypeInformation

# SIG # Begin signature block#Script Signature# SIG # End signature block




