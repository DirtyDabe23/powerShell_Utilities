$officeLocations = Get-MGBetaUser -all -ConsistencyLevel eventual | Where-Object {($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated") -and ($_.UserType -eq "Member")} | Select-Object -Property OfficeLocation -unique | Sort-Object

ForEAch ($officeLocation in $officeLocations)
{
    $date = Get-Date -Format "yyyy.MM.dd"
    $filePath = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\M365\Data_Cleanup\$date.$($officeLocation.OfficeLocation).csv"
    Get-MGBetaUser -search "OfficeLocation:$($officelocation.officeLocation)" -ConsistencyLevel eventual | Select-Object -Property DisplayName, UserPrincipalName, CompanyName, OfficeLocation, Department, JobTitle | Sort-Object -Property "Company","OfficeLocation","DisplayName" |   Export-CSV -Path $filePath 
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





