$ServicePrincipalId = '$ExOManagedIdent' #Copied from the Identity blade above
$ResourceGroupName = 'uniqueParentCompanyGIT'
New-AzRoleAssignment -ObjectId $ServicePrincipalId -ResourceGroupName $ResourceGroupName -RoleDefinitionName Reader
New-AzRoleAssignment -ObjectId $ServicePrincipalId -ResourceGroupName $ResourceGroupName -RoleDefinitionName 'Automation Job Operator'
New-AzRoleAssignment -ObjectId $ServicePrincipalId -ResourceGroupName $ResourceGroupName -RoleDefinitionName 'Automation Runbook Operator'

#New Service Principal Permissions using Graph API
$ServicePrincipalId = '$ExOManagedIdent'
$GraphResource = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$Permission = $GraphResource.AppRoles | Where-Object {$_.value -eq 'User.Read.All'}
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipalId -PrincipalId $ServicePrincipalId -AppRoleId $Permission.Id -ResourceId $GraphResource.Id

# SIG # Begin signature block#Script Signature# SIG # End signature block





