param(
    [string]$Key,
    [string]$Runbook
)

$params = [ordered]@{"KEY"="$Key"}

$connection = Connect-AzAccount -Identity -Subscription "azSubsription"

$context = Get-AzContext 

Write-output $context

Write-Output "The runbook is: $Runbook"
Write-Output "The key is $Key"
Start-AzAutomationRunbook -AutomationAccountName "AutomationAccount1" -Name $Runbook -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Test Hybrid Worker Group" -Parameters $params


# SIG # Begin signature block#Script Signature# SIG # End signature block






