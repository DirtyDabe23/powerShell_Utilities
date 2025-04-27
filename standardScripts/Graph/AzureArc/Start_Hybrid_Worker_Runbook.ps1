param(
    [string]$Key,
    [string]$Runbook
)

$params = [ordered]@{"KEY"="$Key"}
Start-AzAutomationRunbook -AutomationAccountName "GIT-Infrastructure-Automation" -Name $Runbook -ResourceGroupName "uniqueParentCompanyGIT" -RunOn "Test Hybrid Worker Group" -Parameters $params
# SIG # Begin signature block#Script Signature# SIG # End signature block




