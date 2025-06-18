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
        $listUri = "https://graph.microsoft.com/v1.0/sites/$($subSite.id)/lists"
        $listResponse = invoke-graphrequest -Uri $listUri -Method Get -ErrorAction SilentlyContinue
        $lists = $listResponse.value | ConvertTo-Json -Depth 10 | ConvertFrom-Json -Depth 10    

        # Collect Data for Lists with 'Workflow' in Name
        foreach ($list in $lists) {
            #if ($list.DisplayName -like "*Workflow*") {
                $script:trackingData += [PSCustomObject]@{
                    topLevelSiteDisplayName = $topLevelSiteDisplayName
                    topLevelSiteURL         = $topLevelSiteURL
                    subSiteDisplayName      = $subSite.DisplayName
                    subSiteURL              = $subSite.webURL
                    listDisplayName         = $list.DisplayName
                    listContentTypesEnabled = $list.list.contentTypesEnabled
                    listTemplate            = $list.list.template
                    listHidden              = $list.list.hidden          
                }
            #}
        }

        # Recursively Call Function for Nested Subsites
        Get-SubSites -siteId $subSite.id -topLevelSiteDisplayName $topLevelSiteDisplayName -topLevelSiteURL $topLevelSiteURL
    }
}

# Initialize Tracking Data
$trackingData = @()


# Connect to Microsoft Graph via Client Credentials Flow
$graphTenantId = $tenantIDString
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
$graphAppClientId = $appIDString
$graphRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText

# Construct Authentication Body
$graphAuthBody = @{
    client_id     = $graphAppClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $graphRetrSecret
    grant_type    = "client_credentials"
}

# Get Access Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing
$baseToken = ($tokenRequest.content | ConvertFrom-Json).access_token

# Set API Headers
$graphAPIHeader = @{
    "Authorization" = "Bearer $baseToken"
    "Content-Type"  = "application/json"
}


# Get Top-Level Site
$topLevelSite = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/root" -Method Get
$topLevelSiteDisplayName = $topLevelSite.DisplayName
$topLevelSiteURL = $topLevelSite.webURL

# Call Recursive Function
Get-SubSites -siteId "root" -topLevelSiteDisplayName $topLevelSiteDisplayName -topLevelSiteURL $topLevelSiteURL

# Output Tracking Data
$trackingData | Format-Table -AutoSize
# SIG # Begin signature block#Script Signature# SIG # End signature block







