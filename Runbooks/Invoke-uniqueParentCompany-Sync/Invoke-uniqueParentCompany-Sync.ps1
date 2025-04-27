function Invoke-uniqueParentCompanySync{
        [CmdletBinding()]
        param(
        [Parameter(Position = 2, HelpMessage = "Enter the name of the sever that syncs devices. Example: PREFIX-VS-AADC01.uniqueParentCompany.com`n`nEnter")]
        [string] $syncServer = "PREFIX-VS-AADC01.uniqueParentCompany.com",
        [Parameter(Position=3,HelpMessage ="Create a PSCredential, and pass it to this variable, for an account that has the required permissions to invoke a sync",Mandatory = $true)]
        [System.Management.Automation.Credential()]
        [PSCredential]$SyncServerCred
        )
        #Ensures you aren't going to wait over 5 minutes for a sync, if it takes over 5 minutes, something is wrong.
        $waitedTime = 0
        try{
            Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -credential $SyncServerCred -erroraction Stop
            Write-Output "Sync started! It can take up to 5 minutes to apply"
        }
        catch{
            $busySync = $true
            while (($busySync -eq $true) -and ($waitedTime -lt 50))
            {
                $syncErrorMessage = ($error[0] | Select-Object exception).exception
                If (Select-String -InputObject $syncErrorMessage -Pattern "The user name or password is incorrect.")
                {
                    Write-Output "Your entered credentials are invalid!"
                    Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $SyncServerCred -erroraction Stop
                }
                else
                {
                    Write-Output "Waiting 6 seconds for Sync to Finish at $(Get-Date -Format HH:mm:ss)"
                    $waitedTime++
                    Start-Sleep -Seconds 6
                    $syncResult = Invoke-Command -ComputerName $syncServer -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -Credential $SyncServerCred -ErrorAction SilentlyContinue
                    Write-OUtput "The Sync Result Is $($syncResult.Result)"
                    if ($syncResult.Result -eq "Success")
                    {
                        $busySync = $false
                    }
                }
            }
            if($waitedTime -eq 50){Write-Output "Somethning is wrong with the sync."}
            else{Write-Output "Sync ran at $(Get-Date -Format HH:mm:ss), it will take up to 5 minutes for all changes to replicate"}
        }
}

$syncServerCred = Get-AutomationPSCredential -Name 'Testing-TT-Credential'
Invoke-uniqueParentCompanySync -syncServerCred $syncServerCred

# SIG # Begin signature block#Script Signature# SIG # End signature block





