Select-MgProfile -Name "beta"
$userAttributes = Get-MgUser -UserId $userName@uniqueParentCompany.com -Property "customSecurityAttributes"
$userAttributes.CustomSecurityAttributes.AdditionalProperties | Format-List
$userAttributes.CustomSecurityAttributes.AdditionalProperties.Engineering
$userAttributes.CustomSecurityAttributes.AdditionalProperties.Marketing
# SIG # Begin signature block#Script Signature# SIG # End signature block








