function Start-MoveVMDatastore {
    <#
    .SYNOPSIS
    Moves a virtual machine to a different datastore in vCenter.

    .DESCRIPTION
    This script connects to a vCenter server, prompts for a virtual machine name,
    and moves the specified VM from one datastore to another. It provides progress updates
    during the migration process.

    .PARAMETER vmName
    The name of the virtual machine to be moved.

    .PARAMETER hostServer
    The vCenter server to connect to.

    .PARAMETER sourceDatastoreName 
    The name of the source datastore from which the VM will be moved.

    .PARAMETER destinationDatastoreName
    The name of the destination datastore to which the VM will be moved.

    .PARAMETER credential
    The vCenter server credential used for authentication.
    
    .PARAMETER silent
    Set to `$true to suppress progress output.

    .EXAMPLE
    Start-MoveVMDatastore
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,    HelpMessage = "Enter the Host Server Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$hostServer,
        [Parameter(Position = 1,    HelpMessage = "Enter the Host Server Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$sourceDatastoreName,        
        [Parameter(Position = 2,    HelpMessage = "Enter the Host Server Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$destinationDatastoreName,
        [Parameter(Position = 3,    HelpMessage = "Enter the vm Name.`nExample: vcenter.company.com",  Mandatory = $true)]
        [string]$vmName,
        [Parameter(Position = 4,    HelpMessage = "Enter the vCenter Server Credential.`nExample: vcenter.company.com",  Mandatory = $true)]
        [PSCredential]$credential,
        [Parameter(Position = 5,    HelpMessage = "Set to `$true to suppress progress output.", Mandatory = $false)]
        [switch]$silent
    )
    #Validate that not only are the modules installed, but that they are imported with a new prefix, as there are conflicts between the VMware PowerCLI modules and the standard PowerShell cmdlets.
    $modules = @("VMWAre.VimAutomation.Core","VMWare.VimAutomation.Common")
    forEach ($module in $modules){
        try{
            Import-Module -Name $module -Prefix "VI" -ErrorAction Stop
        }
        catch {
            throw "Error importing '$module' module. Ensure it is installed and available.`nError: $_"
        }
    }
    # Connect to vCenter
    try{
        Connect-VIServer -Server $hostServer -Credential $credential -ErrorAction Stop
    }
    catch{
        throw "Error connecting to vCenter server '$hostServer'`nError: $_"   
    }
    # Retrieve both the destination and source datastores. This is a terminal error and would cause the process at large to fail.
    try{
        $sourceDatastore = Get-Datastore -Name $sourceDatastoreName -ErrorAction Stop
    }
    catch {
        Disconnect-VIServer -Confirm:$false
        throw "Error retrieving source datastore '$sourceDatastoreName'`nError: $_"
    }
    try{
        $destinationDatastore = Get-Datastore -Name $destinationDatastoreName -ErrorAction Stop
    }
    catch {
        Disconnect-VIServer -Confirm:$false
        throw "Error retrieving destination datastore '$destinationDatastoreName'`nError: $_"
    }
    # Retrieve the virtual machine object
    try{
        $vm = Get-VIVM -Name $vmName -ErrorAction SilentlyContinue
    }
    catch {
        Disconnect-VIServer -Confirm:$false
        throw "Error retrieving virtual machine '$vmName'`nError: $_"
    }

    # Validate the selected virtual machine
    if ($vm.ExtensionData.Storage.PerDatastoreUsage.Datastore -contains $sourceDatastore.Id) {
        try {
            Write-Output "Initiating migration of virtual machine '$vmName' to datastore '$($destinationDatastore.Name)'......"
            
            # Start migration asynchronously
            $task = Move-VIVM -VM $vm -Datastore $destinationDatastore -Confirm:$false -RunAsync

            # Monitor migration progress
            do {
                $taskView = Get-VITask | Where-Object { $_.Id -eq $task.Id }
                $percent = $taskView.PercentComplete
                $state = $taskView.State
                if(!($silent)){
                    if ($null -ne $percent) {
                        Write-Progress -Activity "Migrating virtual machine" -Status "$percent% Complete" -PercentComplete $percent
                    } else {
                        Write-Progress -Activity "Migrating virtual machine" -Status "Starting....." -PercentComplete 0
                    }
                }

                Start-Sleep -Milliseconds 200
            } while ($state -eq "In Progress")

            # Migration result
            if ($state -eq "Success") {
                Write-Output "VM '$vmName' has successfully moved." 
            } else {
                Throw "Migration failed or was cancelled. Status: $state"
            }

        } 
        catch {
            throw "Error during VM migration: $_"
        }
    } 
    else {
        # Disconnect from vCenter
        Disconnect-VIServer -Confirm:$false
        throw "VM '$vmName' not found in $($sourceDatastore.Name)."
    }
    # Disconnect from vCenter
    Disconnect-VIServer -Confirm:$false
    return $taskView
}
