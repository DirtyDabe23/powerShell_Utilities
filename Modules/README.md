# EVAPCO PowerShell Modules

This directory contains ready-to-use PowerShell modules for common IT operations and management tasks.

## Quick Start

### Installation
```powershell
# Navigate to the Install-EvapcoModule directory
cd .\Install-EvapcoModule\
# Run the installation script
.\InstallModule.ps1
```

## Available Modules

### User Management
- **Get-EvapcoUser** - Retrieve comprehensive user information from various systems
- **Get-EvapcoUserDevices** - List all devices assigned to a specific user
- **Rename-EvapcoUser** - Safely rename user accounts across systems
- **Remove-EvapcoDeviceAssignment** - Remove device assignments from users
- **Get-LicenseAssignedDate** - Check when licenses were assigned to users
- **Get-LocationUserCount** - Get user counts by location

### Device & System Management
- **Get-Device42Devices** - Query Device42 inventory system for device information
- **Get-Device42Win10Readiness** - Check Windows 10 readiness status
- **Get-InTuneWindowsManagedDevices** - Manage and query Intune-managed Windows devices
- **Get-CimProgram** - Retrieve installed programs via CIM
- **Install-SolidEdge** - Automated SolidEdge software installation
- **Remove-TeamsCache** - Clear Microsoft Teams cache to resolve issues
- **Uninstall-CimProgram** - Remove programs using CIM methods

### Jira Integration
- **Get-JiraTicket** - Retrieve detailed Jira ticket information
- **Get-AssignedJiraIssues** - Get issues assigned to specific users
- **Get-ReportedJiraIssues** - Get issues reported by specific users
- **Jira-Comments** - Add and manage comments on Jira tickets
- **Jira-Tickets** - Create, update, and modify Jira tickets

### Server & Network Tools
- **Start-ConfigureEvapcoServer** - Automated server configuration and setup
- **Start-ConfigureServerTLS** - Configure TLS settings on servers
- **Start-FullNetTest** - Comprehensive network connectivity testing
- **Start-BetterIISReset** - Enhanced IIS restart with logging
- **Start-BetterMessageTrace** - Improved Exchange message tracing
- **Start-MoveVMDataStore** - Move virtual machine datastores

### Custom Field Management
- **Get-CustomField** - Retrieve custom field definitions
- **Get-CustomFieldValues** - Get values for custom fields
- **New-CustomField** - Create new custom fields
- **Update-CustomField** - Modify existing custom fields

### Administrative Tools
- **Add-Alias** - Create and manage PowerShell aliases
- **Audit-Defender** - Audit Windows Defender configurations
- **Clear-Enrollment** - Clear device enrollment data
- **Export-PublicFolder** - Export Exchange public folder data
- **Format-Name** - Standardize name formatting
- **Get-Permission** - Retrieve permission information
- **Set-Permission** - Modify permissions on objects
- **Install-CustomModule** - Install custom PowerShell modules
- **Set-DevEnvironment** - Configure development environments
- **Set-WindowTitle** - Customize PowerShell window titles

### Specialized Tools
- **Get-CompliantDepartments** - Check departmental compliance status
- **New-DeviceGroupPerEvapcoLocation** - Create device groups by location
- **Set-MgDeviceExtensionAttribute** - Modify device extension attributes
- **Set-NewUserDataPath** - Configure data paths for new users
- **Start-ReplaceNamesAndContent** - Bulk find and replace operations
- **Start-SignEvapcoScript** - Digitally sign PowerShell scripts
- **Invoke-EvapcoSync** - Synchronize data across systems

## Usage Examples

### Basic User Operations
```powershell
# Get user information
Get-EvapcoUser -UserName "john.doe"

# Check user's devices
Get-EvapcoUserDevices -UserName "john.doe"

# Get license assignment date
Get-LicenseAssignedDate -UserName "john.doe"
```

### Device Management
```powershell
# Query Device42 for specific device
Get-Device42Devices -DeviceName "WORKSTATION001"

# Check Intune managed devices
Get-InTuneWindowsManagedDevices -Filter "deviceName eq 'WORKSTATION001'"

# Clear Teams cache
Remove-TeamsCache
```

### Jira Operations
```powershell
# Get ticket details
Get-JiraTicket -TicketKey "HELP-1234"

# Get user's assigned issues
Get-AssignedJiraIssues -UserName "john.doe"
```

## Safety Guidelines

**WARNING**: These modules perform system-level operations that can affect production environments.

1. **Test First** - Always test modules in a development environment
2. **Backup Data** - Ensure backups exist before running any modification commands
3. **Review Parameters** - Understand all parameters before execution
4. **Check Permissions** - Verify you have appropriate permissions for the target systems
5. **Document Changes** - Log all changes made using these modules

## Support

For module-specific questions or issues:
- Review the inline help: `Get-Help <ModuleName> -Full`
- Check module documentation in each subdirectory
- Contact: GIT-HelpDesk@EVAPCO.com

---
**Last Updated**: June 2025
