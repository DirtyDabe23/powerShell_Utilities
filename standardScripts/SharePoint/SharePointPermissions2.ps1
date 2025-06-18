 Connect to M365 tenant
Connect-MicrosoftTeams

# Get all SharePoint sites from M365
$sites = Get-SPOSite -Limit All | Where-Object {$_.Template -eq "STS#0"}

# Initialize array to hold user permissions
$userPermissions = @()

# Loop through all SharePoint sites
foreach ($site in $sites) {
    Write-Host "Processing site $($site.Url)" -ForegroundColor Green

    # Get all users with access to the site
    $users = Get-SPOUser -Site $site.Url

    # Loop through all users and get their permissions
    foreach ($user in $users) {
        $permissions = Get-SPOUserEffectivePermissions -Site $site.Url -User $user.LoginName

        # Add user permissions to the array
        $userPermissions += New-Object PSObject -Property @{
            SiteUrl = $site.Url
            User = $user.LoginName
            Permissions = ($permissions | Select-Object -ExpandProperty Permissions)
        }
    }
}

# Export user permissions to a CSV file
$userPermissions | Export-Csv -Path "UserPermissions.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block



