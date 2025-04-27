$allDevices = Get-MGDeviceManagementManagedDevice -All
$winDevices = $allDevices | Where-Object {($_.OperatingSystem -eq 'Windows')}

ForEach ($device in $winDevices)
{
    $user = $device.UserPrincipalName

    if (($user -eq "$null") -or ($user -eq ""))
    {
        $null
    }
    else
    {
        $userInfo = Get-MGBetaUser -userid $user
        $officeLocation = $userInfo.officeLocation
        $department = $userinfo.department
        $graphIDs = (Get-MGBetaDevice -search "DisplayName:$($device.deviceName)" -ConsistencyLevel eventual).id
        ForEach ($graphID in $graphIDs)
        {

            $uri = "https://graph.microsoft.com/beta/devices/" + $graphID

            $json = @{
                "extensionAttributes" = @{
                "extensionAttribute1" = "$officeLocation"
                "extensionAttribute2" = "$department"
                    }
            }

            $realJSON = $json | ConvertTo-Json

            Invoke-MgGraphRequest -Uri $uri -Body $realJSON -Method PATCH -ContentType "application/json"
        }



    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




