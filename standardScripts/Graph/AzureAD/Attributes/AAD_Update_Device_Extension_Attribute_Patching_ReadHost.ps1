$devicename = Read-Host "Enter the display name of the device"

$PatchLevel = Read-Host "Select the Patching level `n1) Alpha`n2) Beta `n3) Standard `n4) Upgrade `n5) Do not Patch"

switch ($PatchLevel) {
    "1" {$extAttr14Value = "Alpha"}
    "2" {$extAttr14Value = "Beta"}
    "3" {$extAttr14Value = $null}
    "4" {$extAttr14Value = "Upgrade"}
    "5" {$extAttr14Value = "Do Not Patch"}
    Default {$null}
}


$device = Get-MGBetaDevice -All -ConsistencyLevel eventual | Where-Object {$_.DisplayName -eq $devicename}

if ($device.Count -ge 2)
{
    $device = ($device | sort registrationdatetime -Descending)[0]
}

$uri = "https://graph.microsoft.com/beta/devices/" + $device.id


$json = @{
    "extensionAttributes" = @{
    "extensionAttribute14" = "$extAttr14Value"
        }
} | ConvertTo-Json

  
Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
# SIG # Begin signature block#Script Signature# SIG # End signature block




