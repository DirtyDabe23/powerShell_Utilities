if (!($computerName)){$computerName = Read-Host "Enter the computername"}
$lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords
    if($lapsData){
    $account  = -join (".\" , $($lapsData.account))
    $pw = $lapsData.Password
    $cred = [PSCredential]::New($account,$pw)}

$session = New-PSSession -ComputerName $computerName -Credential $cred -EnableNetworkAccess -Authentication Negotiate -ConfigurationName PowerShell.7
$notificationImageName = "RunAway.gif"
$headerMessage = "You know what?"
$messageContent = "SCREW THIS, EVERY PERSON FOR THEMSELVES"
$remoteImageDestination = "C:\GIT_Scripts"
$remoteImageName = $remoteImageDestination , $notificationImageName -join ""

#Copy-Item -Path $notificationImage -Destination $remoteImageName -ToSession $session
Invoke-Command -Session $session -ScriptBlock {
        invoke-webrequest -Uri "https://media1.tenor.com/m/mYuNLpPNX3EAAAAd/run-away-monty-python.gif" -OutFile $using:remoteImageName
        $gitLogo = New-BTImage -Source $using:remoteImageName  -HeroImage
        $header = New-BTText -Content  $using:headerMessage
        $messageContent = New-BTText -Content $using:messageContent
        $rebootButton = New-BTButton -Content "Get Up and Leave" -Arguments "ToastReboot:" -ActivationType Protocol
        $action = New-BTAction -Buttons $rebootButton
        $Binding = New-BTBinding -Children $header, $messageContent -HeroImage $gitLogo
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $action
        Submit-BTNotification -Content $Content
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



