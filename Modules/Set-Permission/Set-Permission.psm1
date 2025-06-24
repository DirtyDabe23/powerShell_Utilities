function Set-Permission {
    <#
    .SYNOPSIS
    Sets permissions on a specified file or directory.
    .DESCRIPTION
    This function allows you to set specific permissions for a user on a given file or directory.
    It can either copy permissions from a source path or set specific permissions manually.
    .COMPONENT
    FileSystem
    .PARAMETER Path
    The path to the file or directory where permissions will be set.
    .PARAMETER SourcePath
    The source path to copy permissions from (Auto parameter set).
    .PARAMETER User
    The user or group to whom the permissions will be granted (Manual parameter set).
    .PARAMETER Permissions
    An array of permissions to be granted (Manual parameter set).
    .PARAMETER Inherit
    If true, permissions will be inherited by child items. Default is false.
    .PARAMETER PreserveExistingAccess
    If true, existing permissions will be preserved when setting new ones. Default is true.
    .PARAMETER ReplaceAll
    If true, all existing permissions will be replaced. Default is false (adds to existing).
    .EXAMPLE
    Set-Permission -Path "C:\Temp\MyFile.txt" -User "DOMAIN\User" -Permissions "Read", "Write"
    .EXAMPLE
    Set-Permission -Path "C:\Temp\MyFolder" -SourcePath "C:\Template\Folder"
    .NOTES
    Ensure you run this script with appropriate permissions to modify ACLs.
    #>
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the path to the file or directory that requires the update to the ACL.")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Specify the source path to copy ACL from.", ParameterSetName = "Auto")]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Specify the user or group to set permissions for.", ParameterSetName = "Manual")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^[a-zA-Z0-9_.-]+\\[a-zA-Z0-9_.-]+$")]
        [string]$User,
        [ValidateSet("ListDirectory", "ReadData", "CreateFiles", "WriteData", "AppendData", "CreateDirectories", "ReadExtendedAttributes", "WriteExtendedAttributes", 
        "ExecuteFile", "Traverse", "DeleteSubDirectoriesAndFiles", "ReadAttributes", "WriteAttributes", "Write", "Delete", "ReadPermissions", "Read",
        "ReadAndExecute", "Modify", "ChangePermissions", "TakeOwnership", "Synchronize", "FullControl")]        
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Specify the permissions to set.", ParameterSetName = "Manual")]
        [string[]]$Permissions,
        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "If true, permissions will inherit to child items. Default is false.")]
        [bool]$Inherit = $false,
        [Parameter(Mandatory = $false, Position = 4, HelpMessage = "If true, preserves existing ACL rules. Default is true.")]
        [bool]$PreserveExistingAccess = $true,
        [Parameter(Mandatory = $false, HelpMessage = "If true, replaces all existing permissions. Default is false (adds to existing).")]
        [bool]$ReplaceAll = $false
    )
    
    # Validate paths exist
    if (-not (Test-Path -Path $Path)) {
        Write-Warning "Specified path '$Path' does not exist."
        throw "Path not found: $Path"
    }
    
    if ($PSCmdlet.ParameterSetName -eq "Auto" -and -not (Test-Path -Path $SourcePath)) {
        Write-Warning "Specified source path '$SourcePath' does not exist."
        throw "Source path not found: $SourcePath"
    }
    
    # Get current ACL
    $currentACL = Get-Acl -Path $Path
    
    if ($PSCmdlet.ParameterSetName -eq "Auto") {
        # Copy ACL from source
        Write-Host "Copying permissions from '$SourcePath' to '$Path'"
        $sourceACL = Get-Acl -Path $SourcePath
        
        if ($ReplaceAll) {
            # Replace entire ACL
            Set-Acl -Path $Path -AclObject $sourceACL
        } else {
            # Add source ACL rules to current ACL
            foreach ($accessRule in $sourceACL.Access) {
                $currentACL.SetAccessRule($accessRule)
            }
            Set-Acl -Path $Path -AclObject $currentACL
        }
    } 
    elseif ($PSCmdlet.ParameterSetName -eq "Manual") {
        # Set specific permissions for user
        Write-Host "Setting permissions for '$User' on '$Path'"
        
        # Determine inheritance and propagation flags
        $inheritanceFlags = if ($Inherit) { 
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit 
        } else { 
            [System.Security.AccessControl.InheritanceFlags]::None 
        }
        
        $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
        
        # Convert permissions array to FileSystemRights
        $fileSystemRights = [System.Security.AccessControl.FileSystemRights]::None
        foreach ($permission in $Permissions) {
            $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::$permission
        }
        
        # Create the access rule
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $User,
            $fileSystemRights,
            $inheritanceFlags,
            $propagationFlags,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        
        if ($ReplaceAll) {
            # Remove existing rules for this user first
            $currentACL.PurgeAccessRules([System.Security.Principal.NTAccount]$User)
        }
        
        # Add the new rule
        if ($PreserveExistingAccess) {
            $currentACL.SetAccessRule($accessRule)  # Adds or updates
        } else {
            $currentACL.AddAccessRule($accessRule)  # Always adds
        }
        
        # Apply the ACL
        Set-Acl -Path $Path -AclObject $currentACL
    }
    
    # Verify the changes
    $finalACL = Get-Acl -Path $Path
    
    if ($PSCmdlet.ParameterSetName -eq "Manual") {
        $result = $finalACL.Access | Where-Object { $_.IdentityReference -eq $User }
        if ($result) {
            Write-Host "Permissions set successfully for '$User' on '$Path'" -ForegroundColor Green
            return $result
        } else {
            Write-Warning "Failed to set permissions for '$User' on '$Path'"
            return $null
        }
    } else {
        Write-Host "Permissions copied successfully from '$SourcePath' to '$Path'" -ForegroundColor Green
        return $finalACL.Access
    }
}
SignatureBlock

