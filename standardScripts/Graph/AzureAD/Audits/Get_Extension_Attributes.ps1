$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual 
$allRealUsers = $allAADUsers | where-object {($_.CompanyName -ne "Not Affiliated") -and ($_.UserType -eq "Member")}


$ExchangeAttrs = @()
ForEach ($user in $allRealUsers)
{
Try
    {
    Get-Mailbox -identity $user.UserPrincipalName -erroraction stop
    $Attr1 = (Get-Mailbox -identity $user.UserPrincipalName).customattribute1
    $userName = $user.UserPrincipalName
    $ExchangeAttrs += [PSCustomObject]@{
    UserName        = $userName
    CustomAttribute1       = $Attr1
    }
    }

Catch
    {
   $null
    }


   
}


# SIG # Begin signature block#Script Signature# SIG # End signature block




