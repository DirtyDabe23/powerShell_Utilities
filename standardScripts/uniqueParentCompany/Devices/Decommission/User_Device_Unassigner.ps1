#This removes all the devices assigned to the user 
$userToRemove = Read-Host "Enter the UPN of the user who needs their devices removed"
$devices = Get-MGBetaUserOwnedDevice -UserId $userToRemove
If ($devices)
{
    ForEach ($device in $devices)
    {
        if ($device.AdditionalProperties['trustType'] -ne "Workplace")
        {
            $inTuneDeviceID = $device.ID
            $graphApiVersion = "beta"
            $Resource = "deviceManagement/managedDevices('$IntuneDeviceId')/users/`$ref"
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            Invoke-MgGraphRequest -Method GET $uri
        }
        else
        {
            Write-Output "$($device.additionalProperties['displayName']) is workplace joined and cannot be removed with this process"
        }
    }
}
Else{
    Write-Output "$userToRemove has no devices assigned!"
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



