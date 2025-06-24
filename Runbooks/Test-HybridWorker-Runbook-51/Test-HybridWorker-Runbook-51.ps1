param(
    [string]$jiraTicket
)


#onPremConnection and Data Review
try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $workerSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "TTWorker" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
$password = ConvertTo-SecureString $workerSecret -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("David.DrosdickAdmin@Domain.extension1", $password)
Get-ADUSEr -Server "Domain.extension1" -Identity "Pudge.Drosdick" -Credential $cred
SignatureBlock

