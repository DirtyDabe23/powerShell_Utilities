$scopes = (Get-MgContext).scopes
$failedPerms = @()
$GraphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
$principalDisplays = @('PREFIX-VS-MGMT01','US-AZ-VS-DC01', 'US-CA-VS-DC01','US-KS-VS-DC01', 'US-MN-VS-DC01','US-NC-VS-DC01','DC2','RVS-DC1','uniqueParentCompanyAlcoilSrv')
ForEach ($principalDisplay in $principalDisplays){
WRite-Output "Evaluating: $principalDisplay"
$failedPerms = @{}
$principal = Get-MgServicePrincipal -Search "DisplayName: $principalDisplay" -ConsistencyLevel:eventual

#build the scopes off the context you're using
$scopes = (Get-MGContext).Scopes
ForEach ($scope in $scopes){
    $permissionName = $scope 
$permission = $graphServicePrincipal.AppRoles | Where-Object {($_.Value -eq $permissionName)} | Select-Object *
    if ($permission){
        Write-Output "$principalDisplay`: Adding $permissionName"
        try {
            New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principal.ID -PrincipalId $principal.ID  -ResourceId $GraphServicePrincipal.ID -AppRoleId $permission.ID
        }
        catch{
            $failedPerms += [PSCustomObject]@{
                Principal = $principalDisplay
                FailedPermission = $permissionName}
        }
    }
    Else{
        Write-output "$principalDisplay`: could not be granted $permissionName"
    }
}
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





