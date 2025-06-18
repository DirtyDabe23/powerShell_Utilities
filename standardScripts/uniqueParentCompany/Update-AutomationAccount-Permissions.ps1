Connect-MgGraph -NoWelcome
$failedPerms = @()
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
$principalDisplay = Read-Host "Enter the Service Principal Name that needs permissions updated`n`nExample: AutomationAccount1`nExample: PREFIX-VS-MGMT01`nEnter"
$principal = Get-MgServicePrincipal -Search "DisplayName: $principalDisplay" -ConsistencyLevel:eventual

#build the scopes off the context you're using
$scopes = (Get-MGContext).Scopes
ForEach ($scope in $scopes){
    $permissionName = $scope 
$permission = $graphServicePrincipal.AppRoles | Where-Object {($_.Value -eq $permissionName)} | Select-Object *
    if ($permission){
        Write-Output "$principalDisplay`: Adding $permissionName"
        try {New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principal.ID -PrincipalId $principal.ID  -ResourceId $GraphServicePrincipal.ID -AppRoleId $permission.ID}
        catch{
            $failedPerms +=[PSCustomOBject]{
            FailedPermission = $permissionName
            }
        }
    }
    Else{
        Write-output "$principalDisplay`: could not be granted $permissionName"
    }
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





