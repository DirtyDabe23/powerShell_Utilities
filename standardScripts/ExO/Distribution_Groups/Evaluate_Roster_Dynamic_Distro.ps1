# Define the file paths
$allEmployeesFile = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Dynamic_Groups\ESOP_Group\Working\AllESOPEmployees.csv"
$rosterFile = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Dynamic_Groups\ESOP_Group\Working\Roster.csv"
$employeesNotInRosterFile = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Dynamic_Groups\ESOP_Group\Working\EmployeesNotInRoster2.csv"
$employeesNotInDynamicDistroFile = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Dynamic_Groups\ESOP_Group\Working\EmployeesNotinDynamicDistro2.csv"

# Import the CSV files
$allEmployees = Import-Csv $allEmployeesFile
$roster = Import-Csv $rosterFile

# Find employees not in Roster
$employeesNotInRoster = $allEmployees | Where-Object { $_.Username -notin $roster.Username }

# Find employees not in AllESOPEmployees
$employeesNotInDynamicDistro = $roster | Where-Object { $_.Username -notin $allEmployees.Username }

# Export employees not in Roster to a CSV
$employeesNotInRoster | Export-Csv $employeesNotInRosterFile -NoTypeInformation

# Export employees not in AllESOPEmployees to a CSV
$employeesNotInDynamicDistro | Export-Csv $employeesNotInDynamicDistroFile -NoTypeInformation

Write-Host "Employees not in Roster exported to $employeesNotInRosterFile"
Write-Host "Employees not in AllESOPEmployees exported to $employeesNotInDynamicDistroFile"
# SIG # Begin signature block#Script Signature# SIG # End signature block





