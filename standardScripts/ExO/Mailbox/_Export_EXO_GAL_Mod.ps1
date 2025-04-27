# Set the credentials to connect to Azure AD
$credential = Get-Credential
Connect-ExchangeOnline -Credential $credential
$csvPath = "C:\Temp\ExoContacts.csv"
Get-EXORecipient -RecipientType "MailContact" -Properties "Company", "Title", "Office", "Phone" -ResultSize "Unlimited" | Sort-Object -Property "DisplayName" | Export-CSV -Path $csvPath -Force

Start-Sleep -Seconds "30"
# Import the CSV file
$csv = Import-Csv -Path $csvPath

# Add a new column called "NewTitle"
$csv | Add-Member -MemberType NoteProperty -Name "NewTitle" -Value $null

# Loop through each row in the CSV file and set the value of the "NewTitle" column
foreach ($user in $csv) {
    $user.NewTitle = $user.Title + " - " + $user.Company
}

# Export the modified CSV file
$csv | Export-Csv -Path "C:\Temp\EXOPost.csv" -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block



