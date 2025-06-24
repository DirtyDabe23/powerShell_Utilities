function Set-QuickResponse{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "Jira")]
        [switch]$Jira,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the GHD Project Overview",ParameterSetName = "Jira")]
            [switch]$GHD,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Access Request Form",ParameterSetName = "Jira")]
            [switch]$AccessRequest,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Software Request Form",ParameterSetName = "Jira")]
            [switch]$SoftwareRequest,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the User Change Form",ParameterSetName = "Jira")]
            [switch]$UserChange,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the New User Form",ParameterSetName = "Jira")]
            [switch]$NewUser,
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "GitHub")]
        [switch]$GitHub,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the Modules",ParameterSetName = "GitHub")]
            [switch]$Modules,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Runbooks",ParameterSetName = "GitHub")]
            [switch]$Runbooks,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Projects in GitHub",ParameterSetName = "GitHub")]
            [switch]$Projects,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Configurations",ParameterSetName = "GitHub")]
            [switch]$Configs,
        [Parameter(Mandatory = $true,HelpMessage="Select This to get links for M365",ParameterSetName = "M365")]
        [switch]$M365,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the Azure Portal",ParameterSetName = "M635")]
            [switch]$AzurePortal,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Exchange Admin Center",ParameterSetName = "M365")]
            [switch]$ExchangeAdmin,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the M365 Admin Portal",ParameterSetName = "M365")]
            [switch]$M365Portal,
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "Confluence")]
        [switch]$Confluence,
            [Parameter(Mandatory = $false,HelpMessage="Select This to get the link to the Service Desk Home Page",ParameterSetName = "Confluence")]
            [switch]$GSD,
            [Parameter(Mandatory = $false, HelpMessage="Select This to get the link to the Operations Documentation",ParameterSetName = "Confluence")]
            [switch]$OPS,
        [Parameter(Mandatory = $true,Position = 0,ParameterSetName = "InTune")]
        [switch]$InTune,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Devices Page",ParameterSetName = "Devices")]
            [switch]$Devices,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Apps Page",ParameterSetName = "Apps")]
            [switch]$Apps,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Policies Page",ParameterSetName = "Policies")]
            [switch]$Policies,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Users Page",ParameterSetName = "Users")]
            [switch]$Users,
            [Parameter(Mandatory = $true,HelpMessage="Select This to get to the link to the InTune Groups Page",ParameterSetName = "Groups")]
            [switch]$Groups
    )
        if($Jira){
            if ($GHD) {
                $quickResponse = "https://parentCompany.atlassian.net/jira/servicedesk/projects/GHD/queues/custom/340"
            } 
            if ($AccessRequest) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/create/263"
            } 
            if ($SoftwareRequest) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/group/58/create/315"
            } 
            if($UserChange) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/create/453"
            } 
            if($NewUser) {
                $quickResponse = "https://parentCompany.atlassian.net/servicedesk/customer/portal/26/group/57/create/244"
            }
        }
        if($GitHub){
            if ($Modules) {
                $quickResponse = "https://github.com/DirtyDabe23/parentCompanyRepo/tree/main/Modules"
            }
            if ($Runbooks) {
                $quickResponse = "https://github.com/DirtyDabe23/parentCompanyRepo/tree/main/Runbooks"
            }
            if($Projects) {
                $quickResponse = "https://github.com/DirtyDabe23/Projects"
            }
            if ($Configs) {
                $quickResponse = "https://github.com/DirtyDabe23/public_Configs_Misc"
            }
        if($M365){
            if($AzurePortal){
                $quickResponse = "https://portal.azure.com/"
            }
            if($ExchangeAdmin){
                $quickResponse = "https://admin.exchange.microsoft.com/"
            } 
            if($M365Portal) {
                $quickResponse = "https://admin.microsoft.com/"
            }
        }
        if($Confluence) {
            if( $GSD) {
                $quickResponse = "https://parentCompany.atlassian.net/wiki/spaces/GSD/overview"
            }  
            if($OPS) {
                $quickResponse = "https://parentCompany.atlassian.net/wiki/spaces/GOC/overview"
            }
        }
        if($InTune) {
            if ($Devices) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_DeviceSettings/DevicesMenuBlade/overview"
            } elseif ($Apps) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_Apps/AppsMenuBlade/overview"
            } elseif ($Policies) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_Policy/PolicyMenuBlade/overview"
            } elseif ($Users) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_User/UserMenuBlade/overview"
            } elseif ($Groups) {
                $quickResponse = "https://portal.azure.com/#blade/Microsoft_Intune_Group/GroupMenuBlade/overview"
            }
        }
    }
    Set-Clipboard -Value $quickResponse
}
SignatureBlock

