[int]$daysNoLogon = 90
$MGDevices = Get-MGDevice -all -ConsistencyLevel:eventual | Where-Object {($_.ApproximateLastSignInDateTime -le (Get-Date).AddDays(-$daysNoLogon)) -and ($_.OperatingSystem -eq "Windows")} |Select-Object -Property "DisplayName", "ApproximateLastSignInDateTime" | sort-object -Property "ApproximateLastSignInDateTime"

# SIG # Begin signature block#Script Signature# SIG # End signature block



