param(
        [Parameter(Position = 0, HelpMessage = "Is this a user who has an existing account at parentCompany East?")]
        [bool]$existingCitrixUser,
        [Parameter(Position = 1, HelpMessage = "Enter the Origin UPN, AKA, their standard account UPN")]
        [string]$originUPN,
        [Parameter(Position = 3 , HelpMessage = "The user's mail nickname")]
        [string]$mailNickName,
        [Parameter(Position = 4 , HelpMessage = "Pass over a string of a Date")]
        [string]$startDate,
        [Parameter(Position = 5, HelpMessage = "Pass over the displayName of the user")]
        [string]$displayName,
        [Parameter(Position = 6, HelpMessage = "Pass over the givenName of the user")]
        [string]$firstName,
        [Parameter(Position = 7, HelpMessage = "Pass over the surName of the user")]
        [string]$lastName
)

$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
Import-Module Orchestrator.AssetManagement.Cmdlets -ErrorAction SilentlyContinue
Import-module Az.Accounts
Import-Module Az.KeyVault
Connect-AzAccount -subscription 'azSubsription' -Identity
Connect-MGGraph -Identity -NoWelcome
$localADAdmin = Get-AutomationPSCredential -Name "Credential"
Write-Output "The Credential is: $localADAdmin"
Write-Output "The Credential - UserName is $($localADAdmin.Username)"
Write-Output "The Credential - Password is $($localADAdmin.Password)"
$userName               =   $localADAdmin.UserName
$securePassword         =   $localADAdmin.Password
$password               =   $localADAdmin.GetNetworkCredential().Password
$password | Out-Null
$myPsCred               =   New-Object System.Management.Automation.PSCredential ($userName,$securePassword)
$mailNN                 =   $mailNickName
$emailAddr              =   $originUPN 
#Doclink and Citrix User Adds Get Done Here
#SAM Account Names have a requirement to be sub 20 characters, otherwise it fails. 
If ($mailNN.length -gt 20){
    $acctSAMName        =   $mailNN.substring(0,20)
}
Else{
    $acctSAMName        =   $mailNN
}

$compuDataGroup1    =   Get-ADGroup -Identity "Citrix Cloud W11M Desktop Users" -server 'Domain.extension1' -credential $myPsCred
$compuDataGroup2    =   Get-ADGroup -Identity "DocLink Users" -Server 'Domain.extension1' -credential $myPsCred

if (!($existingCitrixUser)){
    $date               =   get-date $startDate
    $DoW                =   $date.DayOfWeek.ToString()
    $Month              =   (Get-date $date -format "MM").ToString()
    $Day                =   (Get-date $date -format "dd").ToString()
    $pw                 =   $DoW+$Month+$Day+"!"
    $password           =   ConvertTo-SecureString -string "$pw" -AsPlainText -Force

    $compuDataUPN       =   $emailAddr.Split('@')[0] +"@Domain.extension1"
    #Create the new user here 
    New-ADUser -Enabled $true `
    -name $displayName `
    -Country "US" `
    -DisplayName $displayName `
    -UserPrincipalName $compuDataUPN `
    -OfficePhone "14107562600" `
    -Company "Not Affiliated" `
    -Title "DocLink User"`
    -AccountPassword $password `
    -Department "Service Account" `
    -GivenName $firstName `
    -Office "parentCompany East" `
    -Path "OU=CompuData - External Sage Users - Non-Synching,DC=parentCompany,DC=COM" `
    -Surname $lastName `
    -Server "Domain.extension1" `
    -EmailAddress $emailAddr `
    -ChangePasswordAtLogon  $true `
    -SamAccountName $acctSAMName -credential $myPsCred -erroraction Stop
}
else{
    Write-Output "ExisitingUser: $existingUser"
}
Add-ADGroupMember -identity $compuDataGroup1 -members $acctSAMName -server 'Domain.extension1' -credential $myPsCred
Add-ADGroupMember -identity $compuDataGroup2 -members $acctSAMName -server 'Domain.extension1' -credential $myPsCred
SignatureBlock

