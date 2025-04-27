Connect-AzAccount -Identity | Out-Null
Connect-MgGraph -Identity -NoWelcome | Out-Null
Import-Module -Name Microsoft.Graph.DeviceManagement
Import-Module -Name Microsoft.Graph.Beta.Identity.DirectoryManagement
$allDevices = Get-MGDeviceManagementManagedDevice -All
$winDevices = $allDevices | Where-Object {($_.OperatingSystem -eq 'Windows')}
$counter = 1 
$total = $winDevices.Count 
ForEach ($device in $winDevices)
{
    $now = Get-Date -Format HH:mm
    Write-Output "[$now]: Device $counter out of $total"
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
    $counter++
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



