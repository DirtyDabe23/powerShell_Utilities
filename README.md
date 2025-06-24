# EVAPCO IT Automation Repository

Welcome to the EVAPCO IT automation toolkit! This repository contains PowerShell modules, runbooks, and scripts designed to streamline IT operations and management tasks.

## Quick Start

### Prerequisites
- PowerShell 7.0 or later
- Appropriate permissions for target systems
- **Always backup data before running any scripts**

### Installation
1. Clone this repository to your local machine
2. Navigate to the `Modules\Install-EvapcoModule\` directory
3. Run the installation script to set up the EVAPCO module

## Repository Structure

### Modules (`\Modules\`)
**Ready-to-use PowerShell modules for common tasks:**

#### User Management
- `Get-EvapcoUser` - Retrieve user information
- `Get-EvapcoUserDevices` - Get devices assigned to users
- `Rename-EvapcoUser` - Safely rename user accounts
- `Remove-EvapcoDeviceAssignment` - Unassign devices from users

#### Device & System Management
- `Get-Device42Devices` - Query Device42 inventory
- `Get-InTuneWindowsManagedDevices` - Manage Intune devices
- `Install-SolidEdge` - Automated SolidEdge installation
- `Remove-TeamsCache` - Clear Teams cache issues
- `Start-BetterIISReset` - Improved IIS restart process

#### Jira Integration
- `Get-JiraTicket` - Retrieve Jira ticket information
- `Get-AssignedJiraIssues` - Get assigned issues
- `Jira-Comments` - Manage ticket comments
- `Jira-Tickets` - Create and modify tickets

#### Server & Network Tools
- `Start-ConfigureEvapcoServer` - Server setup automation
- `Start-FullNetTest` - Comprehensive network testing
- `Start-BetterMessageTrace` - Enhanced message tracking

### Runbooks (`\Runbooks\`)
**Automated workflows for complex processes:**

#### User Lifecycle Management
- `User-New-*` - New user creation workflows
- `User-Change-*` - User modification processes  
- `User-Transfer-*` - User transfer procedures

#### System Administration
- `M365_Update_Device_Attributes` - Microsoft 365 device management
- `Install-Modules-Server` - Server module installation
- `Invoke-Evapco-Sync` - Data synchronization processes

### Standard Scripts (`\standardScripts\`)
**Organized by technology/service:**

- **Citrix\** - Citrix environment management
- **Device42\** - Inventory system integration
- **ExO\** - Exchange Online operations
- **Graph\** - Microsoft Graph API interactions
- **InTune\** - Mobile device management
- **Jira\** - Issue tracking automation
- **LocalAD\** - Active Directory tasks
- **Teams\** - Microsoft Teams administration
- **vmWare\** - Virtual infrastructure management

### Misc Projects (`\miscProjects\`)
**Development and configuration files:**
- **Configurations\** - System and application configs
- **Python\** - Python automation scripts
- **VS2022\** - Visual Studio projects
- **Markdown\** - Documentation templates

## Common Use Cases

### Quick Tasks
```powershell
# Get user information
Get-EvapcoUser -UserName "john.doe"

# Check device assignments
Get-EvapcoUserDevices -UserName "jane.smith"

# Clear Teams cache
Remove-TeamsCache
```

### Automated Workflows
```powershell
# New user setup (run from Runbooks)
.\User-New-1-Orca\RunNewUser.ps1

# Server configuration
.\Start-ConfigureEvapcoServer\ConfigureServer.ps1
```

## Safety Guidelines

> **WARNING**: Always follow these safety practices:

1. **Backup First** - Ensure you have backups of any data you'll be modifying
2. **Test Environment** - Run scripts in test environments when possible
3. **Review Code** - Understand what a script does before executing it
4. **Have a Rollback Plan** - Know how to undo changes if something goes wrong
5. **Ask for Help** - Contact your supervisor if you're unsure about any process

## Getting Help

- **Technical Issues**: Contact GIT-HelpDesk@EVAPCO.com
- **Script Questions**: Review inline documentation in each script
- **Process Concerns**: Consult with your supervisor

## Acknowledgments

This repository was made possible by:
- [Oh-My-Posh](https://github.com/jandedobbeleer/oh-my-posh) by JanDeDobbeleer
- [BurntToast](https://github.com/Windos/BurntToast) by Windos

---

**Author**: David J. Drosdick (2023 - Present)  
**Last Updated**: June 2025

*Remember: With great power comes great responsibility. Use these tools wisely!*
