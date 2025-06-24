# parentCompany Standard Scripts

This directory contains PowerShell scripts organized by technology and service type. These scripts provide focused functionality for specific systems and applications.

## Quick Start

### Prerequisites
- PowerShell 5.1 or later
- Appropriate permissions for target systems
- Required PowerShell modules for specific technologies
- **Always test scripts in development environments first**

### Usage
```powershell
# Navigate to the relevant technology folder
cd .\Graph\
# Execute the appropriate script
.\GetUserInfo.ps1 -UserName "john.doe"
```

## Directory Structure

### **Citrix\**
Scripts for Citrix environment management
- Session management
- Application publishing
- User profile management
- Citrix Cloud administration

### **Connection\**
Network and connectivity testing scripts
- Connection validation
- Network diagnostics
- Service connectivity tests

### **Defender\**
Microsoft Defender management scripts
- Policy configuration
- Threat detection
- Security compliance
- Defender for Endpoint management

### **Device42\**
Device42 inventory system integration
- Asset management
- Device discovery
- Inventory reporting
- Data synchronization

### **DocLink\**
DocLink document management system scripts
- Document processing
- User access management
- System configuration

### **parentCompany\**
parentCompany-specific business logic scripts
- Custom business processes
- Internal system integrations
- Company-specific workflows

### **ExO\** (Exchange Online)
Exchange Online management scripts
- Mailbox management
- Mail flow configuration
- Distribution list management
- Exchange Online reporting

### **Graph\**
Microsoft Graph API integration scripts
- User management via Graph
- Group operations
- Application management
- Azure AD operations

### **InTune\**
Microsoft Intune device management
- Device enrollment
- Policy deployment
- Application management
- Compliance reporting

### **Jira\**
Atlassian Jira integration scripts
- Ticket management
- Project administration
- User management
- Workflow automation

### **JobScope\**
JobScope system integration scripts
- Work order management
- Resource scheduling
- Project tracking

### **LocalAD\**
Local Active Directory management
- User account management
- Group operations
- OU management
- AD reporting

### **Mac\**
macOS-specific scripts and tools
- Mac device management
- macOS configuration
- Mac-specific utilities

### **Revit\**
Autodesk Revit management scripts
- License management
- Installation automation
- Configuration deployment

### **SharePoint\**
SharePoint administration scripts
- Site management
- List operations
- Permission management
- Content migration

### **Shortcuts\**
Windows shortcut management utilities
- Shortcut creation
- Desktop management
- Start menu configuration

### **SolidEdge\**
Siemens Solid Edge management
- Software deployment
- License management
- Configuration automation

### **Teams\**
Microsoft Teams administration
- Team management
- Channel operations
- User administration
- Teams reporting

### **ToastAlerts\**
Windows toast notification scripts
- User notifications
- System alerts
- Custom messaging

### **Utils_Misc\**
Miscellaneous utility scripts
- General-purpose tools
- System utilities
- Helper functions

### **Windows\**
Windows operating system scripts
- System configuration
- Windows updates
- Registry management
- Service management

### **vmWare\**
VMware infrastructure management
- Virtual machine operations
- vSphere management
- Resource allocation
- Infrastructure monitoring

## Usage Examples

### Microsoft Graph Operations
```powershell
cd .\Graph\
# Get user information
.\Get-GraphUser.ps1 -UserPrincipalName "user@Domain.extension1"

# Update user properties
.\Set-GraphUserProperty.ps1 -UserPrincipalName "user@Domain.extension1" -Department "IT"
```

### Exchange Online Tasks
```powershell
cd .\ExO\
# Create shared mailbox
.\New-SharedMailbox.ps1 -Name "IT-Support" -Alias "itsupport"

# Set mailbox permissions
.\Set-MailboxPermission.ps1 -Mailbox "shared@Domain.extension1" -User "admin@Domain.extension1"
```

### Active Directory Management
```powershell
cd .\LocalAD\
# Create new user
.\New-ADUser.ps1 -Name "John Doe" -SamAccountName "jdoe" -Department "IT"

# Update user properties
.\Set-ADUserProperties.ps1 -Identity "jdoe" -Title "System Administrator"
```

### Device Management
```powershell
cd .\InTune\
# Get device compliance status
.\Get-DeviceCompliance.ps1 -DeviceName "LAPTOP001"

cd ..\Device42\
# Update device information
.\Update-Device42Record.ps1 -DeviceName "LAPTOP001" -Owner "John Doe"
```

## Script Categories

### Administrative Scripts
- User management
- System configuration
- Permission management
- Reporting tools

### Integration Scripts
- API connections
- Data synchronization
- Cross-system operations
- Workflow automation

### Utility Scripts
- Helper functions
- Common operations
- System diagnostics
- Maintenance tasks

### Monitoring Scripts
- Health checks
- Performance monitoring
- Compliance reporting
- Alert generation

## Safety Guidelines

**WARNING**: These scripts directly interact with production systems.

1. **Read Documentation** - Review script comments and help information
2. **Test Environment** - Always test in development first
3. **Parameter Validation** - Verify all input parameters
4. **Backup Data** - Ensure backups exist before modifications
5. **Monitor Execution** - Watch for errors during script execution
6. **Document Changes** - Log all script executions and results

## Best Practices

### Before Execution
- Review script source code
- Understand script parameters
- Verify target system connectivity
- Confirm appropriate permissions

### During Execution
- Monitor progress and logs
- Watch for error messages
- Verify expected behavior

### After Execution
- Validate results
- Document changes made
- Review logs for issues
- Update documentation if needed

## Support

For script-specific questions:
- Review inline script documentation
- Check script help: `Get-Help .\ScriptName.ps1 -Full`
- Examine script comments and examples
- Contact: GIT-HelpDesk@Domain.extension1

---
**Last Updated**: June 2025

