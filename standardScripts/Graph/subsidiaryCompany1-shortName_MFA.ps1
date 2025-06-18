$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual 
$officloc = Get-MGBetauser -UserId "dona.swarts@anonSubsidiary-1corp.com" | select officelocation
$allanonSubsidiary-1Users = $allAADUsers | where-object {($_.OfficeLocation -eq $officloc.officelocation) -and ($_.CompanyName -ne "Not Affiliated")}
$gname = "MFA Enabled"

$groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID

 ForEach ($user in $allanonSubsidiary-1Users)
 {
    $userID = (Get-MGBetaUser -userID $user.userprincipalname).ID
    $displayNAme = $user.displayName
    Write-Host "Adding $displayName to Group: MFA Enabled"
    New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userID 
}


# SIG # Begin signature block#Script Signature# SIG # End signature block




