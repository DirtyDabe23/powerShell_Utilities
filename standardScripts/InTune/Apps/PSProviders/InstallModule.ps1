$ProtocolHandler = get-item 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    Write-Output "Protocol Handler does not exist."
    New-Item 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -Force
}
else{
    Write-output "Protocol Handler Exists"
}

        $toastReboot = Get-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot'
        $toastRebootShell = Get-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\command'
        if (($toastReboot.editFlags -ne '2162688') -or ($toastRebootShell.PSChildName -ne "command") -or ($toastRebootShell.'(Default)' -ne 'pwsh.exe -Command "& {Restart-Computer -Force}" -windowstyle "Hidden"')){
            Write-Output "Invalid Configuration"
            # Create handler for reboot
            Set-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -Name '(DEFAULT)' -Value 'url:ToastReboot' -Force
            Set-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -Name 'URL Protocol' -Value '' -Force
            New-ItemProperty -Path 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -PropertyType Dword -Name 'EditFlags' -Value 2162688
            New-Item 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\Command' -Force
            Set-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\Command' -Name '(DEFAULT)' -Value 'pwsh.exe -Command "& {Restart-Computer -Force}" -windowstyle "Hidden"' -Force
            Write-Output "Completed!"
            $toastReboot = Get-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot'
            $toastRebootShell = Get-ItemProperty 'HKLM:\SOFTWARE\CLASSES\ToastReboot\Shell\Open\command'
            if (($toastReboot.editFlags -ne '2162688') -or ($toastRebootShell.PSChildName -ne "command") -or ($toastRebootShell.'(Default)' -ne 'pwsh.exe -Command "& {Restart-Computer -Force}" -windowstyle "Hidden"')){
                Write-Output "Failed to Configure"
                Exit 1 
            }
            else{
                Write-Output "All configured"
                Exit 0
            }
        }
        else{
            Write-Output "All configured"
            Exit 0
        }

# SIG # Begin signature block#Script Signature# SIG # End signature block




