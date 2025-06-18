If ($serviceStatus.Status -ne "Running"){
    Start-Service "NlaSvc"
    Restart-Service TZAutoUpdate
}
Else{
    Write-Output "Service is already running"
    Exit 0
}
$serviceStatus = Get-Service -Name NlaSvc
If ($serviceStatus.Status -ne "Running"){
    Exit 1
}
Else{
    Exit 0
}