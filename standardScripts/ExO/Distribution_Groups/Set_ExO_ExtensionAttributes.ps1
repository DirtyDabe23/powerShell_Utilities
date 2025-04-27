$shopUsers = Get-DistributionGroupMember -Identity "Taneytown-Shop"

ForEach ($shopUser in $shopUsers)
{
    
    Write-Host "Updating Mailbox for $($shopUser.name)"
    Get-Mailbox -Identity $shopUser.Name | Set-Mailbox -CustomAttribute1 "Shop" -erroraction SilentlyContinue
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



