$LADSelf = Get-ADUser "$userName" -Properties *
$LADMAnagerUser = $LADSelf.manager
$LADManager = $LADMAnagerUser.split(",")
$LADManager = $LADMAnager.split("=")
$LADManager = $LADMAnager[1]


$managerUserID = Get-MGUserManager -UserID "$userName@uniqueParentCompany.com"
$MGmanagerUser = Get-MGUser -UserId $managerUserID.Id
$MGManager = $MGmanagerUser.DisplayName
# SIG # Begin signature block#Script Signature# SIG # End signature block





