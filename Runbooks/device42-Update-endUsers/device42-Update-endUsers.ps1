$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
Import-module Az.Accounts
Import-Module Az.KeyVault
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-AzAccount -subscription 'azSubsription' -Identity

$d42retrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -name 'Device42Api' -AsPlainText


#This pulls all the end users
$apiUrl = 'https://itam.Domain.extension1/api/1.0/endusers/'

# Convert the username and password to a Base64 string for Basic Authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("GIT_API:$d42retrSecret")))

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

$device42EndUsers = (Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers).values

#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId = "graphTenantID"

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$graphAppClientId = "graphAppID"

$graphRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "GraphAPIKey" -AsPlainText

# Construct the body to be used in Invoke-WebRequest
$graphAuthBody = @{
    client_id     = $graphAppClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret =  $graphRetrSecret
    grant_type    = "client_credentials"
}

# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
Write-Output "Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop

$Users = Get-MGBetaUser -all -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "Member") -and ($_.AccountEnabled -eq $true)}
# Initialize an array to store user data
$graphUserData = @()
# Loop through each user to retrieve their license information
foreach ($user in $Users) {
    $phone = $user.businessphones[0]
      $graphUserData += [PSCustomObject]@{
        name              = $user.DisplayName
        email             = $user.UserPrincipalName
        contact           = $phone
        location          = $user.OfficeLocation
        adusername        = $user.OnPremisesUserPrincipalName
        notes             = $null
        groups            = $null
        }
    }



#The following below are the requirements for updatin the users.

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type"  = "application/x-www-form-urlencoded"
    "Accept"        = "application/json"
}

[array] $existingUsers = $null
[array] $nonExistingUsers = $null
ForEach ($user in $graphUserData)
{

    $name = "name=$($user.name.replace(" ","%20"))&"
    $email =  "email=$($user.email.replace("@","%40"))&"
    $contact = "contact=$($user.contact)&"
    If($User.location -ne '' -and $user.location -ne ' ' -and $null -ne $user.location)
    {
        $location = "location=$($user.location.replace(" ","%20"))&"
    }
    Else
    {
        $location = $null
    }
    #Block to create new user
    If ($user.name -notin $device42endusers.Name)
    {
        Write-Output "$($user.name) does not exist in Device42"
        $nonExistingUsers += $user.name
        #user will need created here
        $createNew = "create_new=true"
        $body = $name+$email+$contact+$location+$createNew
    }
    else 
    {
        Write-Output "$($user.name) exists in Device42"
        $existingUsers += $user.name
        #user will need updated in Device42
        $device42ID= ($device42EndUsers | Where-Object {($_.Name -eq $($user.name))}).id
        $createNew = "create_new=false"
        $id = "id=$($device42ID)&"
        $body = $id+$name+$email+$contact+$location+$createNew
    }
    
    Invoke-RestMethod -method Post -uri $apiUrl -Headers $headers -body $body | Out-Null
}
SignatureBlock

