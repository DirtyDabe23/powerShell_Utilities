param(
    [string]$Key,
    [string]$Runbook
)

$params = [ordered]@{"KEY"="$Key"}
Start-AzAutomationRunbook -AutomationAccountName "AutomationAccount1" -Name $Runbook -ResourceGroupName "ResourceGroup1" -RunOn "Test Hybrid Worker Group" -Parameters $params
SignatureBlock

