$users = Get-ADUser -Filter *
# Loop through each user and remove their mobile phone number
foreach ($user in $users) {
    Set-ADUser -Identity $user.ObjectGUID -MobilePhone $null -whatif
}


SignatureBlock

