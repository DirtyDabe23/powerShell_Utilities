
function Get-Permission{
    <#
    .SYNOPSIS
    Retrieves permissions for a specified user or group on a given object.
    .DESCRIPTION
    This function retrieves the permissions on a given object and returns the information in a human readable format.
    .PARAMETER Path
    The path to the object for which permissions are being retrieved.
    .PARAMETER Identity
    The user or group for which permissions are being retrieved.
    .PARAMETER Type
    The type of object for which permissions are being retrieved (e.g., 'User', 'Group').
    .PARAMETER ObjectType
    The type of object for which permissions are being retrieved (e.g., 'File', 'Folder', 'Share').
    .PARAMETER IncludeInherited
    A switch to include inherited permissions in the output.
    .PARAMETER IncludeEffective
    A switch to include effective permissions in the output.
    .EXAMPLE
    Get-Permission -Path "C:\MyFolder" -Identity "Domain\User" -Type "User" -ObjectType "Folder"
    Retrieves permissions for the user "Domain\User" on the folder "C:\MyFolder".
    .EXAMPLE
    Get-Permission -Path "C:\MyFolder" -Identity "Domain\Group" -Type "Group" -ObjectType "Folder" -IncludeInherited
    Retrieves permissions for the group "Domain\Group" on the folder "C:\MyFolder", including inherited permissions.
    .NOTES
    You must have the necessary permissions to retrieve permissions on the specified object.
    .LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-acl?view=powershell-7.5#notes
    .OUTPUTS
    System.Management.Automation.PSObject
    Returns a PSObject containing the permissions for the specified user or group on the given object.    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,HelpMessage = "Path to the object for which permissions are being retrieved.",Position = 0,
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false, HelpMessage = "The user or group for which permissions are being retrieved.", Position = 1,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Identity,

        [Parameter(Mandatory = $false, HelpMessage = "The type of object for which permissions are being retrieved.", Position = 2,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('User', 'Group')]
        [string]$Type,
        [Parameter(Mandatory = $false, HelpMessage = "The type of object for which permissions are being retrieved.", Position = 3,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('File', 'Folder', 'Share')]
        [string]$ObjectType,
        [Parameter(Mandatory = $false, HelpMessage = "Include inherited permissions in the output.", Position = 4,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$IncludeInherited
    )
    begin {
        Write-Verbose "Starting Get-Permission function"
    }
    process{
        try{Test-Path -Path $Path -ErrorAction Stop | Out-Null
            Write-Verbose "The specified path '$Path' exists and is accessible."
        }
        catch {
            Write-Error "The specified path '$Path' does not exist or is inaccessible."
            return
        }
        $acl = Get-Acl -Path $Path -ErrorAction Stop
        if ($null -eq $acl) {
            Write-Error "Failed to retrieve ACL for the specified path '$Path'."
            return
        }
        $permissions = @()
        foreach ($access in $acl.Access) {
            $permissions += [PSCustomObject]@{
                IdentityReference = $access.IdentityReference
                AccessControlType = $access.AccessControlType
                FileSystemRights  = $access.FileSystemRights
                IsInherited       = $access.IsInherited
                InheritanceFlags  = $access.InheritanceFlags
                PropagationFlags  = $access.PropagationFlags
            }
        }
        switch ($Identity){
            $null{
                Write-Verbose "No Identity specified, returning all permissions for the path '$Path'."
                [pscustomobject]$returnPermissions = $permissions | Select-Object IdentityReference, AccessControlType, FileSystemRights, IsInherited, InheritanceFlags, PropagationFlags
            }
            Default {
                Write-Verbose "Filtering permissions for Identity '$Identity'."
                $filteredPermissions = $permissions | Where-Object { $_.IdentityReference -like "*$Identity*" }
                if ($filteredPermissions.Count -eq 0) {
                    Write-Warning "No permissions found for Identity '$Identity' on the path '$Path'."
                    return
                }
                [pscustomobject]$returnPermissions = $filteredPermissions | Select-Object IdentityReference, AccessControlType, FileSystemRights, IsInherited, InheritanceFlags, PropagationFlags
            }
        }
        switch($Type) {
            'User' {
                Write-Verbose "Filtering permissions for User type."
                $returnPermissions = $returnPermissions | Where-Object { $_.IdentityReference -like "*$Identity*" -and $_.AccessControlType -eq 'Allow' }
            }
            'Group' {
                Write-Verbose "Filtering permissions for Group type."
                $returnPermissions = $returnPermissions | Where-Object { $_.IdentityReference -like "*$Identity*" -and $_.AccessControlType -eq 'Allow' }
            }
            'Share'{
                Write-Verbose "Filtering permissions for Share type."
                $returnPermissions = $returnPermissions | Where-Object { $_.IdentityReference -like "*$Identity*" -and $_.AccessControlType -eq 'Allow' }
            }
            Default {
                Write-Verbose "No specific type provided, returning all permissions."
            }
        }
        Switch($includeInherited) {
            $true {
                Write-Verbose "Including inherited permissions."
                $returnPermissions = $returnPermissions | Where-Object { $_.IsInherited -eq $true }
            }
            $false {
                Write-Verbose "Excluding inherited permissions."
                $returnPermissions = $returnPermissions | Where-Object { $_.IsInherited -eq $false }
            }
            default {
                Write-Verbose "No IncludeInherited switch provided, returning all permissions."
            }
        }
        if ($returnPermissions.Count -eq 0) {
            Write-Warning "No permissions found for the specified criteria."
            return
        }
        Else{
            Write-Verbose "Returning permissions for the specified criteria."
            return $returnPermissions
        }
    }
}

SignatureBlock

