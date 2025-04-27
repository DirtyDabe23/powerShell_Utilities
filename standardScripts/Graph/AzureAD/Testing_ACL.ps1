#This will remove inheritance from the top level, but will retain it downlevel. 
$NewACL = Get-ACL -Path \\PREFIX-VS-FS01\Global\
$isProtected = $true
$preserveInheritance = $true
$NewAcl.SetAccessRuleProtection($isProtected, $preserveInheritance)
Set-Acl -Path "C:\Temp\ACL_TextFile2.txt" -AclObject $NewAcl

#This is to add the ability for 'Full Control' to the Built in Administrators
$NewAcl = Get-Acl -Path \\PREFIX-VS-FS01\Global\
# Set properties
$identity = "uniqueParentCompany\$userNameadmin"
$fileSystemRights = "ReadAndExecute","Synchronize"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "C:\Temp\ACL_TextFile2.txt" -AclObject $NewAcl
# SIG # Begin signature block#Script Signature# SIG # End signature block







