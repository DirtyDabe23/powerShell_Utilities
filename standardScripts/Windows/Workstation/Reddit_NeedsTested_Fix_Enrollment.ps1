[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

 

$Computer  = [Microsoft.VisualBasic.Interaction]::InputBox("Enter machine name here","Target Machine:")

 

Start-Process "C:\Windows\System32\PsExec.exe" -ArgumentList \$Computer -s winrm.cmd quickconfig -q -NoNewWindow -ErrorAction SilentlyContinue

 

Invoke-Command -ComputerName $Computer {

 

Start-Transcript "c:\temp$computer.log"

 

 

 

$dsreg = dsregcmd.exe /status

            if (($dsreg | Select-String "DomainJoined :") -match "NO") {

                throw "Computer is NOT domain joined"

            }

 

            Start-Sleep 5

 

            Write-host "removing certificates"

            Get-ChildItem 'Cert:\LocalMachine\My' | ? { $_.Issuer -match "MS-Organization-Access|MS-Organization-P2P-Access [\d+]" } | % {

                Write-Host "Removing leftover Hybrid-Join certificate $($_.DnsNameList.Unicode)" -ForegroundColor Cyan

                Remove-Item $_.PSPath

            }

 

            $dsreg = dsregcmd.exe /status

            if (!(($dsreg | Select-String "AzureAdJoined :") -match "NO")) {

                throw "$Computer is still joined to Azure. Run again"

            }

 

            # join computer to Azure again

            "Joining $Computer to Azure"

            Write-Verbose "by running: Get-ScheduledTask -TaskName Automatic-Device-Join | Start-ScheduledTask"

           

            Get-ScheduledTask -TaskName "Automatic-Device-Join" | Enable-ScheduledTask | Start-ScheduledTask

            while ((Get-ScheduledTask "Automatic-Device-Join" -ErrorAction silentlyContinue).state -ne "Ready") {

                Start-Sleep 1

                "Waiting for sched. task 'Automatic-Device-Join' to complete"

            }

            if ((Get-ScheduledTask -TaskName "Automatic-Device-Join" | Get-ScheduledTaskInfo | select -exp LastTaskResult) -ne 0) {

                throw "Sched. task Automatic-Device-Join failed. Is $Computer synchronized to AzureAD?"

            }

 

            # check certificates

            "Waiting for certificate creation"

            $i = 30

            Write-Verbose "two certificates should be created in Computer Personal cert. store (issuer: MS-Organization-Access, MS-Organization-P2P-Access [$(Get-Date -Format yyyy)]"

 

            Start-Sleep 3

 

            while (!($hybridJoinCert = Get-ChildItem 'Cert:\LocalMachine\My' | ? { $_.Issuer -match "MS-Organization-Access|MS-Organization-P2P-Access [\d+]" }) -and $i -gt 0) {

                Start-Sleep 3

                --$i

                $i

            }

 

            Write-Host "Syncing to the cloud"

            Get-ScheduledTask | ? {$_.TaskName -eq ‘PushLaunch’} | Start-ScheduledTask

 

Stop-Transcript
# SIG # Begin signature block#Script Signature# SIG # End signature block




