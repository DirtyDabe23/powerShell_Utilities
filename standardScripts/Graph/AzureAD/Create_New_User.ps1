# Connect to AzureAD
Connect-AzureAD

# Import CSV file
$users = Import-Csv "C:\Path\To\CSV\File.csv"

# Loop through each user in the CSV
foreach ($user in $users) {
    # Set the suffix based on the location name
    switch ($user.Location) {
        "Location" { $suffix = "@Domain.extension1" }
        "Madera" { $suffix = "@parentCompanywest.com" }
        "Location3" { $suffix = "@parentCompanymw.com" }
        "Iowa" { $suffix = "@parentCompanyia.com" }
        "Texas" { $suffix = "@subsidiaryCompany1-shortNamecorp.com" }
        "Tongeren" { $suffix = "@parentCompany.be" }
        "Beijing" { $suffix = "@parentCompanychina.com" }
        "Shanghai" { $suffix = "@parentCompanychina.com" }
        "Australia" { $suffix = "@Domain.extension1.au" }
        "parentCompany Dry Cooling" { $suffix = "@parentCompany-blct.com" }
        "Tower Components" { $suffix = "@Domain.extension2" }
        "Newton" { $suffix = "@parentCompanymw.com" }
        "Denmark" { $suffix = "@Domain.Extension10" }
        "parentCompany-Brasil" { $suffix = "@Domain.extension1.br" }
        "subsidiaryCompany3" { $suffix = "@Domain.extension3" }
        "Minnesota" { $suffix = "@Domain.extension7" }
        "parentCompany LMP" { $suffix = "@lmpinc.ca" }
        "parentCompany Select Tech" { $suffix = "@Domain.Extension9" }
        default { Write-Warning "Invalid location: $($user.Location)"; continue }
    }
    
    # Create the username in the format of firstname.lastname
    $username = $user.FirstName + "." + $user.LastName
    
    # Create the user account with
SignatureBlock

