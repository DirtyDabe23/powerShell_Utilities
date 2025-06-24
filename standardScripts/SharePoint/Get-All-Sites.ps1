# Connect to SharePoint Online
Connect-SPOService -url https://parentCompanyinc-admin.sharepoint.com

# Get all SharePoint sites
$sites = Get-SPOSite -Limit All

# Loop through all sites and display their URLs
foreach ($site in $sites) {
    Write-Host "Site URL: $($site.Url)"
    #Get-SpoUser -Site $site 
}
SignatureBlock

