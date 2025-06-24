$userOOO = Read-Host -Prompt "Enter the email address of the user who needs out of office reset"
Set-MailboxAutoReplyConfiguration -Identity $userOOO -AutoReplyState Disabled
SignatureBlock

