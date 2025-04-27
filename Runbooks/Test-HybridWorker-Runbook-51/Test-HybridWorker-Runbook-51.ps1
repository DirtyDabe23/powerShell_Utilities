param(
    [string]$Key
)


#onPremConnection and Data Review
try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $workerSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "TTWorker" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
$password = ConvertTo-SecureString $workerSecret -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("$userNameAdmin@uniqueParentCompany.com", $password)
Get-ADUSEr -Server "uniqueParentCompany.com" -Identity "Pudge.Drosdick" -Credential $cred
# SIG # Begin signature block#Script Signature# SIG # End signature block







