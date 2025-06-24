$destinationRunbookParameters = [ordered]@{"Key"="$key";"destinationLADParameters"=$destinationLADParameters;"destinationHybridWorkerUser" = "$destinationHybridWorkerUser"; "destinationHybridWorkerKeyVault" = "$destinationHybridWorkerKeyVault";"newUPN" = "$newUPN";"currentUserID" = "$originGraphUserID"}
start-azautomationRunbook -AutomationAccountName "AutomationAccount1" -Name "User-Transfer-5-create-local-74" -ResourceGroupName "ResourceGroup1" -RunOn $destinationHybridWorkerGroup  -Parameters $destinationRunbookParameters  -Wait

#implicit:
$runbook = "Test-HybridWorkerRunbook-74"

#explicit:
$runbook = "User-Transfer-5-Create-Local-74"

$runbook = "Test-MGGraph-72"
start-azautomationRunbook -AutomationAccountName "AutomationAccount1" -Name $runbook -ResourceGroupName "ResourceGroup1" -RunOn $destinationHybridWorkerGroup  -Parameters $destinationRunbookParameters -verbose

SignatureBlock

