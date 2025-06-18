Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Location Employee Roster Members" | Export-CSV -Path "C:\Temp\Location Employee Roster Members.csv"
Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Location Employee Roster Owners" | Export-CSV -Path "C:\Temp\Location Employee Roster Owners.csv"
Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Location Employee Roster Visitors" | Export-CSV -Path "C:\Temp\Location Employee Roster Visitors.csv"
Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Location Office Employee Roster Visitors" | Export-CSV -Path "C:\Temp\Location Office Employee Roster Visitors.csv"

# SIG # Begin signature block#Script Signature# SIG # End signature block





