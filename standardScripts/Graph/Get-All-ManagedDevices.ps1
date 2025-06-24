$tracking = @()
$response = Invoke-MgGraphRequest -method GET -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices" | ConvertTo-JSON -Depth 10 | ConvertFrom-Json -Depth 10
$tracking += $response.value
if ($response.'@odata.nextLink'){
    while ($response.'@odata.nextLink'){
        $uri      = $response.'@odata.nextLink'
        $response = Invoke-MgGraphRequest -method GET -uri $uri  | ConvertTo-JSON -Depth 10 | ConvertFrom-Json -Depth 10
        $tracking += $response.Value
    }
}
return $tracking 

SignatureBlock

