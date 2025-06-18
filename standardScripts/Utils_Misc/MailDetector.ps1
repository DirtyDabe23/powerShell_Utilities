$emailDetector = 0
while ($emailDetector -le 1)
    {
    If (!(Get-Exomailbox -identity "$userName@uniqueParentCompany.com" -ErrorAction SilentlyContinue))
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
# SIG # Begin signature block#Script Signature# SIG # End signature block





