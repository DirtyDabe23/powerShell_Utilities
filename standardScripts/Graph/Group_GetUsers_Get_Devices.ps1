Clear-Host
connect-MgGraph -NoWelcome
$groupName = Read-Host "Enter the group name"
$group = Get-MgGroup -Search "DisplayName:$groupName" -ConsistencyLevel:eventual
$members = Get-MgGroupMember -GroupId $group.id -All -ConsistencyLevel eventual
$userAndDevice = @()

ForEach ($member in $members)
{
    if ($member.additionalproperties.'@odata.type')
    {
        $user = Get-MGBEtaUser -UserId $member.ID | Select-Object -Property userprincipalname , CompanyName , OfficeLocation , Department , ID
        $devices = Get-MgUserOwnedDevice -userid $user.ID
        ForEach ($device in $devices)
        {
            $deviceDetail = Get-MGBetaDevice -DeviceId $device.id | select *
            If ($deviceDetail.OperatingSystem -eq "Windows")
            {
                $UserandDevice +=[PSCustomObject]@{
                    primaryUserID = $user.ID 
                    primaryUser = $user.UserPrincipalName
                    primaryUserCompany = $user.CompanyName
                    primaryUserOffice = $user.OfficeLocation
                    primaryUserDepartment = $user.Department
                    deviceHostname        = $deviceDetail.DisplayName
                    deviceTrust           = $deviceDetail.TrustType
                    deviceID              = $deviceDetail.Id
                    deviceApproxLastSeen  = $deviceDetail.ApproximateLastSignInDateTime
                    deviceModel           = $deviceDetail.Model
                    deviceOSVersion       = $deviceDetail.OperatingSystemVersion
                }

            }

        } 
    }
}

Write-Output $UserandDevice | Format-Table
# SIG # Begin signature block#Script Signature# SIG # End signature block



