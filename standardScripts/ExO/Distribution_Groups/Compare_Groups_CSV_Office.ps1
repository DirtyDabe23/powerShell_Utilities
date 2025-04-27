# Define the paths to the CSV files
$staticCsvPath = "C:\Temp\TT_Office.csv"
$dynamicCsvPath = "C:\Temp\TT_Office_Dynamic.csv"
$missingCsvPath = "C:\Temp\TT_Office_Missing.csv"

# Import the CSV files
$staticData = Import-Csv $staticCsvPath
$dynamicData = Import-Csv $dynamicCsvPath

# Initialize an empty array to store the missing users
$missingUsers = @()

# Iterate through each user in the static CSV
foreach ($user in $staticData) {
    $primarySMTPAddress = $user.PrimarySMTPAddress

    # Check if the PrimarySMTPAddress exists in the dynamic CSV
    $matchingUser = $dynamicData | Where-Object { $_.UserPrincipalName -eq $primarySMTPAddress }

    # If no matching user is found, add it to the missing users array
    if (!$matchingUser) {
        $missingUsers += $user
    }
}

# Export the missing users to a new CSV
$missingUsers | Export-Csv -Path $missingCsvPath -NoTypeInformation

# Output the result
Write-Host "Comparison complete. Missing users exported to $missingCsvPath."
# SIG # Begin signature block#Script Signature# SIG # End signature block



