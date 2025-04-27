$userOOO = Read-Host -Prompt "Enter the email address of the user who will be out of the office"
Set-MailboxAutoReplyConfiguration -Identity $userOOO -AutoReplyState Enabled
# SIG # Begin signature block#Script Signature# SIG # End signature block




