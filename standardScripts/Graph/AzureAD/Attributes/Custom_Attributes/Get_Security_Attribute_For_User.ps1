Select-MgProfile -Name "beta"
$userAttributes = Get-MgUser -UserId david.drosdick@Domain.extension1 -Property "customSecurityAttributes"
$userAttributes.CustomSecurityAttributes.AdditionalProperties | Format-List
$userAttributes.CustomSecurityAttributes.AdditionalProperties.Engineering
$userAttributes.CustomSecurityAttributes.AdditionalProperties.Marketing
SignatureBlock

