Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Taneytown Employee Roster Members" | Export-CSV -Path "C:\Temp\Taneytown Employee Roster Members.csv"
Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Taneytown Employee Roster Owners" | Export-CSV -Path "C:\Temp\Taneytown Employee Roster Owners.csv"
Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Taneytown Employee Roster Visitors" | Export-CSV -Path "C:\Temp\Taneytown Employee Roster Visitors.csv"
Get-SPOUser -Site https://uniqueParentCompanyinc.sharepoint.com -Group "Taneytown Office Employee Roster Visitors" | Export-CSV -Path "C:\Temp\Taneytown Office Employee Roster Visitors.csv"

# SIG # Begin signature block#Script Signature# SIG # End signature block




