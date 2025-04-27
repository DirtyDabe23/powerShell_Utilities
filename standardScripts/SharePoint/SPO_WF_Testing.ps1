$failedSites = @()
Connect-PNPOnline -UseWebLogin -url "https://uniqueParentCompanyinc-admin.sharepoint.com"
$allSites = Get-PNPTenantSite -Detailed 
$classicSites = $allSites | where {($_.GroupID -eq '00000000-0000-0000-0000-000000000000')}
ForEach ($site in $classicSites){
    Disconnect-PnPOnline -ErrorAction SilentlyContinue
    try{
        Write-Output "Connecting to: $($site.Title)"
        Connect-PNPOnline -UseWebLogin -url $site.url -errorAction Stop
    }
    catch{
       Write-Output "Failed to connect to $($site.title)"
       $failedSites += [PSCustomObject]@{
        FailedSite  =   $site.Title
        FailedURL   =   $site.URL
       }
       Continue
    }
    $lists = Get-PnPList
    foreach ($list in $lists) {
        # Query Workflow Associations (2013 Workflows)
        #$workflowAssociations = Invoke-PnPSPRestMethod -Method Get -Url "/_api/web/lists(guid'$($list.Id)')/WorkflowAssociations"
        $workflowAssociations = Invoke-PnPSPRestMethod -Method Get -Url "/_api/web/lists(guid'$($list.Id)')/WorkflowAssociations"
        if ($workflowAssociations) {
            Write-output "List: $($list.title)"
            $workflowAssocations | format-list
            $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
            foreach ($workflow in $workflowAssociations.value) {
                $workflowSites += [PSCustomObject]@{
                    SiteUrl   = $site.Url
                    ListName  = $list.Title
                    listID    = $list.ID
                    listURL   = $list.URL
                    Workflow  = $workflow.Name
                }
            }
        }
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




