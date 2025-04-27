function Remove-uniqueParentCompanyDeviceAssignment{
    <#
    .SYNOPSIS
    This script removes the user as the primary user of the device.
    
    .DESCRIPTION
    This script removes the user as the primary user of the device by their UserPrincipalName
    It does not remove Entra Enrolled Devices
    
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the Primary User to remove from Devices.
    
    .EXAMPLE
    Remove-uniqueParentCompanyDeviceAssignment -UserPrincipalName "TestFirst.TestLast@uniqueParentCompany.com"
    
    .NOTES
    You need to start with Connect-MgGraph, and then you will need to have the permissions required. 
    #>
    [CmdletBinding()] 
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the User Principal Name for the Device to Remove",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$UserPrincipalName
    )
    #This removes all the devices assigned to the user
    try{ 
    $devices = Get-MGBetaUserOwnedDevice -UserId $UserPrincipalName -ErrorAction SilentlyContinue
    }
    catch{
        Write-Output "Failed to Retrieve: $UserPrincipalName, please try again"
        continue
    }
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
                Invoke-MgGraphRequest -Method DELETE $uri
            }
            else
            {
                Write-Output "$($device.additionalProperties['displayName']) is workplace joined and cannot be removed with this process"
            }
        }
    }
    Else{
        Write-Output "$UserPrincipalName has no devices assigned!"
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




