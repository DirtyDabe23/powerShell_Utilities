[int] $newCount = 0
[int] $alreadyExists = 0

Write-Output "Pulling Distro Group Members"
$IL_Employees = Import-CSV -Path "C:\Temp\IL_Employees.csv"
$EE_Employees = Import-CSV -Path "C:\Temp\EE_Employees.csv"
$allDistros = $EE_Employees + $IL_Employees

$allDistros = $allDistros | Sort-object -property EmailAddress

$user = $null
$email = $null
$dispName = $null


Write-Output "Performing Main Operation"
ForEach($user in $allDistros)
{
    $email = $user.EmailAddress
    $dispName = $user.Name
    
    If ($email.length -ne 0)
    {
    #If User does not exist in MGGraph
    If(!(Get-Mailbox -identity $email -erroraction SilentlyContinue))
    {
        If (!(Get-MailContact -Identity $email -erroraction SilentlyContinue))
        {
            Write-Output "Creating Mail Contact $dispName / $email"
            New-MailContact -Name $dispName -ExternalEmailAddress $email -erroraction Inquire | Out-Null
            Set-MailContact -identity $email -HiddenFromAddressListsEnabled $true -erroraction Inquire | Out-Null
            $newCount++
        }
        Else
        {
            Write-Output "$email : Detected in Contacts"
            $alreadyExists++
        }
    }
        Else
        {
            Write-Output "$email : Detected in Mailboxes"
            $alreadyExists++
        }
    }
        
}  


$user = $null
$email = $null
$dispName = $null



#Example Test Command to verify operability 
#New-MailContact -Name "David Drosdick" -ExternalEmailAddress "DDrosdick23@gmail.com" | Set-MailContact  -HiddenFromAddressListsEnabled $true
# SIG # Begin signature block#Script Signature# SIG # End signature block



