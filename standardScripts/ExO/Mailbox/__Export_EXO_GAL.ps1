Get-EXORecipient -RecipientType "MailContact" -Properties "Company", "Title", "Office", "Phone" -ResultSize "Unlimited" | Sort-Object -Pro perty "DisplayName" | Export-CSV C:\Temp\ExoContacts2.csv
SignatureBlock

