Get-Mailbox -ResultSize unlimited | select-object -Property UserPrincipalName, CustomAttribute1, CustomAttribute2, CustomAttribute3, CustomAttribute4, CustomAttribute5, CustomAttribute6, CustomAttribute7, CustomAttribute8, CustomAttribute9, CustomAttribute10, CustomAttribute11, CustomAttribute12, CustomAttribute13, CustomAttribute14, CustomAttribute15 | Export-CSV -Path C:\Temp\CustomAttributes.csv 
# SIG # Begin signature block#Script Signature# SIG # End signature block



