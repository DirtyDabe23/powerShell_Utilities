# Set the values for Group Email and Group Display Name
$addr
$dispName 

# Specify the path to the CSV file
$csvPath = "C:\Temp\Taneytown Shop Distro.csv"

# Import the CSV file
$data = Import-Csv -Path $csvPath

# Add the "Group Email" and "Group Display Name" columns with specified values
$data | Add-Member -MemberType NoteProperty -Name "Group Email" -Value $addr
$data | Add-Member -MemberType NoteProperty -Name "Group Display Name" -Value $dispName

# Export the modified data back to CSV
$data | Export-Csv -Path $csvPath -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block




