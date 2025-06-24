$groups = Get-MGBetaGroup -ConsistencyLevel eventual -Search "DisplayName:KnowBe4" 



ForEach ($group in $groups){
    $oldRule = $group.membershipRule
    $newRule = $oldRule + $newRulePart
    Update-MGBetaGroup -groupid $group -MembershipRule $newRule 
}
SignatureBlock

