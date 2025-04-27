$NewAcl = Get-Acl -Path (Read-Host -Prompt "Enter the path of the ACL to copy")
# Set properties
$groupName = Read-Host -Prompt "Enter the group name to apply their rights to read the files"
$identity = (Get-ADGroup -Filter "Name -eq '$groupName'").SID
$fileSystemRights = "ReadAndExecute" , "Synchronize"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path (Read-Host -Prompt "Enter the path of the file to apply the New ALC") -AclObject $NewAcl



# SIG # Begin signature block#Script Signature# SIG # End signature block




