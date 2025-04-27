Write-Host "Ensure that use an account with the correct permissions for Exchange Online and SharePoint Online!"
Connect-ExchangeOnline
$SPOSite = Read-Host -Prompt "Enter the name of the SharePoint Online Site you would like to manipulate"
Connect-SPOService -Url $SPOSite 

$type = Read-Host -prompt "Enter 1 for Dynamic Distribution Groups, 2 for a Regular Distribution Group"
$DistroMembers = Read-Host -Prompt "Enter the name of the distribution group that you would like to add to the sharepoint site"



if ($type -eq 1)
{
    try
    {
    $usersEmail = (Get-DynamicDistributionGroupMember -Identity $DistroMembers).PrimarySMTPAddress
    }
    catch
    {
     Write-Host "Error with attempting to retrieve the group membership"
    }

}


if ($type -eq 2)
{

    try
    {
    $usersEmail = (Get-DistributionGroupMember -Identity $DistroMembers).PrimarySMTPAddress
    }
    catch
    {
    Write-Host "Error with attempting to retrieve the group membership"
    }


}


$groupMem = Read-Host -Prompt "Enter the SharePoint Group to add the users into!"

ForEach ($user in $usersEmail)
{
    Try
    {
    Add-SPOUser -site $SPOSite -LoginName $user -Group $groupMem -ErrorAction stop
    }
    Catch
    {
    Write-Host "Error adding $user to Site: $SPOSite Group: $groupMem!"
    }
}





# SIG # Begin signature block#Script Signature# SIG # End signature block



