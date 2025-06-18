$azureAplicationId ="cd58df38-bda7-4ffa-9d3d-49ab4cb0eb1f"
$azureTenantId= $tenantIDString
$azurePassword = ConvertTo-SecureString "$AzureARC" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal
# SIG # Begin signature block#Script Signature# SIG # End signature block




