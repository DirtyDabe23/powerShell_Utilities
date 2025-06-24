function Remove-parentCompanyDeviceAssignment{
    <#
    .SYNOPSIS
    This script removes the user as the primary user of the device.
    
    .DESCRIPTION
    This script removes the user as the primary user of the device by their UserPrincipalName
    It does not remove Entra Enrolled Devices
    
    .PARAMETER UserPrincipalName
    The UserPrincipalName of the Primary User to remove from Devices.
    
    .EXAMPLE
    Remove-parentCompanyDeviceAssignment -UserPrincipalName "TestFirst.TestLast@Domain.extension1"
    
    .NOTES
    You need to start with Connect-MgGraph, and then you will need to have the permissions required. 
    #>
    [CmdletBinding()] 
    param(
    [Parameter(Position = 0, HelpMessage = "Enter The User Prinicpal Name to remove said user from the specified devices where they are the primary user.",ValueFromPipelineByPropertyName,Mandatory = $false)]
    [Parameter(ParameterSetName = "UserPrincipalName",  Position = 0, HelpMessage = "Enter the User Principal Name to remove as the Primary User from all devices.",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Position = 1, HelpMessage = "Enter the Intune Device DisplayName to Remove the Primary User from it",ValueFromPipelineByPropertyName,Mandatory = $false)]
    [Parameter(ParameterSetName = "DeviceDisplayName" , Position = 1, HelpMessage = "Enter the Intune Device DisplayName to Remove the Primary User from it",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$intuneDeviceName,
    [Parameter(Position = 2, HelpMessage = "Enter the Intune Device ID to Remove the Primary User from it.",ValueFromPipelineByPropertyName,Mandatory = $false)]
    [Parameter(ParameterSetName = "DeviceID",           Position = 2, HelpMessage = "Enter the Intune Device ID to Remove the Primary User from it.",ValueFromPipelineByPropertyName,Mandatory = $true)]
    [string]$intuneDeviceID
    )
    $removalData = @()
    if ($PSCmdlet.ParameterSetName -eq "DeviceDisplayName"){
        $searchMethod   = "DeviceDisplayName"
        $searchValue    = "$intuneDeviceName"
        #Get the Device ID from the Display Name
        $allAPIDevices = @()
        $pageData = @()
        $pageData += invoke-mggraphrequest -method get -uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices" -headers @{ConsistencyLevel = 'eventual'} -ContentType application/json -outputType PSObject
        if ($pageData.'@odata.nextLink'){
            $allAPIDevices += $pageData.Value
            $nextPage = $pageData.'@odata.nextLink'
            while ($nextPage){
                $nextPageDevices = invoke-mggraphrequest -method get -uri $nextPage -headers @{ConsistencyLevel = 'eventual'} -ContentType application/json -OutputType PSObject
                $allAPIDevices += $nextPageDevices.value
                $nextPage = $nextPageDevices.'@odata.nextLink'
            }
        }
        else{
            $allAPIDevices = $pageData.Value
        }
        $devices = $allAPIDevices | Where-Object { $_.deviceName -eq $intuneDeviceName }
    }
    if ($psCmdlet.ParameterSetName -eq "DeviceID"){
        $searchMethod = 'DeviceID'
        #Validate the Device ID
        $devices = Get-MgBetaDeviceManagementManagedDevice -ManagedDeviceId $intuneDeviceID -ErrorAction SilentlyContinue
        $searchValue = "$intuneDeviceID" 
    }
    if ($PSCmdlet.ParameterSetName -eq "UserPrincipalName"){
        $searchMethod = 'UserPrincipalName'
        $searchValue =  "$userPrincipalName"
        try{ 
            $userURI = 'https://graph.microsoft.com/beta/users?$search="UserPrincipalName:' , "$UserPrincipalName"  , '"&?select=id' -join "" 
            $userResponse = invoke-mggraphrequest -method Get -uri $userURI -Headers @{ConsistencyLevel = 'eventual'} -ContentType application/json -OutputType PSObject 
            }
        catch{
            return "Failed to Retrieve: $UserPrincipalName, please try again"
        }
        $devices = (invoke-mgGraphRequest -method GEt -uri ('https://graph.microsoft.com/beta/users/{',$userResponse.Value.ID,'}/managedDevices' -join "") -OutputType PSObject -Headers @{ConsistencyLevel = 'eventual'} -ContentType application/json).value
    }
    If ($devices){
            ForEach ($device in $devices){
                $intuneDeviceID = $device.ID
                $graphApiVersion = "beta"
                $Resource = "deviceManagement/managedDevices('$intuneDeviceID')/users/`$ref"
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
                Invoke-MgGraphRequest -Method DELETE $uri
                $removalData += [PSCustomObject]@{
                    DeviceName              =   $device.deviceName
                    DeviceID                =   $device.ID
                    UserPrincipalName       =   $device.userPrincipalName
                    SearchMethod            =   $searchMethod 
                    SearchValue             =   $searchValue
                }
            }
            return $removalData
        }
        Else{
            return "There is no device registration matching $searchValue via $searchMethod"
        }
}
SignatureBlock

