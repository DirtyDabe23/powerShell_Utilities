$TenantUrl = "https://uniqueParentCompanyinc-admin.sharepoint.com/"
$User = "Flow.Admin@uniqueParentCompany.com"
Connect-SPOService -Url  $TenantUrl 
$SPOSites = Get-SPOSite -limit all 
foreach ($SPOSite in $SPOSites)
{
    Set-SPOUser -Site $SPOSite.Url -LoginName $User -IsSiteCollectionAdmin $true
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




