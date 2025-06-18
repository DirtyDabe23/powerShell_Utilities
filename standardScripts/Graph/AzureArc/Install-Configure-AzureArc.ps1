$start_time = Get-Date

$psGallery = Get-PSRepository -Name PSGallery
If ($psGallery.installationPolicy -ne 'Trusted'){
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}
else{
    Write-Host "Provider already trusted"
}

$modules = Get-InstalledModule
If (!($modules -contains 'Az.ConnectedMachine')){
    Install-Module -Name Az.ConnectedMachine -force -confirm:$false -Verbose
}
Else{
    $null
}
Write-Output "Time taken for pre-requisite check: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"

$start_time = Get-Date

$azureAplicationId ="cd58df38-bda7-4ffa-9d3d-49ab4cb0eb1f"
$azureTenantId= $tenantIDString
$azurePassword = ConvertTo-SecureString "$AzureARC" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal
Connect-AzConnectedMachine -ResourceGroupName "AzureARC_uniqueParentCompanyEAST" -Name "$env:ComputerName" -Location "EastUS" -subscriptionid "azSubsription"

Write-Output "Time taken for enrollment: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"
# SIG # Begin signature block#Script Signature# SIG # End signature block






