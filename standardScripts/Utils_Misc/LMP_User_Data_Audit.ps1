$lmpUserData = [PSCustomOBject] @()
$allLMPUsersBase = Get-MGBetaUser -all -consistencyLevel Eventual -property * | Where-Object {($_.OfficeLocation -eq 'unique-Company-Name-11')} | Sort-Object surname | Select-Object GivenName, SurName, Mail , CompanyName , OfficeLocation , Department , UserPrincipalName , ID 
ForEach ($user in $allLMPUsersBase){
    $manager = Get-MGUSer -userid $user.ID -Property Manager -ExpandProperty Manager | Select-Object Manager -ExpandProperty Manager 
    if (($manager.id -ne '') -and ($null -ne $manager.ID)){
    $managerUser = Get-MGUser -userid $manager.ID
    $lmpUserData+=[PSCustomObject]@{
        GivenName           =   $user.GivenName
        SurName             =   $user.Surname
        Email               =   $user.mail
        CompanyName         =   $user.CompanyName
        OfficeLocation      =   $user.OfficeLocation
        Department          =   $user.Department
        UserPrincipalName   =   $user.UserPrincipalName
        Manager             =   $managerUser.DisplayName 
        }
    }
    else{
            $lmpUserData+= [PSCustomObject]@{
                GivenName           =   $user.GivenName
                SurName             =   $user.Surname
                Email               =   $user.mail
                CompanyName         =   $user.CompanyName
                OfficeLocation      =   $user.OfficeLocation
                Department          =   $user.Department
                UserPrincipalName   =   $user.UserPrincipalName
                Manager             =   "No Manager" 
        }
    }
}
$lmpUserData | Format-Table
# SIG # Begin signature block#Script Signature# SIG # End signature block




