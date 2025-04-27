$groups = @()
$groups += (Get-MGBetaGroup -Search "DisplayName:Global: CC - Beta Test User Devices" -ConsistencyLevel: eventual).ID
$groups += (Get-MGBetaGroup -Search "DisplayName:Global: CC - Alpha Test User Devices" -ConsistencyLevel: eventual).ID
$groups = (Get-MGBetaGroup -search "DisplayName:Windows Updates Disabled" -ConsistencyLevel: eventual).id

ForEach ($group in $groups)
{
    switch ($group) {
        "7b8eb4df-8989-497e-a7cd-b064d31dc09e" {$extAttr14Value = "Beta"}
        "701f96f8-cda4-4e69-8c94-fbec7c96b11b" {$extAttr14Value = "Alpha"}
        "fbc2a1e8-30f6-4ce1-918b-d59418dea392" {$extAttr14Value = "Do Not Patch"}
        Default {$null}
    }
    #Alpha Users
    $Devices = Get-MGBetaGroupMember -GroupId $group 

    ForEach ($device in $devices)
    {

    $uri = "https://graph.microsoft.com/beta/devices/" + $device.id

    $json = @{
        "extensionAttributes" = @{
        "extensionAttribute14" = "$extAttr14Value"
            }
    } | ConvertTo-Json
    
    Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




