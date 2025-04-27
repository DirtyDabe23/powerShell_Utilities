#Connect the SharePoint online Admin center  
Connect-SPOService -URL https://uniqueParentCompanyinc-admin.sharepoint.com  
  
$siteURL = “https://uniqueParentCompanyinc.sharepoint.com/it/SitePages/Global-Information-Technology.aspx”  
  
Set-SPOSite -Identity $siteURL -Lockstate “NoAccess”  
   
#Set-SPOSite -Identity $siteURL -Lockstate “Unlock”  
# SIG # Begin signature block#Script Signature# SIG # End signature block




