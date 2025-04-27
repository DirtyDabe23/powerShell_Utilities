param(
    [Parameter (Position = 0, HelpMessage = "Enter the Jira Key, Example: GHD-44619")]
    [string]$Key,
    [Parameter(Position = 1 , HelpMessage = "The Ticket Parameters should be passed off here")]
    [PSCustomObject]$originParametersUser,
    [Parameter(Position = 2 , HelpMessage = "The Ticket Parameters should be passed off here")]
    [PSCustomObject]$originParametersObject,
    [Parameter(Position = 3 , HelpMessage = "Pass along a credential object")]
    [string] $originHybridWorkerCred,
    [Parameter(Position = 4 , HelpMessage = "Enter the UPN of the user to modify")]
    [String] $currentUserID,
    [Parameter(Position = 5 , HelpMessage = "Binary Switch for if the user is synching or not")]
    [Boolean] $originSynching
)
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
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
Import-module Az.Accounts
Import-Module Az.KeyVault
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-AzAccount -subscription $subscriptionID -Identity
#Connect to: Graph / Via: Secret
#The Tenant ID from App Registrations
$graphTenantId = $tenantIDString

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"

#The Client ID from App Registrations
$graphAppClientId = $appIDString

$graphRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-VAULT" -Name "$graphSecretName" -AsPlainText

# Construct the body to be used in Invoke-WebRequest
$graphAuthBody = @{
    client_id     = $graphAppClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret =  $graphRetrSecret
    grant_type    = "client_credentials"
}

# Get Authentication Token
$graphTokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAuthBody -UseBasicParsing

# Extract the Access Token
$graphSecureToken = ($graphTokenRequest.content | convertfrom-json).access_token | ConvertTo-SecureString -AsPlainText -force
Write-Output "Attempting to connect to Graph"
Connect-MgGraph -NoWelcome -AccessToken $graphSecureToken -ErrorAction Stop
Write-Output "The Basic Parameters are as follows:"
Write-Output "originSynching: $originSynching"
Write-Output "originHybridWorkerCredentialObject: $originHybridWorkerCred"
Write-Output "currentUserID: $currentUserID"

Write-Output "`n`n`nThe complex Parameters are as follows:"

Write-Output "The Variable Name: $`originParametersUser"
Write-Output "The Variable Type: $($originParametersUser.GetType())"
Write-Output "The Variable Value: $originParametersUser"
$originParametersUser | Select-Object * | Format-List

Write-Output "The Variable Name: $`originParametersObject"
Write-Output "The Variable Type: $($originParametersObject.GetType())"
Write-Output "The Variable Value: $originParametersObject"
$originParametersObject | Select-Object * | Format-List


$paramsForRunbookUserHashTable = @{}
if ($originParametersUser.GetType().Name -eq 'String'){
    $string = $originParametersUser
    $stringNOLeft = $originParametersUser.replace('{','')
    $stringNoBrackets = $stringNOLeft.replace('}','')
    $splits = $stringNoBrackets.Split(",")
    ForEach ($split in $splits){
    $splitKey = $split.split(":")[0].replace("~",",").replace('"',"")
    $splitValue = $split.split(":")[1].replace("~",",").replace('"',"")
     $paramsForRunbookUserHashTable.add($splitKey,$splitValue)
    }
 }

 [PSCustomObject]$userObject = $paramsForRunbookUserHashTable | convertTO-JSON | convertFrom-JSON

$adObjectHashTable = @{}
if ($originParametersObject.GetType().Name -eq 'String'){
    $string = $originParametersObject
    $stringNOLeft = $string.replace('{','')
    $stringNoBrackets = $stringNOLeft.replace('}','')
    $splits = $stringNoBrackets.Split(",")
    ForEach ($split in $splits){
     $splitKey = $split.split(":")[0].replace("~",",").replace('"',"")
     $splitValue = $split.split(":")[1].replace("~",",").replace('"',"")
     $adObjectHashTable.add($splitKey,$splitValue)
    }
 }
 [PSCustomObject]$adObjectObject = $adObjectHashTable | ConvertTo-JSON | ConvertFrom-JSON

Write-Output "The Generated Parameters are as Follows:"

Write-Output "The Variable Name: `$userObject"
Write-Output "The Variable Type: $($userObject.GetType())"
Write-Output "The Variable Value: $userObject"
$userObject | Format-Table

Write-Output "The Variable Name: `$adObjectObject"
Write-Output "The Variable Type: $($adObjectObject.GetType())"
Write-Output "The Variable Value: $adObjectObject"

$adObjectObject | Format-Table



switch ($originSynching) {
    $true {
        $localADAdmin = Get-AutomationPSCredential -Name $originHybridWorkerCred
        Write-Output "The Credential is: $localADAdmin"
        Write-Output "The Credential - UserName is $($localADAdmin.Username)"
        Write-Output "The Credential - Password is $($localADAdmin.Password)"

        $userName = $localADAdmin.UserName
        $securePassword = $localADAdmin.Password
        $password = $localADAdmin.GetNetworkCredential().Password
        $password | Out-Null
        $Cred = New-Object System.Management.Automation.PSCredential ($userName,$securePassword)
        $originLocalUser = Get-ADUser -identity "$($userObject.Identity)" -server $userObject.Server -Credential $Cred -properties * | Select-Object -Property *
        Write-Output "The Origin Local User is $($originLocalUser.displayName)"
        Set-ADUser -Identity $originLocalUser.DistinguishedName -Clear 'mS-DS-ConsistencyGuid' -Credential $Cred
        $originLocalUser = Get-ADUser -identity $originLocalUser.SAMAccountName -properties * | Select-Object -Property *
        Move-ADObject -Identity $originLocalUser.DistinguishedName -server $adObjectObject.server -TargetPath $adObjectObject.TargetPath -Credential $Cred
        Start-Sleep -Milliseconds "400" 
        Invoke-uniqueParentCompanySync -SyncServerCred $cred
        $graphUserExists = $true 
        While ($graphUserExists){
            $removingGraphUser = Get-MGBetaUser -userid $currentUserID -erroraction silentlycontinue
            invoke-command -ComputerName PREFIX-VS-AADC01.uniqueParentCompany.com -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -credential $cred -erroraction silentlycontinue
            if ($removingGraphUser){Write-output "Waiting for $currentUserID to be removed"
                Start-Sleep -Seconds 5
                $removingGraphUser = $null
            }
            else{
                Write-Output "$currentUserID is ready for restoration"
                $graphUserExists = $false
            }
        }
        Write-Output "Starting the Restoration Runbook"
        
    }
    Default {
        $null
    }
}


# SIG # Begin signature block#Script Signature# SIG # End signature block









