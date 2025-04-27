if (!($computerName)){$computerName = Read-Host "Enter the computername"}
$lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords
    if($lapsData){
    $account  = -join (".\" , $($lapsData.account))
    $pw = $lapsData.Password
    $cred = [PSCredential]::New($account,$pw)}

$session = New-PSSession -ComputerName $computerName -Credential $cred -EnableNetworkAccess -Authentication Negotiate -ConfigurationName PowerShell.7
$notificationImageName = "bestgitgud.gif"
$headerMessage = "This is Microsoft CoPilot"
$messageContent = "I would like the Hermit Crab Cage"
$remoteImageDestination = "C:\GIT_Scripts\"
$remoteImageName = $remoteImageDestination , $notificationImageName -join ""
$imageURI = "https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExbzlkMzAxazJmeTUzOHRwMmx3bjJ2NHJ6MnJhNXk2ZHd5NW9udXN1byZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/KX5nwoDX97AtPvKBF6/giphy.gif"

Invoke-Command -Session $session -ScriptBlock {
        invoke-webrequest -Uri $using:imageURI -OutFile $using:remoteImageName
        $gitLogo = New-BTImage -Source $using:remoteImageName  -HeroImage
        $header = New-BTText -Content  $using:headerMessage
        $messageContent = New-BTText -Content $using:messageContent
        $rebootButton = New-BTButton -Content "Reboot now" -Arguments "ToastReboot:" -ActivationType Protocol
        $action = New-BTAction -Buttons $rebootButton
        $Binding = New-BTBinding -Children $header, $messageContent -HeroImage $gitLogo
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $action
        Submit-BTNotification -Content $Content
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



