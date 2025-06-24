$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual 
$officloc = Get-MGBetauser -UserId "dona.swarts@subsidiaryCompany1-shortNamecorp.com" | select officelocation
$allsubsidiaryCompany1-shortNameUsers = $allAADUsers | where-object {($_.OfficeLocation -eq $officloc.officelocation) -and ($_.CompanyName -ne "Not Affiliated")}


$ExchangeAttrs = @()
ForEach ($user in $allsubsidiaryCompany1-shortNameUsers)
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


SignatureBlock

