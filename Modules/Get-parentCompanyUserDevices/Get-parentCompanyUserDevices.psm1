function Get-parentCompanyUserDevices{
    <#
    .SYNOPSIS
    This function retrieves all of the user's owned devices and prints them in an easy to read manner.
    .DESCRIPTION
    This function
    .COMPONENT
    EntraID, Intune
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the Primary User to remove from Devices. It pulls based off InTune and returns all devices where they are listed as the primary user.
    .EXAMPLE
    Get-parentCompanyUserDevices -UserPrincipalName $userUPN 
    .NOTES
    You need to start with Connect-MgGraph, and then you will need to have the permissions required.
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    .OUTPUTS
    A list of devices assigned to the user with their details.
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
    $tracking = @()
    If ($devices){ 
        ForEach($device in $devices){
            $deviceData = $device | Select-Object -Property AdditionalProperties -ExpandProperty AdditionalProperties | ConvertTo-Json -Depth 10 | ConvertFrom-Json -Depth 10
            $tracking += [PSCustomObject]@{
                deviceUser          =   $UserPrincipalName
                deviceDisplayName   =   $deviceData.displayName
                created             =   $deviceData.createdDateTime
                enrollment          =   $deviceData.enrollmentType
                trustType           =   $deviceData.trustType
                management          =   $deviceData.managementType
                manufacturer        =   $deviceData.manufacturer
                model               =   $deviceData.model
                OS                  =   $deviceData.operatingSystem
                OSVersion           =   $deviceData.operatingSystemVersion
                
            }
        }
        return $tracking
        
    }
    Else{
        return "$UserPrincipalName has no devices assigned!"
    }
}
SignatureBlock

