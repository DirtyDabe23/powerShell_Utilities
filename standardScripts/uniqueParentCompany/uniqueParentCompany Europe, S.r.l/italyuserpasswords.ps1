$csvPath = "C:\Users\$userName\Documents\_Project\Italy_OneDrive\Users.csv"

# Check if the CSV file exists
if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file does not exist."
    exit
}

# Import the CSV file
$csvData = Import-Csv $csvPath

$TURL = "https://uniqueParentCompanyeurope-my.sharepoint.com/"

# Iterate over each row in the CSV
foreach ($row in $csvData) 
{
    #variable binding
    #Source UPN
    $SUPN = $row.SourceUserUPN
    
    #target UPN
    $TUPN = $row.TargetUserUPN

    #target URL
    

    Start-SPOCrossTenantUserContentMove  -SourceUserPrincipalName $SUPN -TargetUserPrincipalName $TUPN -TargetCrossTenantHostUrl $TURL
    Write-Host "One Drive Migration for '$upn' started."
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





