$comp = Get-ADComputer -Filter * | Select-Object -ExpandProperty name

$data = Invoke-Command -ComputerName $comp -ScriptBlock { 
    get-localgroupmember administrators | Where-Object PrincipalSource -eq Local
}

$data | Export-Csv \\server\Share\localadmin.csv -NoTypeInformation
# SIG # Begin signature block#Script Signature# SIG # End signature block





