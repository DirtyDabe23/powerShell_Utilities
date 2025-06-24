param(
    [string]$jiraTicket,
    [string]$Runbook
)

$params = [ordered]@{"jiraTicket"="$jiraTicket"}

$connection = Connect-AzAccount -Identity -Subscription "azSubsription"

$context = Get-AzContext 

Write-output $context

Write-Output "The runbook is: $Runbook"
Write-Output "The key is $jiraTicket"
Start-AzAutomationRunbook -AutomationAccountName "AutomationAccount1" -Name $Runbook -ResourceGroupName "ResourceGroup1" -RunOn "Test Hybrid Worker Group" -Parameters $params


SignatureBlock

