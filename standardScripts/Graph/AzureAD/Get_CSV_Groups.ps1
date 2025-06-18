$groups = Import-Csv -Path C:\Temp\GroupsToCollect.csv 
ForEach ($group in $groups)
    { 
    Write-Host "Name: " $group.Name
    $gname = $group.Name 
    $groupID = Get-AzureADGroup -SearchString $group.name
    Write-Host "GroupID: " $groupID.objectID
    $GID = $groupID.objectID 
    Get-AzureADGroupMember -ObjectId $GID | Export-CSV -Path C:\Temp\$gName.CSV
    }

# SIG # Begin signature block#Script Signature# SIG # End signature block



