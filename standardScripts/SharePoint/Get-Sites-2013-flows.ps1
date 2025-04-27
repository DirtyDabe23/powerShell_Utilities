Connect-SPOService -url "https://uniqueParentCompanyinc-admin.sharepoint.com"
$topLevelSites = Get-SPOSite -limit All

# Get SP 2013 workflows
$outputFile = 'C:\Temp\2013Workflows.csv'
$site =  Get-SPOSite -limit All


     # get the collection of webs
     foreach($site in $topLevelSites){
        $sitePages = Get-SPOSitePages -site $site.Url
     foreach($spWeb in $site.AllWebs) {
       $wfm = New-object Microsoft.SharePoint.WorkflowServices.WorkflowServicesManager($spWeb)
       $wfsService = $wfm.GetWorkflowSubscriptionService()
       foreach ($spList in $spWeb.Lists) {
         $subscriptions = $wfsService.EnumerateSubscriptionsByList($spList.ID)
         foreach ($subscription in $subscriptions) {
           #$subscriptions.name
           #$subscriptions.PropertyDefinitions#._UIVersionString #_IsCurrentVersion
           $i++
           #excluding multiple version of the same workflow
           if (($spWeb.Url + $spList.Title + $subscriptions.Name) -ne $output) {
             $output = $spWeb.Url + $spList.Title + $subscription.Name    
             $wfID = $subscription.PropertyDefinitions["SharePointWorkflowContext.ActivationProperties.WebId"]        
             $wfResult = New-Object PSObject;
             $wfResult | Add-Member -type NoteProperty -name 'URL' -value ($spWeb.URL);
             $wfResult | Add-Member -type NoteProperty -name 'ListName' -value ($spList.Title);
             $wfResult | Add-Member -type NoteProperty -name 'wfName' -value ($subscription.Name);
             $wfResult | Add-Member -type NoteProperty -name 'wfID' -value ($wfID);
             $wfResults += $wfResult;
           }
           if ($i -eq 10) {Write-Host '.' -NoNewline; $i = 0;}
         }
       }
    }

 }
 $wfResults | Export-CSV $outputFile -Force -NoTypeInformation
 Write-Host
 Write-Host 'Script Completed'
 Stop-SPAssignment $spAssignment  
# SIG # Begin signature block#Script Signature# SIG # End signature block




