$coPilotUsers = import-csv -Path "C:\Temp\CoPilotUsers.csv"
$group = Get-MGBetaGroup -Filter "DisplayName eq 'Global: UC - CoPilot Users'"
$failedUser = @()
$failedGroup = @()
ForEach ($coPilotUser in $coPilotUsers.UPN){ 
    try{$user = Get-MGBetaUser -UserId $coPilotUser -ErrorAction Stop
    }
    catch{
        $failedUser += $coPilotUser
    }
    try{ 
    New-MGGroupMEmber -GroupId $($group.ID) -DirectoryObjectId $($user.id) -ErrorAction Stop
    }
    catch{
        $failedGroup += $coPilotUser
    }
}
SignatureBlock

