$officeusers = Get-DistributionGroupMember -Identity "Taneytown-Office"

ForEach ($officeuser in $officeusers)
{
    
    Write-Host "Updating Mailbox for $($officeuser.name)"
    Get-Mailbox -Identity $officeuser.Name | Set-Mailbox -CustomAttribute1 "Office" -erroraction SilentlyContinue
}
# SIG # Begin signature block#Script Signature# SIG # End signature block



