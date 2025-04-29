$moduleVersion = "2.24.0"
$runtimeVersion = "5.1"
$automationAccountName = "AutomationAccount1"
$resourceGroupName = "uniqueParentCompanyGIT"
$startingGraphModules = Get-AzAutomationModule -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName | Where-Object -Property Name -like "*Graph"
foreach ($module in $startingGraphModules){New-AzAutomationModule -AutomationAccountName $automationAccountName  -ResourceGroupName $resourceGroupName -Name $module.Name -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$($module.name)/$moduleVersion" -RuntimeVersion $runtimeVersion -verbose}


$module = "Az.Accounts"
$moduleVersion = "2.24.0"
$runtimeVersion = "7.2"
$automationAccountName = "AutomationAccount1"
$resourceGroupName = "uniqueParentCompanyGIT"
New-AzAutomationModule -AutomationAccountName $automationAccountName  -ResourceGroupName $resourceGroupName -Name $module -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$module/$moduleVersion" -RuntimeVersion $runtimeVersion

$module = "ExchangeOnlineManagement"
$moduleVersion = "3.5"
$runtimeVersion = "7.2"
$automationAccountName = "AutomationAccount1"
$resourceGroupName = "uniqueParentCompanyGIT"
New-AzAutomationModule -AutomationAccountName $automationAccountName  -ResourceGroupName $resourceGroupName -Name $module -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$module/$moduleVersion" -RuntimeVersion $runtimeVersion

# SIG # Begin signature block#Script Signature# SIG # End signature block





