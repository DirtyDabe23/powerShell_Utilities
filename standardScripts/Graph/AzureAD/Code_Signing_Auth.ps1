#Connect via the App Registration
$SecurePassword = Read-Host -Prompt 'Enter a Password' -AsSecureString
$TenantId = '9e228334-bae6-4c7e-8b7f-9b0824082151'
$ApplicationId = 'd8eb3ee1-5a22-461c-a5ac-da204ae20f74'
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential

#Connect via the Managed Identity:

# SIG # Begin signature block#Script Signature# SIG # End signature block



