$NewAcl = Get-Acl -Path (Read-Host -Prompt "Enter the path of the ACL to copy")
# Set properties
$readDomain = Read-Host "Enter the Domain.  `nExample: uniqueParentCompany"
$readUser = Read-Host "Enter the User SAMAccount Name. `nExample: $userName"
$objUser = New-Object System.Security.Principal.NTAccount($readDomain, $readUser)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$identity = $strSID.Value
$fileSystemRights = "ReadAndExecute" , "Synchronize"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path (Read-Host -Prompt "Enter the path of the file to apply the New ALC") -AclObject $NewAcl



# SIG # Begin signature block#Script Signature# SIG # End signature block






