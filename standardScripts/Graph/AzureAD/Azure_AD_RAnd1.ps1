# Define the network share path
$sharePath = "\\server\share" # Get all files and folders in the network share
$items = Get-ChildItem -Path $sharePath -Recurse -Depth "2" # Loop through each item and get its ACL
$acls = @()
foreach ($item in $items) {
    $acl = Get-Acl -Path $item.FullName
    $acls += $acl
} # Export the ACLs to a CSV file
$acls | Export-Csv -Path "C:\Temp\ACL.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block



