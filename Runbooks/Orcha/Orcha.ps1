param(
    [string]$Key,
    [string]$Runbook
)

$params = [ordered]@{"KEY"="$Key"}

$connection = Connect-AzAccount -Identity -Subscription "ea460e20-c6e3-46c7-9157-101770757b6b"

$context = Get-AzContext 

Write-output $context

Write-Output "The runbook is: $Runbook"
Write-Output "The key is $Key"
Start-AzAutomationRunbook -AutomationAccountName "GIT-Infrastructure-Automation" -Name $Runbook -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Test Hybrid Worker Group" -Parameters $params


# SIG # Begin signature block#Script Signature# SIG # End signature block




