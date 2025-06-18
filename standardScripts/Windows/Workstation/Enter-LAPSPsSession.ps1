if (!($computerName)){$computerName = Read-Host "Enter the computername"}
$lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords
    if($lapsData){
    $account  = -join (".\" , $($lapsData.account))
    $pw = $lapsData.Password
    $LAPS = [PSCredential]::New($account,$pw)
    $testResult = Test-Wsman -ComputerName $computerName -Authentication Negotiate -Credential $LAPS
        if($testResult){
            Enter-PsSession -ComputerName $computerName -Authentication Negotiate -Credential $LAPS -ConfigurationName "PowerShell.7" -EnableNetworkAccess
        }
        Else{
            Throw $error[0]
        }
    }
else{
    Throw $error[0]
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




