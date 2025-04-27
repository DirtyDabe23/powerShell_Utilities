$computers = "PREFIX-LT-1114" , "PREFIX-LT-1240" , "PREFIX-LT-1181", "PREFIX-LT-1128" , "uniqueParentCompany-1037" , "PREFIX-LT-1217" , "PREFIX-LT-1239"
If (!($cred))
{
    Write-Output "Pending Credential Request"
    $cred = Get-Credential
}
ForEach ($computer in $computers){
    Invoke-Command -SCriptBlock {Get-IISAppPool  | Select-Object *} -ComputerName $computer -Credential $cred -Authentication Negotiate -AsJob | Out-Null
}




do {
    $now = Get-Date -Format HH:mm:ss
    Write-Output "[$now] : Waiting for AppPool jobs to complete"
    Start-Sleep -Seconds 5
    $jobs = Get-Job  
    
} While ($jobs.state -like "Running")
$appPools = $jobs | Where-Object {($_.State -eq "Completed")} | Receive-Job -Keep
$appPoolsSorted = $appPools | Select-Object PSComputerNAme, Name , isLocallyStored, StartMode , AutoStart , State | Sort-Object PSComputerName
$appPoolsSorted | Format-Table

$jobs | Remove-Job -Force
$jobs = $null

ForEach ($computer in $computers){
    Invoke-Command -SCriptBlock {Get-IISSite  | Select-Object *} -ComputerName $computer -Credential $cred -Authentication Negotiate -AsJob | Out-Null
}


do {
    $now = Get-Date -Format HH:mm:ss
    Write-Output "[$now] : Waiting for IIS Sites jobs to complete"
    Start-Sleep -Seconds 5
    $jobs = Get-Job  
    
} While ($jobs.state -like "Running")
Start-Sleep -Seconds 5
$jobs = Get-Job
$iisSites  = $jobs | Where-Object {($_.State -eq "Completed")} | Receive-Job -Keep
$iisSiteSsorted = $iisSites| Select-Object PSComputerNAme, Name , isLocallyStored, StartMode , AutoStart , State | Sort-Object PSComputerName
$iisSitesSorted | Format-Table




# SIG # Begin signature block#Script Signature# SIG # End signature block






