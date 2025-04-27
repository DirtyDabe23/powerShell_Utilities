Install-Module -Name PnP.PowerShell

#Connect to the Source Site
Connect-PnPOnline -Url https://uniqueParentCompanyinc.sharepoint.com/materials/intercompanytransfers/sourcegreenup -Interactive

#Create the Template
Get-PnPSiteTemplate -Out C:\Temp\Lists.xml -ListsToExtract "Transfer Requests", "2019-2020" -Handlers Lists

#Get the List Data 
Add-PnPDataRowsToSiteTemplate -Path C:\Temp\Lists.xml -List "Transfer Requests"
Add-PnPDataRowsToSiteTemplate -Path C:\Temp\Lists.xml -List "2019-2020"

#Connect to Target Site
Connect-PnPOnline -Url https://uniqueParentCompanyinc.sharepoint.com/materials/intercompanytransfers/sourcegreenup -Interactive

#Apply the Template
Invoke-PnPSiteTemplate -Path "C:\Temp\Lists.xml" 

# SIG # Begin signature block#Script Signature# SIG # End signature block




