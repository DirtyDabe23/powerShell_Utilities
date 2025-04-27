$destinationRunbookParameters = [ordered]@{"Key"="$key";"destinationLADParameters"=$destinationLADParameters;"destinationHybridWorkerUser" = "$destinationHybridWorkerUser"; "destinationHybridWorkerKeyVault" = "$destinationHybridWorkerKeyVault";"newUPN" = "$newUPN";"currentUserID" = "$originGraphUserID"}
start-azautomationRunbook -AutomationAccountName "GIT-Infrastructure-Automation" -Name "User-Transfer-5-create-local-74" -ResourceGroupName "uniqueParentCompanyGIT" -RunOn $destinationHybridWorkerGroup  -Parameters $destinationRunbookParameters  -Wait

#implicit:
$runbook = "Test-HybridWorkerRunbook-74"

#explicit:
$runbook = "User-Transfer-5-Create-Local-74"

$runbook = "Test-MGGraph-72"
start-azautomationRunbook -AutomationAccountName "GIT-Infrastructure-Automation" -Name $runbook -ResourceGroupName "uniqueParentCompanyGIT" -RunOn $destinationHybridWorkerGroup  -Parameters $destinationRunbookParameters -verbose

# SIG # Begin signature block#Script Signature# SIG # End signature block




