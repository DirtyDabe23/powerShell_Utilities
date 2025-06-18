[int]$daysNoLogon = Read-Host "Enter the # of days to check"
Get-ADCOmputer -filter * -Properties * | Where-Object {($_.LastLogonDate -le (Get-Date).AddDays(-$daysNoLogon)) -and ($_.OperatingSystem -notlike "*Server*") -and ($_.OperatingSystem -ne $null)} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "LastLogonDate"

#FileShare to export the CSV 
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "offlinefor$($daysNoLogon)days.csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$fileName

Get-ADCOmputer -filter * -Properties * | Where-Object {($_.LastLogonDate -le (Get-Date).AddDays(-$daysNoLogon)) -and ($_.OperatingSystem -notlike "*Server*") -and ($_.OperatingSystem -ne $null)} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "LastLogonDate"  | Export-CSV -Path $exportPath
# SIG # Begin signature block#Script Signature# SIG # End signature block




