$emailDetector = 0
while ($emailDetector -le 1)
    {
    If (!(Get-Exomailbox -identity "david.drosdick@Domain.extension1" -ErrorAction SilentlyContinue))
        {
            Write-Host "Mailbox does not exist yet. Waiting 10 seconds"
            Start-Sleep -Seconds 10
        }
    Else
        {
            Write-Host "Mailbox has been created. Moving onto Group Assignment."
            $emaildetector = 10
        }
    }
SignatureBlock

