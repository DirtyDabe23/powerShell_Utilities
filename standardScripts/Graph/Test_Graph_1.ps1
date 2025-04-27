#The Graph API URL
$uri = "https://graph.microsoft.com/v1.0/users Jump "
 
$method = "GET"
 
# Run the Graph API query to retrieve users
$output = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
# SIG # Begin signature block#Script Signature# SIG # End signature block




