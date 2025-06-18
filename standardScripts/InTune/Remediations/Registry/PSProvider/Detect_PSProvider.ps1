$ProtocolHandler = get-item 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    Write-Output "Protocol Handler does not exist."
    Exit 1
}
else{
    Write-output "Protocol Handler Exists"
    # Create handler for reboot
    if (!(Get-Item "HKLM:\SOFTWARE\CLASSES\ToastReboot" -erroraction silentlycontinue)){
        Write-Output "Key does not exist."
        Exit 1
    }
    else{
        $toastReboot = Get-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot'
        $toastRebootShell = Get-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\command'
        if (($toastReboot.editFlags -ne '2162688') -or ($toastRebootShell.PSChildName -ne "command") -or ($toastRebootShell.'(Default)' -ne 'pwsh.exe -Command "& {Restart-Computer -Force}" -windowstyle "Hidden"')){
            Write-Output "Invalid Configuration"
            Exit 1 
        }
        else{
            Write-Output "All configured"
            Exit 0
        }

    }
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




