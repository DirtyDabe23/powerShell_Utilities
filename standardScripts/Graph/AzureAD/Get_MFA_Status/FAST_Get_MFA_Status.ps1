# Modify the UPN Suffix for the location that will be queried
$upnSuffix = '@anonSubsidiary-1corp.com'

# Define secrets
$tenantId = '9e228334-bae6-4c7e-8b7f-9b0824082151'
$clientId = '56cb7f72-67ee-4531-96d7-39a4e2b53555'
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
}

$userList = @()

while ($userRequestURL) {
    $response = Invoke-WebRequest -Uri $userRequestURL -Headers $userRequestHeaders
    $data = ConvertFrom-Json $response
    $userList += $data.value
    
    try {
        $userRequestURL = $data.'@odata.nextLink'
    } catch {
        $userRequestURL = $null
    }
}

$MFAList = @()

$MFARequestUrl = "https://graph.microsoft.com/v1.0/reports/authenticationMethods/userRegistrationDetails?`$select=isMfaRegistered,userPrincipalName"
$MFARequestHeaders = @{
    Authorization = $tokenObj.access_token
}

while ($MFARequestUrl) {
    $MFAresponse = Invoke-WebRequest -Uri $MFARequestURL -Headers $MFARequestHeaders
    $MFAdata = ConvertFrom-Json $MFAresponse
    $MFAList += $MFAdata.value
    
    try {
        $MFARequestURL = $MFAdata.'@odata.nextLink'
    } catch {
        $MFARequestURL = $null
    }
}

# Iterate over user objects
$userData = @()

foreach ($user in $userList) {
    if ($user.signInActivity) {
        $lastSignIn = $user.signInActivity.lastSignInDateTime
    } else {
        $lastSignIn = $null
    }

    $MFAUserData = $MFAList | where-object {$_.UserPrincipalName -eq $user.UserPrincipalName}
    
    $userAdd = [PSCustomObject]@{
        DisplayName = $user.displayName
        UserPrincipalName = $user.userPrincipalName
        LastLogin = $lastSignIn
        MFARegistered = $MFAUserData.isMfaRegistered
    }
    
    $userData += $userAdd
}

# Convert and Output to CSV

$userData | Export-Csv "C:\Temp\anonSubsidiary-1_last_login_MFA.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block





