$psDrives = Get-PSDrive
If ($psDrives.Name -notcontains 'HKU')
{
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
}
Set-Location HKU:\
$users = Get-ChildItem -Path .\
$userKeys = $users.name
$userSids = @()
ForEach ($userKey in $userKeys) { $userSids += $userKey.Split("\")[1]}

$userData = @()

$userSIDS = $userSIDS | Where-Object {($_ -ne ".Default") -and ($_ -ne "S-1-5-18")  -and ($_ -ne "S-1-5-19") -and ($_ -ne "S-1-5-20") -and ($_ -notlike "*_Classes")}
ForEach ($userSID in $userSids)
{
    $SID = New-Object System.Security.Principal.SecurityIdentifier("$userSID”)
    $User = $SID.Translate([System.Security.Principal.NTAccount])
    $userData += [PSCustomObject]@{
        UserName    = $User.Value
        UserSID     = $SID.Value
    }
    
}

Write-Output $userData

ForEach ($sid in $userdata.UserSID)
{
    Set-Location ".\$sid"
    $loc = get-location
    Write-Output "I am currently at $($loc.path)"
    cd ..
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




