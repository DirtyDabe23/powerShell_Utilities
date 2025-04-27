$secGroups = import-csv -path C:\temp\International_KnoBe4.csv

ForEach ($secGroup in $secGroups)
{
New-MGGroup -DisplayName $secGroup.GroupName -MailEnabled:$false  -securityenabled -membershipRule $secgroup.DynamicRule -MailNickname $secGroup.mailNN -GroupTypes DynamicMembership -MembershipRuleProcessingState On
}

$secGroups = import-csv -path C:\temp\International_KnoBe4.csv

ForEach ($secGroup in $secGroups)
{
 $groupID = (Get-MGGroup -search "DisplayName: $($secGroup.GroupName)" -ConsistencyLevel eventual).id
 Remove-MGGroup -GroupId $groupID -WhatIf
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





