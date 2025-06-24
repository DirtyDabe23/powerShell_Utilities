# Connect to SharePoint Online
$siteUrl = "https://parentCompanyinc-admin.sharepoint.com"
Connect-PnPOnline -Url $siteUrl -Interactive  # (Prompt-based auth) 
SignatureBlock

