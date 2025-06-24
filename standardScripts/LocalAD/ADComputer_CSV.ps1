Get-LocalUser | Select Name, PasswordLastSet | ForEach-Object { 
    [PSCustomObject] @{ 
        Hostname = $env:ComputerName
        Username = $_.Name
        PasswordLastSet = $_.PasswordLastSet
    }
} | Export-CSV -Path C:\Temp\LocalUsers1.csv\
SignatureBlock

