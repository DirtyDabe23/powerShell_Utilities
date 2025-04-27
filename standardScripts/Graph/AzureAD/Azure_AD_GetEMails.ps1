# Import required modules
Install-Module Microsoft.Graph.Authentication -Force
Install-Module Microsoft.Graph -Force

# Authenticate using a device code
Connect-MgGraph -Scopes "User.Read.All"

# Get all user objects from M365
$users = Get-MgUser -All $true

# Filter out users whose email address doesn't follow the format of firstname.lastname
$filteredUsers = $users | Where-Object { $_.Mail -notmatch "^([a-zA-Z]+\.[a-zA-Z]+)@\w+" }

# Output the email addresses of the filtered users
$filteredUsers | Select-Object -ExpandProperty Mail
# SIG # Begin signature block#Script Signature# SIG # End signature block



