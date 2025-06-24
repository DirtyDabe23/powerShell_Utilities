Connect-MgGraph -NoWelcome

#Example: ServerMGMT01
$managedIdentityName = Read-Host "Enter the name of the Managed Identity that requires permissions`nExample, ServerMGMT01`n`Managed Identity Name"
$managedIdentity = Get-AzResource -Name $managedIdentityName
$appRegName = Read-Host "Enter the App Registration Name that that the Managed Identity needs access to.`nExample:PowerShell_GraphAccess`nEnter"
$appReg = Get-MgApplication -Search "DisplayName:$appRegName" -ConsistencyLevel:eventual

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $appReg.ID -PrincipalId $managedIDentity.PrincipalID -ResourceId $appReg.ID

SignatureBlock

