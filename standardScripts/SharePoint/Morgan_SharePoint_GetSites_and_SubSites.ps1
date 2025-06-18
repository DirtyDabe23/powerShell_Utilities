https://morgantechspace.com/2021/10/get-all-sites-and-sub-sites-in-sharepoint-online-using-pnp-powershell.html
Provide your SharePoint Online Admin center URL
$AdminSiteURL = "https://contoso-admin.sharepoint.com"
#$AdminSiteURL = "https://<Tenant_Name>-admin.sharepoint.com"
 
#Get SharePoint Admin User Credentials  
$Cred = Get-Credential
 
#Connect to SharePoint Admin Site
Connect-PnPOnline -Url $AdminSiteURL -Credentials $Cred 
 
#Get all site collections
$Sites = Get-PnPTenantSite
#The below command gets only modern Team & Communication sites
#$Sites = Get-PnPTenantSite | Where -Property Template -In ("GROUP#0", "SITEPAGEPUBLISHING#0")
   
$AllSites = @()
 
$i = 0;
$TotoalSites = $Sites.Count
#Enumerate site collections and get sub sites recursively
ForEach($Site in $Sites)
{
$i++;
Write-Progress -activity "Processing $($Site.Url)" -status "$i out of $TotoalSites completed"
 
$SubWebs=$null;
Try
{
#Connect to site collection
$SiteConnection = Connect-PnPOnline -Url $Site.Url -Credentials $Cred
   
#Get the sub sites of the site collection
$SubWebs = Get-PnPSubWeb -Recurse -Connection $SiteConnection
  
Disconnect-PnPOnline -Connection $SiteConnection
}
catch{
Write-Host "Error occured $($Site.Url) : $_.Exception.Message"   -Foreground Red;
}
 
#Add site collection in AllSites list 
$AllSites += New-Object PSObject -property $([ordered]@{ 
SiteName  = $Site.Title            
SiteURL = $Site.Url
IsSubSite = $false
HasSubSites = if ($SubWebs -and $SubWebs.Count -gt 0) { $true } Else {$false}
SiteCollectionName = $Site.Title
SiteCollectionURL = $Site.Url
})
 
if ($SubWebs -and $SubWebs.Count -gt 0) {
#Enumerate sub sites and add in AllSites list 
ForEach($SubSite in $SubWebs)
{
$AllSites += New-Object PSObject -property $([ordered]@{ 
SiteName  = $SubSite.Title            
SiteURL = $SubSite.Url
IsSubSite = $true
HasSubSites = $false
SiteCollectionName = $Site.Title
SiteCollectionURL = $Site.Url
})
}
}
}
#Display all site collections and sub sites
$AllSites | Select SiteName,SiteURL,IsSubSite
# SIG # Begin signature block#Script Signature# SIG # End signature block



