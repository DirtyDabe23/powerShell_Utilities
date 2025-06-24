#List all users with a custom security attribute assignment that equals a value

Select-MgProfile -Name "beta"
$userAttributes = Get-MgUser -CountVariable CountVar -Property "id,displayName,customSecurityAttributes" -Filter "customSecurityAttributes/parentCompany/WorkLocation eq 'Office'" -ConsistencyLevel eventual
$userAttributes | select Id,DisplayName,CustomSecurityAttributes
$userAttributes.CustomSecurityAttributes.AdditionalProperties | Format-List
SignatureBlock

