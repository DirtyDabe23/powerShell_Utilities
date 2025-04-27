# Function to Get Subsites Recursively
function Get-SubSites {
    param (
        [string]$siteId,
        [string]$topLevelSiteDisplayName,
        [string]$topLevelSiteURL
    )

    # Fetch Subsites
    $subSites = @()
    $uri = "https://graph.microsoft.com/v1.0/sites/$siteId/sites"
    $response = invoke-graphrequest -Uri $uri -Method Get -ErrorAction Stop
    $subSites += $response.value

    # Pagination Handling
    while ($response.'@odata.nextLink') {
        $response = invoke-graphrequest -Uri $response.'@odata.nextLink' -Method Get
        $subSites += $response.value
    }

    # Process Each Subsite
    foreach ($subSite in $subSites) {
        # Fetch Lists from Subsite

                $script:trackingData += [PSCustomObject]@{
                    topLevelSiteDisplayName = $topLevelSiteDisplayName
                    topLevelSiteURL         = $topLevelSiteURL
                    subSiteDisplayName      = $subSite.DisplayName
                    subSiteURL              = $subSite.webURL      

        }

        # Recursively Call Function for Nested Subsites
        Get-SubSites -siteId $subSite.id -topLevelSiteDisplayName $topLevelSiteDisplayName -topLevelSiteURL $topLevelSiteURL
    }
}

# Initialize Tracking Data
$trackingData = @()


# Get Top-Level Site
$topLevelSite = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/root" -Method Get
$topLevelSiteDisplayName = $topLevelSite.DisplayName
$topLevelSiteURL = $topLevelSite.webURL

# Call Recursive Function
Get-SubSites -siteId "root" -topLevelSiteDisplayName $topLevelSiteDisplayName -topLevelSiteURL $topLevelSiteURL

# Output Tracking Data
$trackingData | Format-Table -AutoSize
# SIG # Begin signature block#Script Signature# SIG # End signature block



