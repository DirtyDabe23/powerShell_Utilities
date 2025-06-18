# Connect to Azure AD
Connect-AzureAD

# Get all users
$users = Get-AzureADUser -All $true

# Loop through each user
foreach ($user in $users) {

    # Check if first name, last name, and email address are entered
    if ($user.GivenName -ne $null -and $user.Surname -ne $null -and $user.Mail -ne $null) {
        
        # Check if email address is complteamMembert
        $emailParts = $user.Mail.Split('@')
        if ($emailParts[0] -ne ($user.GivenName + '.' + $user.Surname)) {
            
            # Generate new email address
            $newEmail = ($user.GivenName + '.' + $user.Surname + '@example.com')
            
            # Modify email address
            Set-AzureADUser -ObjectId $user.ObjectId -Mail $newEmail
            
            # Set current email address as an alias
            $alias = New-Object -TypeName Microsoft.Open.AzureAD.Model.ObjectIdentity
            $alias.SignInType = 'emailAddress'
            $alias.Value = $user.Mail
            Add-AzureADUserExtension -ObjectId $user.ObjectId -ExtensionName 'AlternateEmailAddresses' -ExtensionValue $alias
        }
    }
}

# Disconnect from Azure AD
Disconnect-AzureAD

# SIG # Begin signature block#Script Signature# SIG # End signature block




