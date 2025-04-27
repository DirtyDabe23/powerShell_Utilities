# Connect to AzureAD
Connect-AzureAD

# Import CSV file
$users = Import-Csv "C:\Path\To\CSV\File.csv"

# Loop through each user in the CSV
foreach ($user in $users) {
    # Set the suffix based on the location name
    switch ($user.Location) {
        "Taneytown" { $suffix = "@uniqueParentCompany.com" }
        "Madera" { $suffix = "@uniqueParentCompanywest.com" }
        "Greenup" { $suffix = "@uniqueParentCompanymw.com" }
        "Iowa" { $suffix = "@uniqueParentCompanyia.com" }
        "Texas" { $suffix = "@anonSubsidiary-1corp.com" }
        "Tongeren" { $suffix = "@uniqueParentCompany.be" }
        "Beijing" { $suffix = "@uniqueParentCompanychina.com" }
        "Shanghai" { $suffix = "@uniqueParentCompanychina.com" }
        "Australia" { $suffix = "@uniqueParentCompany.com.au" }
        "uniqueParentCompany Dry Cooling" { $suffix = "@uniqueParentCompany-blct.com" }
        "Tower Components" { $suffix = "@towercomponentsinc.com" }
        "anonSubsidiary-1" { $suffix = "@uniqueParentCompanymw.com" }
        "Denmark" { $suffix = "@uniqueParentCompany.de" }
        "uniqueParentCompany-Brasil" { $suffix = "@uniqueParentCompany.com.br" }
        "unique-Office-Location-16" { $suffix = "@anonSubsidiary-1.com" }
        "Minnesota" { $suffix = "@uniqueParentCompanymn.com" }
        "unique-Company-Name-11" { $suffix = "@lmpinc.ca" }
        "unique-Office-Location-21" { $suffix = "@uniqueParentCompanyselect.com" }
        default { Write-Warning "Invalid location: $($user.Location)"; continue }
    }
    
    # Create the username in the format of firstname.lastname
    $username = $user.FirstName + "." + $user.LastName
    
    # Create the user account with
# SIG # Begin signature block#Script Signature# SIG # End signature block










