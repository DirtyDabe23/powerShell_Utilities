$user = Get-ADUser (Read-Host -Prompt "Enter the SAM Account Name of the user to fix")
Set-ADUser $user -add @{"extensionAttribute14"="Compliant"}
Get-ADUSer $user -properties * | select samaccountname , extensionAttribute14

SignatureBlock

