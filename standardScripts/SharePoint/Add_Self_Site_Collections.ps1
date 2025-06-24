$TenantUrl = "https://parentCompanyinc-admin.sharepoint.com/"
$User = "david.drosdick@Domain.extension1"
Connect-SPOService -Url  $TenantUrl 
$SPOSites = Get-SPOSite -limit all 
foreach ($SPOSite in $SPOSites)
{
    Set-SPOUser -Site $SPOSite.Url -LoginName $User -IsSiteCollectionAdmin $true
}
SignatureBlock

