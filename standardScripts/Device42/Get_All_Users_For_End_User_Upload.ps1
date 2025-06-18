Connect-MGGraph -NoWelcome
$Users = Get-MGBetaUser -all -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "Member") -and ($_.AccountEnabled -eq $true)}
# Initialize an array to store user data
$userData = @()
# Loop through each user to retrieve their license information
foreach ($user in $Users) {
    $phone = $user.businessphones[0]
      $userData += [PSCustomObject]@{
        name              = $user.DisplayName
        email             = $user.mail
        contact           = $phone
        location          = $user.OfficeLocation
        notes             = $null
        groups            = $null
        fully_qualified_username      = $user.userprincipalname
        }
    }

# SIG # Begin signature block#Script Signature# SIG # End signature block



