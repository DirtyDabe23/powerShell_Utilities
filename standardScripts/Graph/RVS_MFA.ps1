$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual 
$officloc = Get-MGBetauser -UserId "dona.swarts@subsidiaryCompany1-shortNamecorp.com" | select officelocation
$allsubsidiaryCompany1-shortNameUsers = $allAADUsers | where-object {($_.OfficeLocation -eq $officloc.officelocation) -and ($_.CompanyName -ne "Not Affiliated")}
$gname = "MFA Enabled"

$groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID

 ForEach ($user in $allsubsidiaryCompany1-shortNameUsers)
 {
    $userID = (Get-MGBetaUser -userID $user.userprincipalname).ID
    $displayNAme = $user.displayName
    Write-Host "Adding $displayName to Group: MFA Enabled"
    New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userID 
}


SignatureBlock

