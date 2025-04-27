# Connect to M365 tenant
Connect-MsolService

Connect-SPOService -Url "https://uniqueParentCompanyinc.sharepoint.com/" -credential $(Get-Credential)

# Get all SharePoint sites from M365
$sites = Get-SPOSite -Limit All

# Loop through all sites
foreach ($site in $sites) {

    # Get all users with access to site
    $users = Get-SPOUser -Site $site.Url

    # Loop through all users
    foreach ($user in $users) {

        # Get user permissions
        $permissions = Get-SPOUserEffectivePermissions -Site $site.Url -User $user.LoginName

        # Create an object with user information and permissions
        $output = New-Object PSObject -Property @{
            Site = $site.Url
            User = $user.LoginName
            Permissions = $permissions.RoleDefinitions
        }

        # Print output to CSV
        $output | Export-Csv -Path "Permissions.csv" -Append -NoTypeInformation
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




