$password = Read-Host "Enter the Password" -MaskInput
#This pulls all the end users
$apiUrl = 'https://itam.uniqueParentCompany.com/api/1.0/endusers/'

# Convert the username and password to a Base64 string for Basic Authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$userName@uniqueParentCompany.com:$password")))

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

$device42EndUsers = (Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers).values


Connect-MGGraph -NoWelcome
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
    
    Invoke-RestMethod -method Post -uri $apiUrl -Headers $headers -body $body -SkipCertificateCheck
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





