while ($later -gt $now)
{$time = Get-Date -Format HH:mm:ss
Write-output "Waiting as of: $time"
Start-Sleep -Seconds 30
$now = Get-Date 
}

$distro | Set-DynamicDistributionGroup -ForceMembershipRefresh
$time = Get-Date -Format HH:mm:ss
Write-output "Waiting as of: $time"
Start-Sleep -seconds 30
$distro | Get-DynamicDistributionGroupMember -ResultSize Unlimited | sort LastName | select DisplayName , PrimarySmtpAddress, CountryOrRegion , Company , Office , Department | Export-CSV -path C:\Temp\2024-12-09-allusemployeesminusselect.csv
# SIG # Begin signature block#Script Signature# SIG # End signature block



