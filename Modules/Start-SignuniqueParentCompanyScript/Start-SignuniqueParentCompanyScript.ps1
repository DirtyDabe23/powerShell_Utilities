function Start-SignuniqueParentCompanyPsScript {
    <#
    .SYNOPSIS
    This script will sign all of the PowerShell Scripts listed at a provided path.
    
    .DESCRIPTION
    This script will sign all of the PowerShell Scripts listed at a provided path.
    You must have permissions to access the Key Vault in order to access the required secrets.

    
    .PARAMETER Path
    Enter a path to the directory which contains the scripts:
    C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\* 
    
    .EXAMPLE
    #Sign all the PowerShell Scripts that are stored under C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\DDrosdick Scripts\*
    Start-SignuniqueParentCompanyPSsScript 

    #Sign all the PowerShell Scripts that are stored at C:\Temp
    Start-SignuniqueParentCompanyPSsScript -Path "C:\Temp"
    .NOTES
    This is for signing all scripts that either need a new signature as they have been updated, have never been signed, or have their certificate expired.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, HelpMessage = "Enter the path of the script to sign, or use \* to sign a wildcarded directory.",ValueFromPipelineByPropertyName)]
        [string[]]$Path = "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - Documents\General\Powershell Scripts\GIT-PowerShell\*"
    )
    [PSCustomObject] $output = @()
    
    $AzContext = Get-AzContext  
    if ($null -eq $AzContext){
        Connect-AzAccount -Subscription $subscriptionID
    }
    If ($null -eq $codeSigningSecret){
        try{
            $codeSigningSecret = get-azkeyvaultsecret -vaultname PREFIX-VAULT -Name codeSigner -AsPlainText -erroraction SilentlyContinue
        }
        Catch{
            Throw "Failed to retrieve the secret"
            Continue
        }
    }
    $TenantId = 'graphTenantID'
    $ApplicationId = 'd8eb3ee1-5a22-461c-a5ac-da204ae20f74'
    $vaultURI = "https://git-dev.vault.azure.net/"
    $certName = "GIT-CSC-2024"
    If (Test-Path -Path $Path){
        "*.ps1","*.psm1" | ForEach-Object{
            Get-ChildItem -Path $Path -filter $_  -Recurse | ForEach-Object {
                If ((Get-AuthenticodeSignature -FilePath $_.FullName).status -ne "Valid"){
                    $script = “$($_.FullName)"
                    $successString = $response | Select-String -Pattern 'Successful Operations: [0-9]+' -raw
                    $response = azuresigntool sign -kvu "$vaultURI" -kvc $certName -kvi $applicationID -kvs "$codeSigningSecret" --azure-key-vault-tenant-id "$TenantID" -tr http://timestamp.globalsign.com/tsa/advanced -td sha256 “$($_.FullName)"
                    $successString = $response | Select-String -Pattern 'Successful Operations: [0-9]+' -raw
                    if($successString){
                        $successCount = [int] $successString.split(':')[1]
                    }
                    $failedString = $response | Select-String -Pattern 'Failed Operations: [0-9]+' -raw
                    if($failedString){
                        $failedCount = [int] $failedString.Split(':')[1]
                    }
                    
                    if ($failedCount -ne 0){
                        if($successCount -ne 0){
                            $status = "Mixed"
                        }
                        else{
                            $status = "Failed"
                        }
                    }
                    else{
                        if ($succesCount -ne 0){
                            $status = "Successful"
                        }
                        else{
                            $status = "Error"
                        }
                    }
                    $now = Get-DAte -Format "yyyy-MM-dd HH:mm"
                    $output +=[PSCustomObject]@{
                        timeOfSign      =   $now
                        status          =   $status
                        script          =   $script
                    }

                }
            }
        }
    }
    Else{
        Throw "Invalid Path"
        Continue
    }
        return $output
}
# SIG # Begin signature block#Script Signature# SIG # End signature block








