#Connect via the App Registration
$SecurePassword = Read-Host -Prompt 'Enter a Password' -AsSecureString
$TenantId = 'graphTenantID'
$ApplicationId = 'd8eb3ee1-5a22-461c-a5ac-da204ae20f74'
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential

#Connect via the Managed Identity:

# SIG # Begin signature block#Script Signature# SIG # End signature block




