#DDrosdick Device42 Password
$password = Read-Host -Prompt "Enter your device42 password" -MaskInput

#This pulls all the end users
$apiUrl = 'https://itam.uniqueParentCompany.com/api/1.0/endusers/'

# Convert the username and password to a Base64 string for Basic Authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$userName@uniqueParentCompany.com:$password")))

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

$device42EndUsers = (Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers).values

# Output the response
$device42EndUsers

#The following below are the requirements for updatin the users.

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type"  = "application/x-www-form-urlencoded"
    "Accept"        = "application/json"
}


$body = "id=1&name=David%20Drosdick&email=$userName%40uniqueParentCompany.com&contact=4107562600&location=uniqueParentCompany%20East&create_new=false"


Invoke-RestMethod -method Post -uri $apiUrl -Headers $headers -body $body -SkipCertificateCheck


$body = "id=1&name=David%20Drosdick&email=$userName%40uniqueParentCompany.com&contact=4107562600&location=uniqueParentCompany%20East&create_new=false"

#Sample Body

"name=David%20Drosdick&
email=$userName%40uniqueParentCompany.com&
contact=4107562600&
location=uniqueParentCompany%20East&
create_new=false
"

$name = "name=$($user.name.replace(" ","%20"))&"
$email =  "email=$($user.email.replace("@","%40"))&"
$contact = "contact=$($user.contact)&"
$location = "location=$($user.location.replace(" ","%20"))&"
$createNew = "create_new=false"

$body = $name+$email+$contact+$location+$createNew

$badUsers = ($Device42EndUsers | Where-Object {($_.ID -ge '4079')}).id
ForEach ($id in $badUsers)
{

#delete End Users
$apiUrl = "https://itam.uniqueParentCompany.com/api/1.0/endusers/$ID/"

# Convert the username and password to a Base64 string for Basic Authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$userName@uniqueParentCompany.com:$password")))

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri $apiUrl -Method Delete -Headers $headers
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





