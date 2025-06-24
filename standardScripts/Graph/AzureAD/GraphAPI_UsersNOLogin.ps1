Get-MgUser -Filter "signInActivity/lastSignInDateTime le 2023-01-01T00:00:00Z" | Export-CSV C:\Temp\GraphAPIUsers2023.csv
SignatureBlock

