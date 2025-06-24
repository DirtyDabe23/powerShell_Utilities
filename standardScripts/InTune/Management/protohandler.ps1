while(!($protocolHandler)){
$ProtocolHandler = get-item 'HKLM:\SOFTWARE\CLASSES\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    Write-Warning "$(Get-Date -Format "HH:mm") Protocol Handler does not exist."}
start-sleep -Seconds 5}
SignatureBlock

