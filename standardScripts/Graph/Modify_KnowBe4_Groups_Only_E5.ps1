$groups = Get-MGBetaGroup -ConsistencyLevel eventual -Search "DisplayName:KnowBe4" 



ForEach ($group in $groups){
    $oldRule = $group.membershipRule
    $newRule = $oldRule + $newRulePart
    Update-MGBetaGroup -groupid $group -MembershipRule $newRule 
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




