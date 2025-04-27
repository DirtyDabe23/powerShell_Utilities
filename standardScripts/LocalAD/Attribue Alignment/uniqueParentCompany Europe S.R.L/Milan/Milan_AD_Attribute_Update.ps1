$users = Import-CSV -Path C:\Temp\MilanUsers.csv

ForEach ($user in $users)
{
    If ($user.Manager -eq "")
    {
    $null
    }
    else
    {
        $Manager = Get-ADUser -filter "CN -eq '$($user.Manager)'"
        Set-ADUser -identity $user.ObjectGUID -Manager $manager -whatif
    }
    
    Set-ADUser -identity $user.ObjectGUID -Company $user.company -Office $user.office -OfficePhone $user.OfficePhone -Department $user.Department -Title $user.title -whatif 
    $extAttr1 = $user.ExtensionAttribute

    If ($extAttr1 -eq "")
    {
    $null
    }
    else 
    {
        set-aduser -identity $user.ObjectGUID -add @{"extensionAttribute1"=$extAttr1} -WhatIf  
    }

    $manager = $null
    $extAttr1 = $null 
    
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



