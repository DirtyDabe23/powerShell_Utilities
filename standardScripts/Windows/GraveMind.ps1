Write-Host "Greetings. I am the Monitor of Installation 04. I am 343 Guilty Spark. Someone has released The Flood" -ForegroundColor Cyan
Start-Sleep -Seconds 2
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Loop runs as long as KeyAvailable remains false
while (-not [Console]::KeyAvailable) {
    # Place your recurring script actions here
    Write-Host "~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind" -NoNewline
    Write-Host "~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind" -NoNewline
    Write-Host "~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind" -NoNewline
    Write-Host "~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind~Mind" -NoNewline
    Start-Sleep -Milliseconds 50
}

# Flush the keypress from the console buffer so it doesn't leak into your terminal
$null = [Console]::ReadKey($true) 
Write-Host "`n`n`nNow I Will Speak, and You Will Listen." -ForegroundColor "Green" -BackgroundColor "Black"
