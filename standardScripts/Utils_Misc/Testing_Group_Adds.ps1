$gname = "Taneytown-Shop"
$groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
$userObjID = (Get-MGUser -UserID "$userName@uniqueParentCompany.com").ID
        try 
            {
            New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID
            } 
        catch 
            {
            Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
            Add-DistributionGroupMember -Identity $uData.customfield_10772 -member $emailAddr -BypassSecurityGroupManagerCheck
            }
            

#otherattempt

try {
    New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID
} catch {
    $errorRecord = $_.Error[0]

    if ($errorRecord.Exception.Message -like '*Cannot Update a mail-enabled security groups and or distribution list.*') {
        Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."

        try {
            Add-DistributionGroupMember -Identity $groupObjID -Member $userObjID -BypassSecurityGroupManagerCheck
        } catch {
            Write-Host "Unable to add $emailAddr to '$($uData.customfield_10772)'. Please do this manually."
        }
    } else {
        Write-Host "An error occurred while adding the user to the Azure AD group."
        # Handle any other errors or perform additional error handling if needed.
    }
}

#thefuckitmethod
New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID
Add-DistributionGroupMember -Identity $groupObjID -Member $userObjID -BypassSecurityGroupManagerCheck




If(!(Get-DistributionGroup -Identity $groupObjID))
		{
			Add-MGGroupMember
		}
		Else
		{
			Add-DistributionGroupMember
		}

Write-Host "$($udata.customfield_10772)"



#TryingwithErrorAction

   $gname = "Taneytown-Shop"
        $groupObjID = (Get-MGGroup -Search "displayname:$gname" -ConsistencyLevel:eventual -top 1).ID
        $userObjID = (Get-MGUser -UserID $userName@uniqueParentCompany.com).ID
        try 
            {
            New-MGGroupMember -GroupId $groupObjID -DirectoryObjectId $userObjID -erroraction stop
            } 
        catch 
            {
            Write-Host "An error occurred while adding the user to the Azure AD group. Trying to add to the distribution group instead."
            try
                {
                Add-DistributionGroupMember -Identity $groupObjID -member $userObjID -BypassSecurityGroupManagerCheck
                }
            catch
                {
                Write-Host "Unable to add $emailAddr to "$uData.customfield_10772". Please do this manually."
                }
            }
# SIG # Begin signature block#Script Signature# SIG # End signature block





