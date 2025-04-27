# Load SharePoint PowerShell snap-in
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

# Set output CSV file path
$outputFile = "C:\Permissions.csv"

# Create an empty array to hold the results
$results = @()

# Get all SharePoint sites
$sites = Get-SPSite -Limit All

# Loop through each site
foreach ($site in $sites) {

    # Get all users with access to the site
    $users = $site.RootWeb.SiteUsers

    # Loop through each user
    foreach ($user in $users) {

        # Get the user's permissions on the site
        $permissionLevel = $site.RootWeb.GetUserEffectivePermissionInfo($user.LoginName).RoleAssignments | 
                           Select-Object -ExpandProperty MemberRoleAssignments | 
                           Select-Object -ExpandProperty RoleDefinitionBindings | 
                           Select-Object -ExpandProperty Name -Unique
        
        # Create a new object to store the results
        $result = New-Object -TypeName PSObject
        $result | Add-Member -MemberType NoteProperty -Name "Site URL" -Value $site.Url
        $result | Add-Member -MemberType NoteProperty -Name "User" -Value $user.Name
        $result | Add-Member -MemberType NoteProperty -Name "Permissions" -Value ($permissionLevel -join ", ")
        
        # Add the result to the array
        $results += $result
    }
}

# Export the results to a CSV file
$results | Export-Csv $outputFile -NoTypeInformation

# Dispose SharePoint PowerShell snap-in
Remove-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

# SIG # Begin signature block#Script Signature# SIG # End signature block



