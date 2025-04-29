# Modify the UPN Suffix for the location that will be queried
$upnSuffix = '@uniqueParentCompany.com'

# Define secrets
$tenantId = 'graphTenantID'
$clientId = 'graphAppID'
$clientSecret = 'GraphAPI'

$authority = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token' -f $tenantId

# Request a token
$tokenHeader = @{'Content-Type' = 'application/x-www-form-urlencoded' }

$tokenBody = @{
    client_id = $clientId
    scope = 'https://graph.microsoft.com/.default'
    client_secret = $clientSecret
    grant_type = 'client_credentials'
}

$token = Invoke-WebRequest -Method 'POST' -Uri $authority -Headers $tokenHeader -Body $tokenBody
$tokenObj = ConvertFrom-Json $token

# Prepare the request
$userRequestURL = "https://graph.microsoft.com/v1.0/users?`$top=999&`$count=true&ConsistencyLevel=eventual&`$select=signInActivity&`$filter=endsWith(userPrincipalName,'{0}')" -f $upnSuffix
$userRequestHeaders = @{
    Authorization = $tokenObj.access_token
    'Content-type' = 'application/json'
}

$userList = @()

while ($userRequestURL -ne $null) {
    $response = Invoke-WebRequest -Uri $userRequestURL -Headers $userRequestHeaders
    $data = ConvertFrom-Json $response
    $userList += $data.value
    
    try {
        $userRequestURL = $data.'@odata.nextLink'
    } catch {
    $userRequestURL = None
    }
}

# Iterate over user objects
$userData = @()

foreach ($user in $userList) {
    if ($user.signInActivity) {
        $signIn = $user.signInActivity.lastSignInDateTime
    } else {
        $signIn = $null
    }
    
    $useradd = [PSCustomObject]@{
        DisplayName = $user.displayName
        UserPrincipalName = $user.userPrincipalName
        LastLogin = $signIn
    }
    
    $userData += $useradd
}

# Convert and Output to CSV

$userData | Export-Csv "C:\Temp\last_login.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block






