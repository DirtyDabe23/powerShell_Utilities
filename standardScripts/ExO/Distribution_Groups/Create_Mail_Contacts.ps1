$allMailboxes = $null
Write-Output "Pulling all Mailboxes"
$allMailboxes = Get-Mailbox -ResultSize unlimited
Write-Output "Pulling all Mail Contacts"
$allMailboxes += Get-MailContact -ResultSize Unlimited
[int] $newCount = 0
[int] $alreadyExists = 0

Write-Output "Pulling Distro Group Members"
$ESOP = Import-CSV -Path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP.csv"
$PSIP = Import-CSV -Path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\PSIP.csv"
$Both = Import-CSV -Path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP-PSIP.csv"

$user = $null
$email = $null
$dispName = $null


Write-Output "Evaluating ESOP"
ForEach($user in $ESOP)
{
    $email = $user.EmailAddress
    $dispName = $user.Name 
    #If User does not exist in MGGraph
    If ($allMailboxes.EmailAddresses -like "*$email*") 
    {
        Write-Output "$email : Detected in Mailboxes or Contacts"
        $alreadyExists++
    }
    Else
    {
        Write-Output "Creating Mail Contact $dispName / $email"c
        New-MailContact -Name $dispName -ExternalEmailAddress $email -erroraction Inquire
        $mailContact = Get-MailContact -Name $dispName -erroraction Inquire
        Set-MailContact -identity $mailContact -HiddenFromAddressListsEnabled $true -erroraction Inquire
        $newCount++
        }
}
        
        


$user = $null
$email = $null
$dispName = $null
#$allMailboxes = $null
Write-Output "Re-Fetching Mailboxes and Contacts"
#$allMailboxes = Get-Mailbox -ResultSize unlimited 
#$allMailboxes += Get-MailContact -ResultSize Unlimited


Write-Output "Evaluating PSIP"
ForEach($user in $PSIP)
{
    $email = $user.EmailAddress
    $dispName = $user.Name 
    #If User does not exist in MGGraph
    If ($allMailboxes.EmailAddresses -like "*$email*") 
    {
        Write-Output "$email : Detected in Mailboxes or Contacts"
        $alreadyExists++
    }
    Else
    {
        Write-Output "Creating Mail Contact $dispName / $email"
        New-MailContact -Name $dispName -ExternalEmailAddress $email -erroraction Inquire
        $mailContact = Get-MailContact $dispName -erroraction Inquire
        Set-MailContact -identity $mailContact -HiddenFromAddressListsEnabled $true -erroraction Inquire
        $newCount++
        }
}

$user = $null
$email = $null
$dispName = $null
#$allMailboxes = $null
Write-Output "Re-Fetching Mailboxes and Contacts"
#$allMailboxes = Get-Mailbox -ResultSize unlimited 
#$allMailboxes += Get-MailContact -ResultSize Unlimited

Write-Output "Evaluating ESOP + PSIP"
ForEach ($user in $Both)
{
    $email = $user.EmailAddress
    $dispName = $user.Name 
    #If User does not exist in MGGraph
    If ($allMailboxes.EmailAddresses -like "*$email*") 
    {
        Write-Output "$email : Detected in Mailboxes or Contacts"
        $alreadyExists++
    }
    Else
    {
        Write-Output "Creating Mail Contact $dispName / $email"
        New-MailContact -Name $dispName -ExternalEmailAddress $email -erroraction Inquire
        $mailContact = Get-MailContact $dispName -erroraction Inquire
        Set-MailContact -identity $mailContact -HiddenFromAddressListsEnabled $true -erroraction Inquire
        $newCount++
        }
}


#Example Test Command to verify operability 
#New-MailContact -Name "David Drosdick" -ExternalEmailAddress "DDrosdick23@gmail.com" | Set-MailContact  -HiddenFromAddressListsEnabled $true
# SIG # Begin signature block#Script Signature# SIG # End signature block





