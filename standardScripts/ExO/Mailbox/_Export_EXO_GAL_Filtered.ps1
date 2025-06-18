Get-EXORecipient -RecipientType "MailContact" -Filter "Title -like 'Rep'" -ResultSize Unlimited -Properties "Company", "Title", "Office", "Phone" | Sort-Object -Property "DisplayName" | Export-CSV -Path C:\Temp\EXOContactsFiltered2.csv
# SIG # Begin signature block#Script Signature# SIG # End signature block



