$devicename = Read-Host "Enter the display name of the device"

$device = Get-MGBetaDevice -All -ConsistencyLevel eventual | Where-Object {$_.DisplayName -eq $devicename}

if ($device.Count -ge 2)
{
    $device = ($device | sort registrationdatetime -Descending)[0]
}

$uri = "https://graph.microsoft.com/beta/devices/" + $device.id

$json = @{
      "extensionAttributes" = @{
      "extensionAttribute1" = "unique-Office-Location-0"
         }
  } | ConvertTo-Json
  
Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"


 
# SIG # Begin signature block#Script Signature# SIG # End signature block





