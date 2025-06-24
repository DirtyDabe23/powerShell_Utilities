$LADSelf = Get-ADUser "david.drosdick" -Properties *
$LADMAnagerUser = $LADSelf.manager
$LADManager = $LADMAnagerUser.split(",")
$LADManager = $LADMAnager.split("=")
$LADManager = $LADMAnager[1]


$managerUserID = Get-MGUserManager -UserID "david.drosdick@Domain.extension1"
$MGmanagerUser = Get-MGUser -UserId $managerUserID.Id
$MGManager = $MGmanagerUser.DisplayName
SignatureBlock

