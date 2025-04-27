$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual 
$officloc = Get-MGBetauser -UserId "dona.swarts@anonSubsidiary-1corp.com" | select officelocation
$allanonSubsidiary-1Users = $allAADUsers | where-object {($_.OfficeLocation -eq $officloc.officelocation) -and ($_.CompanyName -ne "Not Affiliated")}


$ExchangeAttrs = @()
ForEach ($user in $allanonSubsidiary-1Users)
{
Try
    {
    $Attr1 = (Get-Mailbox -identity $user.UserPrincipalName).customattribute1
    }
Catch
    {
    $Attr1 = $null
    }

$userName = $user.UserPrincipalName

 $ExchangeAttrs += [PSCustomObject]@{
    UserName        = $userName
    CustomAttribute1       = $Attr1

    }   
}


# SIG # Begin signature block#Script Signature# SIG # End signature block




