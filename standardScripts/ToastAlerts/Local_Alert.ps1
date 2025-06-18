        #LocalAlert
        invoke-webrequest -Uri $imageURI -OutFile $remoteImageName
        $gitLogo = New-BTImage -Source $remoteImageName  -HeroImage
        $header = New-BTText -Content  $headerMessage
        $messageContent = New-BTText -Content $messageContent
        $rebootButton = New-BTButton -Content "Reboot now" -Arguments "ToastReboot:" -ActivationType Protocol
        $action = New-BTAction -Buttons $rebootButton
        $Binding = New-BTBinding -Children $header, $messageContent -HeroImage $gitLogo
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $action
        Submit-BTNotification -Content $Content
# SIG # Begin signature block#Script Signature# SIG # End signature block



