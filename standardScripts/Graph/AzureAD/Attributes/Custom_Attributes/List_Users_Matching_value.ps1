#List all users with a custom security attribute assignment that equals a value

Select-MgProfile -Name "beta"
$userAttributes = Get-MgUser -CountVariable CountVar -Property "id,displayName,customSecurityAttributes" -Filter "customSecurityAttributes/uniqueParentCompany/WorkLocation eq 'Office'" -ConsistencyLevel eventual
$userAttributes | select Id,DisplayName,CustomSecurityAttributes
$userAttributes.CustomSecurityAttributes.AdditionalProperties | Format-List
# SIG # Begin signature block#Script Signature# SIG # End signature block





