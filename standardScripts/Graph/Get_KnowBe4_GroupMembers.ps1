$groups = Get-MGBetaGroup -ConsistencyLevel eventual -Search "DisplayName:KnowBe4" 

$readableMembers = @()

ForEach ($group in $groups){
    $groupMembers = Get-MGGroupMember -groupid $group.id -All
    ForEach ($groupMember in $groupMembers)
    {
        $user = Get-MGBetaUser -userid $groupMEmber.ID
        $readableMembers += [PSCustomObject]@{
            FirstName           = $user.GivenName
            SurName             = $user.Surname
            DisplayName         = $user.DisplayName
            UserPrincipalName   = $user.UserPrincipalName
            OfficeLocation      = $user.OfficeLocation
            Department          = $user.Department  
            Group               = $group.DisplayName 
        }
    }
 
}
$readableMembers = $readableMembers | Sort-Object -Property SurName
$exportPath = "\\uniqueParentCompanyusers\departments\public\Tech-Items\scriptLogs\KnowBe4\$(get-date -format yyyy-MM-dd) AllKnowBe4Users.csv"
$readableMembers | Export-CSV -Path $exportPath
# SIG # Begin signature block#Script Signature# SIG # End signature block




