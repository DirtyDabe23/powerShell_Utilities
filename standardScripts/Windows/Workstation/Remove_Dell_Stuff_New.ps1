$supportAssists = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse | Get-ItemProperty | Where-Object {$_.DisplayName -like "Dell SupportAssist*" -or $_.DisplayName -like "DellSupportAssist*" -or $_.DisplayName -like "DellOptimizer*" } | Select-Object -ExpandProperty UninstallString

If ($supportAssists)
{
    ForEach ($supportAssist in $supportAssists)
    {
        $arguments = $supportassist.substring(12) + " /qn REBOOT=REALLYSUPRESS"
        Write-Output "Uninstalling Dell SupportAssist"
        Write-Output "msiexec.exe " $arguments
        (Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait -PassThru).ExitCode
        While (Get-Process -Name 'msiexec')
        {
            Start-Sleep -Seconds 5 
        }
    }
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




