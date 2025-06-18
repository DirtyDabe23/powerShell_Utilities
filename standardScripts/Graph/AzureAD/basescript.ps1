$csvpath = "ENTER CSV FILEPATH HERE\.csv"

# Import the CSV file
$csvData = Import-Csv $csvPath

# Iterate over each row in the CSV
foreach ($row in $csvData) {
    $upn = $row.UPN
    $password = $row.password
    
    # Convert the password to a secure string
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    
    # Reset the password using appropriate PowerShell cmdlet or method
    # Replace the following command with your actual password reset command
    Set-AzureADUserPassword -ObjectId $upn -Password $securePassword
    
  
    
    # Print a success message
    Write-Host "Password reset for UPN '$upn' completed."


Start-SPOCrossTenantUserContentMove  -SourceUserPrincipalName <...> -TargetUserPrincipalName <...> -TargetCrossTenantHostUrl
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



