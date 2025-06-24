# EVAPCO Automation Runbooks

This directory contains automated workflows and runbooks for complex IT processes. These runbooks combine multiple operations into streamlined workflows for common administrative tasks.

## Quick Start

### Prerequisites
- EVAPCO PowerShell modules installed
- Appropriate system permissions
- Network connectivity to target systems
- **Always backup data before running runbooks**

### Execution
```powershell
# Navigate to the specific runbook directory
cd .\User-New-1-Orca\
# Execute the runbook
.\RunNewUser.ps1
```

## Available Runbooks

### User Lifecycle Management

#### New User Creation
- **User-New-1-Orca** - Initial user creation in Orca system
- **User-New-2-Citrix-Doclink-Sage** - Setup Citrix, DocLink, and Sage access for new users

#### User Modifications
- **User-Change-1-Orca-72** - Modify user settings in Orca (Server 72)
- **User-Change-2-Graph** - Update user information via Microsoft Graph API
- **User-Change-2-LocalAD-72** - Modify local Active Directory settings (Server 72)
- **User-Change-3-LicenseUpdate** - Update user license assignments

#### User Transfers
- **User-Transfer-2-Origin-72** - Transfer user data from origin system (Server 72)
- **User-Transfer-3-Restore** - Restore user data during transfer process
- **User-Transfer-4-Modify-Entra-Account** - Modify Azure AD/Entra account during transfer
- **User-Transfer-5-Create-Local-From-Graph-72** - Create local account from Graph data (Server 72)

### System Administration

#### Infrastructure Management
- **Install-Modules-Server** - Automated server module installation
- **Install-Modules-Server.ps1** - Server module installation script
- **M365_Update_Device_Attributes** - Update Microsoft 365 device attributes

#### Data Synchronization
- **Invoke-Evapco-Sync** - Comprehensive data synchronization between systems

#### Device Management
- **device42-Update-endUsers** - Update end user information in Device42

### Jira Automation

#### User Auditing
- **Jira-userAudit-Invalid-Company** - Audit users with invalid company assignments
- **jira-userAudit-Invalid-Office** - Audit users with invalid office assignments

#### Process Automation
- **Jira_Add_Affected_EVAPCO_Locations** - Add affected locations to Jira tickets
- **Jira_Connection_Update_Orders_With_Shipment_Info** - Update orders with shipment information
- **Jira_External_Company_Users_Create** - Create external company user accounts
- **Jira_External_Company_Users_Invite** - Send invitations to external users
- **Jira_Proc_Set_Location_Department_Acct_Number** - Set location, department, and account numbers
- **jira_Create_Approved_Distro** - Create approved distribution lists
- **When_Device_Decomm_Created_Update_SubTasks** - Update subtasks when device decommission tickets are created

### Exchange Online Operations
- **ExO-Set-mailboxRegion** - Set mailbox regions in Exchange Online

### Monitoring & Maintenance
- **Spectrum_Error_Tagging** - Tag errors in Spectrum monitoring system

### Testing & Development
- **Test-HybridWorker-Runbook-51** - Test hybrid worker functionality (Server 51)
- **Test-HybridWorker-Runbook-72** - Test hybrid worker functionality (Server 72)
- **Test-Invoker-72** - Test PowerShell remoting functionality (Server 72)

### Specialized Workflows
- **Orcha** - Specialized Orcha system workflows

## Usage Examples

### New User Setup
```powershell
# Complete new user onboarding
cd .\User-New-1-Orca\
.\CreateNewUser.ps1 -UserName "john.doe" -Department "IT"

# Setup additional systems
cd ..\User-New-2-Citrix-Doclink-Sage\
.\SetupUserSystems.ps1 -UserName "john.doe"
```

### User Transfer Process
```powershell
# Step 1: Initiate transfer
cd .\User-Transfer-2-Origin-72\
.\InitiateTransfer.ps1 -SourceUser "old.user" -TargetUser "new.user"

# Step 2: Restore data
cd ..\User-Transfer-3-Restore\
.\RestoreUserData.ps1 -UserName "new.user"
```

### System Maintenance
```powershell
# Update M365 device attributes
cd .\M365_Update_Device_Attributes\
.\UpdateDeviceAttributes.ps1

# Synchronize systems
cd ..\Invoke-Evapco-Sync\
.\StartSync.ps1
```

## Runbook Structure

Each runbook directory typically contains:
- **Main script file** - Primary execution script
- **Parameters.json** - Configuration parameters
- **README.md** - Specific runbook documentation
- **Logs\** - Execution logs directory
- **Config\** - Additional configuration files

## Safety Guidelines

**CRITICAL**: Runbooks perform complex, multi-system operations.

1. **Environment Verification** - Confirm target environment before execution
2. **Parameter Validation** - Verify all parameters are correct
3. **Dependency Check** - Ensure all required modules and connections are available
4. **Rollback Plan** - Have a documented rollback procedure
5. **Monitoring** - Monitor execution logs during runbook execution
6. **Documentation** - Document all runbook executions and results

## Troubleshooting

### Common Issues
- **Module Dependencies** - Ensure all required modules are installed
- **Network Connectivity** - Verify network access to target systems
- **Permissions** - Confirm appropriate permissions on all target systems
- **Parameter Errors** - Validate all input parameters

### Log Files
Check logs in each runbook's `Logs\` directory for detailed execution information.

## Support

For runbook-specific assistance:
- Review runbook-specific README.md files
- Check execution logs
- Contact: GIT-HelpDesk@EVAPCO.com

---
**Last Updated**: June 2025
