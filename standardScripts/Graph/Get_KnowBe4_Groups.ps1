$groups = Get-MGBetaGroup -ConsistencyLevel eventual -Search "DisplayName:KnowBe4" 



ForEach ($group in $groups){
    $groupMembers = Get-MGGroupMember -groupid $group.id -All
    $readableMembers = @()
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
    $readableMembers = $readableMembers | Sort-Object -Property SurName
    $fileNameStart = $group.DisplayNAme.split(":")[0]
    $fileNameEnd = $group.DisplayName.split(":")[1]
    $exportPath = "\\parentCompanyusers\departments\public\Tech-Items\scriptLogs\KnowBe4\$(get-date -format yyyy-MM-dd) $($fileNameStart) $($fileNameEnd).csv"
    $readableMembers | Export-CSV -Path $exportPath
}
SignatureBlock

