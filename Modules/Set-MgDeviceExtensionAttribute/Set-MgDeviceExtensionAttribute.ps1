function Set-MgDeviceExtensionAttribute {
    <#
    .SYNOPSIS
    Sets the extension attribute for a device in Microsoft Graph.
    .DESCRIPTION
    This function updates the extension attribute of a specified device in Microsoft Graph.
    It requires the device's display name, the extension attribute number (1-15), and the value to set for that attribute.
    .COMPONENT
    Microsoft Graph
    .PARAMETER devicename
    The display name of the device to update.
    .PARAMETER ExtensionAttributeNumber
    The number of the extension attribute to set. This should be a value between 1 and 15.
    .PARAMETER ExtensionAttributeValue
    The value to set for the specified extension attribute. This should be a string. Refer to Confluence for valid values.
    .PARAMETER PatchLevel
    The patch level to set for the device. This can be "Alpha", "Test", "Do not Patch", or "Upgrade".
    .EXAMPLE
    Set-MgDeviceExtensionAttribute -devicename "MyDevice" -PatchLevel "Beta"
    .NOTES
    This function requires the Microsoft Graph PowerShell SDK to be installed and configured.
    It also requires appropriate permissions to update device attributes in Microsoft Graph.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/set-mgdeviceextensionattribute
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/get-mgdevice
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/invoke-mggraphrequest
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devices/get-mgbetaDevice
    .OUTPUTS
    This function returns the response from the Microsoft Graph API after updating the device's extension attribute.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,Mandatory = $true)]
        [string]$Devicename,

        [Parameter(Position = 1,Mandatory = $true,ParameterSetName = "ExtensionAttributeValue")]
        [ValidateRange(1, 15)]
        [Int]$ExtensionAttributeNumber,

        [Parameter(Position = 2, Mandatory = $true,ParameterSetName = "ExtensionAttributeValue")]
        [string]$ExtensionAttributeValue,

        [Parameter(Position = 1, Mandatory = $true,ParameterSetName = "PatchLevel")]
        [ValidateSet("Alpha", "Test","Do not Patch","Upgrade")]
        [string]$PatchLevel
    )

$device =   Get-MgBetaDevice -search "DisplayName:$deviceName" -ConsistencyLevel eventual -Top 1
if (!($device)){
    Throw "Device with display name '$Devicename' not found."
}

$uri = "https://graph.microsoft.com/beta/devices/" , $device.id -join ""
if($PSBoundParameters.ContainsKey("PatchLevel")){
    switch ($PatchLevel){
        "Alpha" {$ExtensionAttributeValue = "Alpha"}
        "Test" {$ExtensionAttributeValue = "Test"}
        "Do not Patch" {$ExtensionAttributeValue = "Do not Patch"}
        "Upgrade" {$ExtensionAttributeValue = "Upgrade"}
    }
    $attributeNumber = "extensionAttribute14"
}
else {
    if ($ExtensionAttributeNumber -lt 10){
        $ExtensionAttributeNumber = "0" , $ExtensionAttributeNumber -join ""
    }
$attributeNumber = "extensionAttribute" , $ExtensionAttributeNumber -join ""
    if ($ExtensionAttributeValue -eq "Clear"){
        Write-Output "Clearing the value of $attributeNumber for device $Devicename"
        $ExtensionAttributeValue = $null
    }
    else {
        Write-Output "Setting $attributeNumber to '$ExtensionAttributeValue' for device $Devicename"
    }
    }
$json = @{
    "extensionAttributes" = @{
    "$attributeNumber" = "$ExtensionAttributeValue"
        }
} | ConvertTo-Json
  
$response = Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
return $response
}
SignatureBlock

